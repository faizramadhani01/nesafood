import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../model/menu.dart';
import '../model/kantin_data.dart';
import '../theme.dart';
import '../services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> counts;
  final Map<String, Menu> menuMap;
  final String? username;
  final String kantinId;

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

  // --- TAMPILKAN DIALOG PEMBAYARAN ---
  void _showPaymentDialog() {
    Kantin? currentKantin;
    try {
      currentKantin = kantinList.firstWhere((k) => k.id == widget.kantinId);
    } catch (e) {
      currentKantin = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _PaymentBottomSheet(
          qrisUrl: currentKantin?.qrisUrl,
          onConfirm: (method, tableNum) {
            Navigator.pop(context); // Tutup dialog
            _confirmCheckout(method, tableNum); // Lanjut checkout
          },
        ),
      ),
    );
  }

  // --- LOGIKA CHECKOUT KE FIREBASE ---
  Future<void> _confirmCheckout(
    String paymentMethod,
    String tableNumber,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kamu harus login dulu sebelum checkout."),
        ),
      );
      return;
    }

    if (widget.kantinId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data kantin tidak valid. Silakan coba lagi."),
        ),
      );
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
            'quantity': qty,
            'price': menu.price,
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
        'kantinId': widget.kantinId,
        'paymentMethod': paymentMethod,
        'tableNumber': tableNumber,
        'isPaid': false,
      };

      await _firestoreService.addOrder(orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Pesananmu berhasil dibuat! Terima kasih sudah memesan ❤️",
            ),
          ),
        );
        context.pop(<String, int>{});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Waduh, gagal membuat pesanan. Silakan coba lagi."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: AppBar(
        title: Text(
          'Keranjang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
                ? Center(
                    child: Text(
                      "Keranjang Kosong",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
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
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Pembayaran",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalPrice),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NesaColors.terracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // PANGGIL DIALOG
                    onPressed: (localCounts.isEmpty || _isLoading)
                        ? null
                        : _showPaymentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NesaColors.terracotta,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Lanjut Pembayaran",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
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

  Widget _buildCartItem(String name, NumberFormat format) {
    final menu = widget.menuMap[name];
    final qty = localCounts[name] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                menu?.image ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  format.format(menu?.price ?? 0),
                  style: GoogleFonts.poppins(
                    color: NesaColors.terracotta,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () => _update(name, qty - 1),
              ),
              Text(
                "$qty",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_rounded,
                  size: 20,
                  color: NesaColors.terracotta,
                ),
                onPressed: () => _update(name, qty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGET BOTTOM SHEET ---
class _PaymentBottomSheet extends StatefulWidget {
  final String? qrisUrl;
  final Function(String, String) onConfirm; // Callback (Method, TableNumber)

  const _PaymentBottomSheet({this.qrisUrl, required this.onConfirm});

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  String _selectedMethod = 'Cash';
  final _tableCtrl = TextEditingController();

  @override
  void dispose() {
    _tableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Input Nomor Meja
          Text(
            "Nomor Meja",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tableCtrl,
            decoration: InputDecoration(
              hintText: "Contoh: Meja 5, A12",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pilihan Metode
          Text(
            "Metode Pembayaran",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOption(Icons.money, "Tunai (Cash)", "Cash"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOption(Icons.qr_code_scanner, "QRIS", "QRIS"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Konten Dinamis
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _selectedMethod == 'Cash'
                  ? Colors.orange.shade50
                  : Colors.white,
              border: Border.all(
                color: _selectedMethod == 'Cash'
                    ? Colors.orange
                    : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedMethod == 'Cash'
                ? Column(
                    children: [
                      const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.orange,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "JANGAN LUPA SIAPIN CASHMU YA!\nSESUAI NOMINAL YANG TERTERA SAAT MENGAMBIL MAKANANMU 😉",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        "Scan QRIS Kantin",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      widget.qrisUrl != null
                          ? Image.network(
                              widget.qrisUrl!,
                              height: 180,
                              width: 180,
                            )
                          : const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        "Tunjukkan bukti bayar ke kasir",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_tableCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mohon isi nomor meja dahulu!"),
                    ),
                  );
                  return;
                }
                widget.onConfirm(_selectedMethod, _tableCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NesaColors.terracotta,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Konfirmasi & Pesan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, String value) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? NesaColors.terracotta : Colors.white,
          border: Border.all(
            color: isSelected ? NesaColors.terracotta : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
