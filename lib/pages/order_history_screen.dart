import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import '../model/order.dart';
import '../services/firestore_service.dart';
import 'dart:async';
import '../theme.dart';

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
  String _selectedFilter = 'all';

  StreamSubscription? _ordersSub;
  final _fs = FirestoreService();
  
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    orders = widget.initialOrders != null ? List<Order>.from(widget.initialOrders!) : [];
    
    _subscribeToFirestore();
  }

  void _subscribeToFirestore() {
    // --- PERBAIKAN LOGIKA DI SINI ---
    // Jangan pakai widget.username, karena bisa jadi isinya 'Guest' atau Nama.
    // Kita butuh UID (User ID) yang unik dan pasti.
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Dengarkan pesanan milik UID yang sedang login saat ini
      _ordersSub = _fs.getOrders(user.uid).listen((snapshot) {
        final loaded = snapshot.docs
            .map((d) => Order.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList();
        if (mounted) {
          setState(() {
            orders = loaded;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  List<Order> get filteredOrders {
    if (_selectedFilter == 'all') return orders;
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: AppBar(
        title: Text('Riwayat Pesanan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
             if (context.canPop()) {
              context.pop(); 
            } else {
              // Fallback ke Home jika tidak bisa pop
              // Pastikan kita kirim nama display agar Home menyapa dengan benar
              final name = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
              context.go('/home', extra: name);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmClearAll,
            tooltip: "Hapus Riwayat",
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Menunggu', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dimasak', 'cooking'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Siap', 'ready'), // Tambahan status Ready
                  const SizedBox(width: 8),
                  _buildFilterChip('Selesai', 'completed'),
                ],
              ),
            ),
          ),
          
          // List Order
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('Belum ada riwayat pesanan', style: GoogleFonts.poppins(color: Colors.grey)),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: NesaColors.terracotta,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(order.orderDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.menuName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${order.quantity} Item • $dateStr", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.getStatusLabel(),
                  style: GoogleFonts.poppins(color: order.getStatusColor(), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item['quantity']}x ${item['menu_name']}", style: GoogleFonts.poppins()),
                        Text(currencyFormat.format(item['price']), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Harga", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      Text(currencyFormat.format(order.totalPrice), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: NesaColors.terracotta, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmClearAll() {
    // Kita ambil UID langsung di sini juga agar aman
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Riwayat?"),
        content: const Text("Semua data pesanan Anda akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Panggil fungsi hapus dengan UID asli
              await _fs.deleteOrdersForUser(user.uid);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white))
          )
        ],
      )
    );
  }
}