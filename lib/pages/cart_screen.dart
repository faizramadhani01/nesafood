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
        title: Text(
          'Konfirmasi Checkout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Lanjutkan checkout dan kosongkan keranjang?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: NesaColors.terracotta,
            ),
            child: Text('Checkout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        localCounts.clear();
        localMenuMap.clear();
      });
      Navigator.pop(context, localCounts);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout berhasil (demo)',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  Future<void> saveOrder(
    String userId,
    double totalPrice,
    List<Map<String, dynamic>> items,
  ) async {
    final firestoreService = FirestoreService();
    await firestoreService.addOrder({
      'userId': userId,
      'totalPrice': totalPrice,
      'items': items,
      'orderDate': DateTime.now().toIso8601String(),
    });
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Keranjang kosong',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan menu dari halaman Menu untuk memulai pesanan.',
            style: GoogleFonts.poppins(color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _cartItemCard(String name, int qty, Menu? menu) {
    final price = menu?.price ?? 0;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 80,
                width: 80,
                child: menu != null
                    ? Image.asset(
                        menu.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood),
                        ),
                      )
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp${price.toStringAsFixed(0)} · x $qty',
                    style: GoogleFonts.poppins(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _update(name, qty - 1),
                              icon: Icon(Icons.remove, size: 20),
                            ),
                            Text(
                              '$qty',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _update(name, qty + 1),
                              icon: Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailMenuScreen(
                              menu: menu ?? Menu.placeholder(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: Text('Details', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp${(price * qty).toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                IconButton(
                  onPressed: () => _update(name, 0),
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keranjang',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, localCounts);
            },
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(color: Colors.black87),
            ),
          ),
        ],
      ),
      backgroundColor: NesaColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: localCounts.isEmpty
            ? _emptyView()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: localCounts.length,
                      itemBuilder: (context, i) {
                        final name = localCounts.keys.elementAt(i);
                        final qty = localCounts[name]!;
                        final menu = localMenuMap[name];
                        return _cartItemCard(name, qty, menu);
                      },
                    ),
                  ),

                  // summary + actions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp${totalPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _printReceipt,
                          icon: const Icon(Icons.print_outlined),
                          label: Text(
                            'Checkout',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NesaColors.terracotta,
                            side: BorderSide(color: NesaColors.terracotta),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _confirmCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NesaColors.terracotta,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Checkout',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
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
}

// Note: Menu.placeholder() used above — add this helper if not present in model/menu.dart:
// factory Menu.placeholder() => Menu(name: 'Unknown', price: 0, image: 'assets/placeholder.png', description: '');
