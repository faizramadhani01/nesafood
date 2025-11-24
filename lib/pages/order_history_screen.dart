import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/order.dart';
import '../services/firestore_service.dart';
import 'dart:async';

class OrderHistoryScreen extends StatefulWidget {
  final String username;
  final List<Order>? initialOrders;

  const OrderHistoryScreen({
    required this.username,
    this.initialOrders,
    super.key,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late List<Order> orders;
  String _selectedFilter = 'all'; // all, completed, paid, pending

  @override
  void initState() {
    super.initState();
    // Jika ada initialOrders (dikirim dari checkout), gunakan itu.
    orders = widget.initialOrders != null
        ? List<Order>.from(widget.initialOrders!)
        : [];
    // Jika tidak ada initialOrders, dengarkan data dari Firestore berdasarkan username
    if (widget.initialOrders == null) {
      _subscribeToFirestore();
    }
  }

  StreamSubscription? _ordersSub;
  final _fs = FirestoreService();

  void _subscribeToFirestore() {
    final userId = widget.username;
    _ordersSub = _fs.getOrders(userId).listen((snapshot) {
      final loaded = snapshot.docs
          .map((d) => Order.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      setState(() {
        orders = loaded;
      });
    });
  }

  List<Order> get filteredOrders {
    if (_selectedFilter == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        actions: [
          IconButton(
            tooltip: 'Hapus Semua Riwayat',
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmClearAll,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('Semua', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Selesai', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Dibayar', 'paid'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Menunggu', 'pending'),
                ],
              ),
            ),
          ),
          // Order List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filterValue) {
    final isSelected = _selectedFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filterValue;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.orange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.menuName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order ID: ${order.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: order.getStatusColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.getStatusLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderDetail('Tanggal Pesanan', _formatDate(order.orderDate)),
                const SizedBox(height: 12),
                _buildOrderDetail('Jumlah Item', '${order.quantity}x'),
                const SizedBox(height: 12),
                _buildOrderDetail('Harga per Item', 'Rp ${order.price.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Rp ${order.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Detail pesanan ${order.id}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  void _confirmClearAll() {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada riwayat pesanan untuk dihapus.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text('Anda yakin ingin menghapus semua riwayat pesanan? Tindakan ini tidak dapat diubah.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();

              // Backup untuk Undo (simpan maps agar bisa dikirim kembali ke Firestore jika perlu)
              final backup = List<Order>.from(orders);
              final backupMaps = backup.map((o) => o.toMap(userId: widget.username)).toList();

              try {
                // Hapus dari Firestore
                await _fs.deleteOrdersForUser(widget.username);

                // Update UI
                setState(() {
                  orders.clear();
                });

                // Tampilkan Snackbar dengan opsi Undo (akan mencoba restore ke Firestore)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Semua riwayat pesanan telah dihapus'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () async {
                        try {
                          await Future.wait(backupMaps.map((m) => _fs.addOrder(m)));
                          // Firestore listener akan mem-refresh orders otomatis
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengembalikan riwayat: $e')),
                          );
                        }
                      },
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus riwayat: $e')),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
