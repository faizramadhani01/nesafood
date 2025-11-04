import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/menu.dart';
import '../theme.dart';

class DetailMenuScreen extends StatelessWidget {
  final Menu menu;
  const DetailMenuScreen({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    const terracotta = NesaColors.terracotta;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          menu.name,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 220,
                    child: Image.asset(
                      menu.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, size: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    menu.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp${menu.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: terracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    menu.description,
                    style: GoogleFonts.poppins(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                        child: Text('Back', style: GoogleFonts.poppins()),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: terracotta,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          'Lakukan Pemesanan',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
