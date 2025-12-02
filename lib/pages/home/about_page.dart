import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // DATA ANGGOTA KELOMPOK 3 (Silakan Edit Nama & NIM)
  final List<Map<String, String>> members = const [
    {'name': 'Dicky Sanjaya', 'nim': '24111814045'},
    {'name': 'Farid Hanif F', 'nim': '24111814106'},
    {'name': 'Alfina Berlian ', 'nim': '24111814016'},
    {'name': 'Faiz Ramadhani', 'nim': '24111814121'},
    {'name': 'Farras Fadillah', 'nim': '24111814089'},
    {'name': 'Fandy Ahmad', 'nim': '24111814131'},
    {'name': 'Aditya Putra W', 'nim': '24111814126'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          // LOGO
          Image.asset(
            'assets/logo.png',
            height: 100,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.fastfood,
              size: 100,
              color: NesaColors.terracotta,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nesa Food',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: NesaColors.terracotta,
            ),
          ),
          Text('Versi 1.0.0', style: GoogleFonts.poppins(color: Colors.grey)),

          const SizedBox(height: 40),

          // DESKRIPSI NESAFOOD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                  'Tentang Nesa Food',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nesa Food adalah solusi digital untuk memesan makanan di lingkungan kampus UNESA. Aplikasi ini dirancang untuk memudahkan mahasiswa dan civitas akademika dalam menjelajahi menu, memesan makanan dari berbagai kantin tanpa antre, dan melakukan pembayaran secara praktis.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // DEVELOPER TEAM
          Text(
            'Meet the Team',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelompok 3 - Pemrograman Mobile',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: NesaColors.terracotta.withOpacity(0.1),
                      child: Text(
                        "${i + 1}",
                        style: GoogleFonts.poppins(
                          color: NesaColors.terracotta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            members[i]['name']!,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "NIM: ${members[i]['nim']}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 40),
          Text(
            "© 2025 Nesa Food Team",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
