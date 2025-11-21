import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Pastikan Anda sudah menambahkan package 'intl' di pubspec.yaml
import '../theme.dart';

class DashboardAdminScreen extends StatefulWidget {
  final String kantinId;
  const DashboardAdminScreen({super.key, required this.kantinId});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  // Format mata uang
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // Format tanggal
  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          NesaColors.background, // Menggunakan background abu-abu lembut
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Logika refresh atau notifikasi bisa ditaruh sini
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('kantinId', isEqualTo: widget.kantinId)
            .orderBy('orderDate', descending: true) // Urutkan dari yang terbaru
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: NesaColors.terracotta),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final orders = snapshot.data!.docs;

          // Hitung Ringkasan Statistik Secara Manual dari Data yang Ditarik
          double totalRevenue = 0;
          int totalItemsSold = 0;

          for (var doc in orders) {
            final data = doc.data() as Map<String, dynamic>;
            totalRevenue += (data['totalPrice'] as num? ?? 0).toDouble();
            final items = data['items'] as List<dynamic>? ?? [];
            for (var item in items) {
              totalItemsSold += (item['quantity'] as num? ?? 0).toInt();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Bagian Header Sapaan
                Text(
                  'Halo, Pemilik Kantin!',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ringkasan Penjualan',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Statistik Cards (Grid)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pendapatan',
                        value: currencyFormatter.format(totalRevenue),
                        icon: Icons.monetization_on_outlined,
                        color: Colors.green,
                        bgColor: Colors.green.shade50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Order',
                        value: '${orders.length}',
                        icon: Icons.shopping_bag_outlined,
                        color: NesaColors.terracotta,
                        bgColor: NesaColors.terracottaLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Card Statistik Item Terjual (Full Width)
                _buildStatCard(
                  title: 'Menu Terjual',
                  value: '$totalItemsSold Item',
                  icon: Icons.fastfood_outlined,
                  color: Colors.blue,
                  bgColor: Colors.blue.shade50,
                  isFullWidth: true,
                ),

                const SizedBox(height: 30),

                // 3. List Pesanan Terbaru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Lihat Semua',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: NesaColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ListView.builder(
                  itemCount: orders.length,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Agar scroll mengikuti parent
                  itemBuilder: (context, i) {
                    final orderData = orders[i].data() as Map<String, dynamic>;
                    final orderId = orders[i].id;
                    return _buildOrderCard(orderData, orderId);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isFullWidth ? 20 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String orderId) {
    final items = order['items'] as List<dynamic>? ?? [];
    final totalPrice = order['totalPrice'] ?? 0;
    final date = formatDate(order['orderDate']);
    final userId =
        order['userId'] ??
        'Guest'; // Bisa diganti nama user jika ada fetch user

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          // Header Kartu (Saat tertutup)
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${orderId.substring(0, 5).toUpperCase()}', // ID Singkat
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Text(
                  'Lunas', // Status hardcoded, bisa diganti dinamis nanti
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Total: ${currencyFormatter.format(totalPrice)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: NesaColors.terracotta,
                fontSize: 14,
              ),
            ),
          ),

          // Isi Detail (Saat dibuka)
          children: [
            const Divider(),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item['quantity']}x',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['menu_name'] ?? 'Unknown Menu',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                    Text(
                      currencyFormatter.format(item['price']),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Info Pembeli (Opsional)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Customer ID: $userId',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            'Pesanan masuk akan muncul di sini.',
            style: GoogleFonts.poppins(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
