import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'theme.dart';

class ProfilePanel extends StatelessWidget {
  final String username;
  final VoidCallback onClose;

  const ProfilePanel({
    super.key,
    required this.username,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil inisial nama untuk avatar (default 'U' jika kosong)
    final initials = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'U';
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER PROFIL ---
          Row(
            children: [
              CircleAvatar(
                backgroundColor: NesaColors.terracottaLight,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? Text(
                        initials,
                        style: GoogleFonts.poppins(
                          color: NesaColors.terracotta,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      user?.email ?? 'Pengguna',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
              )
            ],
          ),
          const Divider(height: 24),

          // --- MENU ITEMS ---
          
          // 1. Profil Saya
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            text: 'Profil Saya',
            onTap: () {
              // Menutup panel dulu, baru pindah halaman
              onClose();
              context.push('/my-profile'); 
            },
          ),

          // 2. Riwayat Pesanan
          _buildMenuItem(
            context,
            icon: Icons.history,
            text: 'Riwayat Pesanan',
            onTap: () {
              onClose();
              // Kirim UID agar history bisa filter data milik user ini saja
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.push('/order-history', extra: uid);
            },
          ),

          // 3. Pengaturan
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            text: 'Pengaturan Akun',
            onTap: () {
              onClose();
              context.push('/settings', extra: username);
            },
          ),
          
          const Divider(height: 24),
          
          // 4. Logout
          _buildMenuItem(
            context,
            icon: Icons.logout,
            text: 'Keluar',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              // Proses Logout
              await AuthService().signOut();
              if (context.mounted) {
                onClose();
                // Kembali ke halaman Login dan hapus semua stack history sebelumnya
                context.go('/login'); 
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.black87),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}