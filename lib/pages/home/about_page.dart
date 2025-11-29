import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 80,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.fastfood, size: 80, color: NesaColors.terracotta),
          ),
          const SizedBox(height: 20),
          Text(
            'Nesa Food',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'v1.0.0',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tentang Kami',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aplikasi pemesanan makanan kantin modern untuk memudahkan mahasiswa.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: NesaColors.terracottaLight,
                    child: Icon(Icons.code, color: NesaColors.terracotta),
                  ),
                  title: Text(
                    'Developer',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Mahasiswa UNESA',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}