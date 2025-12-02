import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/menu.dart';
import '../theme.dart';

class DetailMenuScreen extends StatelessWidget {
  final Menu menu;
  final Function(Menu) onAddCart;

  const DetailMenuScreen({
    super.key,
    required this.menu,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          menu.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Menu
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                menu.image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(height: 16),

            // Nama Menu
            Text(
              menu.name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Harga Menu
            Text(
              'Rp${menu.price.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: NesaColors.terracotta,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi Menu
            Text(
              menu.description ?? 'Tidak ada deskripsi.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // Tombol Tambahkan ke Keranjang
            ElevatedButton(
              onPressed: () => onAddCart(menu),
              style: ElevatedButton.styleFrom(
                backgroundColor: NesaColors.terracotta,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tambahkan ke Keranjang',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
