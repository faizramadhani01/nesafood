import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'detail_menu_screen.dart';
import '../model/menu.dart';
import '../theme.dart';
import '../services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> counts;
  final Map<String, Menu> menuMap;

  const CartScreen({super.key, required this.counts, required this.menuMap});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<String, int> localCounts;
  late Map<String, Menu> localMenuMap;

  @override
  void initState() {
    super.initState();
    localCounts = Map<String, int>.from(widget.counts);
    localMenuMap = Map<String, Menu>.from(widget.menuMap);
  }

  void _update(String name, int newCount) {
    setState(() {
      if (newCount <= 0) {
        localCounts.remove(name);
        localMenuMap.remove(name);
      } else {
        localCounts[name] = newCount;
      }
    });
  }

  double get totalPrice {
    double sum = 0;
    localCounts.forEach((name, qty) {
      final menu = localMenuMap[name];
      if (menu != null) sum += menu.price * qty;
    });
    return sum;
  }

  Future<Uint8List> _loadAssetBytes(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<void> _printReceipt() async {
    if (localCounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Keranjang kosong — tidak ada yang dicetak',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    final pdf = pw.Document();
    final logoData = await _loadAssetBytes('assets/logo.png');
    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nesa Food',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Kantin Baseball UNESA5',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Jl. Maospati - Bar. No.358-360, Kleco, Maospati',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
                pw.Container(
                  width: 64,
                  height: 64,
                  child: pw.Image(pw.MemoryImage(logoData)),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                'Struk Pesanan',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text('Tanggal: $date', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['No', 'Item', 'Qty', 'Harga', 'Subtotal'],
              data: List<List<String>>.generate(localCounts.length, (i) {
                final name = localCounts.keys.elementAt(i);
                final qty = localCounts[name]!;
                final menu = localMenuMap[name];
                final price = menu?.price ?? 0;
                final sub = price * qty;
                return [
                  '${i + 1}',
                  name,
                  '$qty',
                  'Rp${price.toStringAsFixed(0)}',
                  'Rp${sub.toStringAsFixed(0)}',
                ];
              }),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: pw.FixedColumnWidth(24),
                1: pw.FlexColumnWidth(4),
                2: pw.FixedColumnWidth(36),
                3: pw.FixedColumnWidth(72),
                4: pw.FixedColumnWidth(80),
              },
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total: Rp${totalPrice.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Terima kasih telah memesan di Nesa Food',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 6),
            pw.Text(
              'Nesa Food • Kantin Baseball UNESA5',
              style: pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              'Jl. Maospati - Bar. No.358-360, Kleco, Maospati, Kabupaten Magetan, Jawa Timur 63392',
              style: pw.TextStyle(fontSize: 8),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _confirmCheckout() async {
    if (localCounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang kosong', style: GoogleFonts.poppins()),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Pesanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah pesanan Anda sudah benar? Keranjang akan dikosongkan setelah checkout.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cek Lagi',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: NesaColors.terracotta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Checkout',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      // TODO: Integrasi backend pesanan di sini
      setState(() {
        localCounts.clear();
        localMenuMap.clear();
      });
      Navigator.pop(context, localCounts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan berhasil dibuat!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Keranjang Kosong',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Perut lapar? Yuk cari makanan enak di Menu sekarang!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // FIX: Card Item yang aman dari Overflow (Zebra Cross)
  Widget _cartItemCard(String name, int qty, Menu? menu) {
    final price = menu?.price ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align top
          children: [
            // 1. Gambar Menu
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 80,
                width: 80,
                child: menu != null
                    ? Image.asset(
                        menu.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      )
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Detail Menu (Expanded agar tidak overflow)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Menu
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      // Tombol Hapus (Dipindah ke atas agar rapi)
                      InkWell(
                        onTap: () => _update(name, 0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: NesaColors.terracotta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Baris Kontrol (Quantity + Info)
                  // Menggunakan Wrap atau Row dengan Spacer agar aman di layar kecil
                  Row(
                    children: [
                      // Quantity Control Compact
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _qtyButton(
                              Icons.remove,
                              () => _update(name, qty - 1),
                            ),
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text(
                                '$qty',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _qtyButton(
                              Icons.add,
                              () => _update(name, qty + 1),
                              isAdd: true,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Detail Button (Lebih kecil / Icon saja)
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailMenuScreen(
                              menu: menu ?? Menu.placeholder(),
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              Text(
                                'Detail',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper tombol kecil +/-
  Widget _qtyButton(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 14,
          color: isAdd ? Colors.green : Colors.black54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: AppBar(
        title: Text(
          'Keranjang Saya',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: NesaColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context, localCounts),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: localCounts.isEmpty
                ? _emptyView()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: localCounts.length,
                    itemBuilder: (context, i) {
                      final name = localCounts.keys.elementAt(i);
                      final qty = localCounts[name]!;
                      final menu = localMenuMap[name];
                      return _cartItemCard(name, qty, menu);
                    },
                  ),
          ),

          // Bottom Action Bar (Checkout)
          if (localCounts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Rp${totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Tombol Print Struk
                        OutlinedButton(
                          onPressed: _printReceipt,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: NesaColors.terracotta,
                            ),
                          ),
                          child: const Icon(
                            Icons.print,
                            color: NesaColors.terracotta,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Checkout
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NesaColors.terracotta,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Pesan Sekarang',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
