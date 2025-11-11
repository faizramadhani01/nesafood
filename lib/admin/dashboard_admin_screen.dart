import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardAdminScreen extends StatelessWidget {
  final String kantinId;
  const DashboardAdminScreen({super.key, required this.kantinId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('kantinId', isEqualTo: kantinId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('Belum ada pesanan.'));
          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i].data() as Map<String, dynamic>;
              final items = order['items'] as List<dynamic>? ?? [];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Date: ${order['orderDate'] ?? '-'}'),
                      const SizedBox(height: 8),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text('Menu'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text('Qty'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Text('Harga'),
                              ),
                            ],
                          ),
                          ...items.map(
                            (item) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(item['menu_name'] ?? '-'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text('${item['quantity'] ?? 0}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text('Rp${item['price'] ?? 0}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: Rp${order['totalPrice'] ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
