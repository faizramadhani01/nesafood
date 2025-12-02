import 'dart:async'; // WAJIB: Untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart'; // WAJIB

import '../../services/firestore_service.dart';
import '../../theme.dart';
import 'service/admin_auth_service.dart';
import '../../services/notification_service.dart'; // Import Service Notifikasi

class DashboardAdminScreen extends StatefulWidget {
  final String kantinId;
  const DashboardAdminScreen({super.key, required this.kantinId});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final FirestoreService _fs = FirestoreService();
  final AdminAuthService _authService = AdminAuthService();

  // Variabel untuk Notifikasi
  StreamSubscription? _adminOrderSubscription;
  late DateTime _dashboardOpenTime;

  @override
  void initState() {
    super.initState();
    // 1. Catat waktu saat Dashboard dibuka
    // (Agar pesanan kemarin/tadi pagi tidak membunyikan notif lagi saat login)
    _dashboardOpenTime = DateTime.now();

    // 2. Aktifkan Listener Notifikasi
    _setupAdminNotifications();
  }

  @override
  void dispose() {
    // 3. Matikan listener saat keluar halaman (PENTING agar tidak memory leak)
    _adminOrderSubscription?.cancel();
    super.dispose();
  }

  // --- LOGIKA NOTIFIKASI ADMIN ---
  Future<void> _setupAdminNotifications() async {
    // Init service & Minta Izin
    await NotificationService().init();
    await Permission.notification.request();

    // Mulai dengarkan stream pesanan kantin ini
    _adminOrderSubscription = _fs.getOrdersByKantin(widget.kantinId).listen((
      snapshot,
    ) {
      for (var change in snapshot.docChanges) {
        // Cek jika ada dokumen yang DITAMBAHKAN (Added)
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;

          final status = data['status'] ?? 'pending';
          final orderDateStr = data['orderDate'] as String?;
          final tableNumber = data['tableNumber'] ?? '-';

          // Filter: Hanya notifikasi jika pesanan BARU & Status Masih Pending
          if (status == 'pending' && orderDateStr != null) {
            try {
              final orderDate = DateTime.parse(orderDateStr);

              // LOGIKA UTAMA:
              // Hanya bunyikan notifikasi jika tanggal pesanan > waktu buka dashboard
              if (orderDate.isAfter(_dashboardOpenTime)) {
                // TING! Bunyikan Notifikasi
                NotificationService().showNewOrderNotification(
                  change.doc.id,
                  tableNumber.toString(),
                );
              }
            } catch (e) {
              // Ignore date parsing error
            }
          }
        }
      }
    });
  }

  // --- LOGIKA LOGOUT ---
  Future<void> _handleLogout(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      context.go('/login'); // Kembali ke Login
    }
  }

  // --- LOGIKA HAPUS PESANAN ---
  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pesanan?"),
        content: const Text("Pesanan ini akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _fs.deleteOrder(orderId); // Panggil fungsi delete
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pesanan dihapus.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // TOMBOL LOGOUT
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
          ),
        ],
      ),
      backgroundColor: NesaColors.background,
      body: StreamBuilder<QuerySnapshot>(
        // Gunakan widget.kantinId karena sekarang di dalam State
        stream: _fs.getOrdersByKantin(widget.kantinId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: NesaColors.terracotta),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada pesanan masuk.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildAdminOrderCard(
                context,
                doc.id,
                data,
                currencyFormat,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminOrderCard(
    BuildContext context,
    String orderId,
    Map<String, dynamic> data,
    NumberFormat format,
  ) {
    final status = data['status'] ?? 'pending';
    final items = (data['items'] as List<dynamic>?) ?? [];
    final total = (data['totalPrice'] ?? 0).toDouble();
    final userName = data['userName'] ?? 'Unknown';
    final dateStr = data['orderDate'] ?? '';

    final tableNumber = data['tableNumber'] ?? '-';
    final paymentMethod = data['paymentMethod'] ?? 'Cash';

    String displayDate = dateStr;
    try {
      final date = DateTime.parse(dateStr);
      displayDate = DateFormat('dd MMM HH:mm').format(date);
    } catch (e) {
      /* ignore */
    }

    Color statusColor;
    String statusText;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = "Menunggu";
        break;
      case 'cooking':
        statusColor = Colors.blue;
        statusText = "Dimasak";
        break;
      case 'ready':
        statusColor = Colors.green;
        statusText = "Siap";
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = "Selesai";
        break;
      default:
        statusColor = Colors.black;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User, Table, Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Meja: $tableNumber",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // TOMBOL HAPUS ORDER (SAMPAH)
                    IconButton(
                      onPressed: () => _confirmDelete(context, orderId),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: "Hapus Order",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // List Item
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${item['quantity']}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['menu_name'],
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    Text(
                      format.format(item['price']),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Footer
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total: ${format.format(total)}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: NesaColors.terracotta,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          paymentMethod == 'QRIS' ? Icons.qr_code : Icons.money,
                          size: 14,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          paymentMethod,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),

                // Action Buttons
                if (status == 'pending')
                  ElevatedButton(
                    onPressed: () => _fs.updateOrderStatus(orderId, 'cooking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text("Proses"),
                  ),
                if (status == 'cooking')
                  ElevatedButton(
                    onPressed: () => _fs.updateOrderStatus(orderId, 'ready'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text("Siap"),
                  ),
                if (status == 'ready')
                  ElevatedButton(
                    onPressed: () =>
                        _fs.updateOrderStatus(orderId, 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text("Selesai"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
