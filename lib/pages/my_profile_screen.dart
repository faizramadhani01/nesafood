import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyProfileScreen extends StatelessWidget {
  final String username; 

  const MyProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final initials = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';
    final displayName = username.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF7F5F3),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  initials, // Tampilkan inisial
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName, // Tampilkan nama pengguna
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.email_outlined, color: Colors.grey.shade700),
                        title: Text('Email', style: GoogleFonts.poppins()),
                        subtitle: Text(
                          username, // Tampilkan email lengkap
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.phone_outlined, color: Colors.grey.shade700),
                        title: Text('Nomor Telepon', style: GoogleFonts.poppins()),
                        subtitle: Text(
                          '+62 812 3456 7890', // Data contoh
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Tambahkan logika untuk edit profil
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text('Edit Profil', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}