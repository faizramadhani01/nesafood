import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../model/menu.dart';
import '../theme.dart';
import '../services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> counts;
  final Map<String, Menu> menuMap;
  final String? username;
  final String kantinId; // <--- Wajib Terima ID

  const CartScreen({
    super.key, 
    required this.counts, 
    required this.menuMap,
    this.username,
    required this.kantinId, 
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<String, int> localCounts;
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    localCounts = Map<String, int>.from(widget.counts);
  }

  // ... (Fungsi _update dan totalPrice TETAP SAMA) ...
  void _update(String name, int newCount) {
    setState(() {
      if (newCount <= 0) {
        localCounts.remove(name);
      } else {
        localCounts[name] = newCount;
      }
    });
  }

  double get totalPrice {
    double sum = 0;
    localCounts.forEach((name, qty) {
      final menu = widget.menuMap[name];
      if (menu != null) sum += menu.price * qty;
    });
    return sum;
  }

  Future<void> _confirmCheckout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anda harus login terlebih dahulu!")));
      return;
    }
    
    // Validasi Kantin ID
    if (widget.kantinId.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Kantin tidak valid.")));
       return;
    }

    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> itemsData = [];
      localCounts.forEach((key, qty) {
        final menu = widget.menuMap[key];
        if (menu != null) {
          itemsData.add({
            'menu_name': menu.name,
            'price': menu.price,
            'quantity': qty,
            'image': menu.image,
          });
        }
      });

      final orderData = {
        'userId': user.uid,
        'userName': user.displayName ?? widget.username ?? 'User',
        'items': itemsData,
        'totalPrice': totalPrice,
        'status': 'pending',
        'orderDate': DateTime.now().toIso8601String(),
        
        // PENTING: Gunakan ID Kantin yang diterima dari parameter (Dinamis)
        'kantinId': widget.kantinId, 
      };

      await _firestoreService.addOrder(orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil dikirim!"), backgroundColor: Colors.green),
        );
        context.pop(<String, int>{}); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal order: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: AppBar(
        title: Text('Keranjang', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(localCounts),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: localCounts.isEmpty 
              ? Center(child: Text("Keranjang Kosong", style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: localCounts.length,
                  itemBuilder: (ctx, i) {
                    final name = localCounts.keys.elementAt(i);
                    return _buildCartItem(name, currencyFormat);
                  },
                ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Pembayaran", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                    Text(currencyFormat.format(totalPrice), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: NesaColors.terracotta)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (localCounts.isEmpty || _isLoading) ? null : _confirmCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NesaColors.terracotta,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                        : Text("Pesan Sekarang", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(String name, NumberFormat format) {
    final menu = widget.menuMap[name];
    final qty = localCounts[name] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60, height: 60,
              child: Image.network(
                menu?.image ?? '', 
                fit: BoxFit.cover, 
                errorBuilder: (_,__,___)=>const Icon(Icons.fastfood)
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                Text(format.format(menu?.price ?? 0), style: GoogleFonts.poppins(color: NesaColors.terracotta, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey), onPressed: () => _update(name, qty - 1)),
              Text("$qty", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_rounded, size: 20, color: NesaColors.terracotta), onPressed: () => _update(name, qty + 1)),
            ],
          ),
        ],
      ),
    );
  }
}