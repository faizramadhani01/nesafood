import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../theme.dart';

class DashboardAdminScreen extends StatelessWidget {
  final String kantinId;
  final FirestoreService _fs = FirestoreService();

  DashboardAdminScreen({super.key, required this.kantinId});

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
      ),
      backgroundColor: NesaColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getOrdersByKantin(
          kantinId,
        ), // Mendengarkan perubahan data pesanan
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

    // Parsing tanggal agar rapi
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
            // Header: User, Date & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      displayDate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
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

            // Footer: Total & Action Buttons
            Row(
              children: [
                Text(
                  "Total: ${format.format(total)}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: NesaColors.terracotta,
                  ),
                ),
                const Spacer(),

                // LOGIKA TOMBOL ADMIN (Ganti Status)
                if (status == 'pending')
                  ElevatedButton(
                    onPressed: () => _fs.updateOrderStatus(orderId, 'cooking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Proses"),
                  ),
                if (status == 'cooking')
                  ElevatedButton(
                    onPressed: () => _fs.updateOrderStatus(orderId, 'ready'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
