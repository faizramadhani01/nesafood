import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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
    // Inisial untuk avatar
    final initials = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'U';

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
          // Header Profil Singkat
          Row(
            children: [
              CircleAvatar(
                backgroundColor: NesaColors.terracottaLight,
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    color: NesaColors.terracotta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      'Mahasiswa', // Bisa diganti role
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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

          // Menu Items
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            text: 'Profil Saya',
            onTap: () {
              // Gunakan PUSH agar ada tombol back otomatis
              context.push('/my-profile'); 
              onClose();
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            text: 'Riwayat Pesanan',
            onTap: () {
              context.push('/order-history', extra: username);
              onClose();
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            text: 'Pengaturan Akun',
            onTap: () {
              context.push('/settings');
              onClose();
            },
          ),
          
          const Divider(height: 24),
          
          _buildMenuItem(
            context,
            icon: Icons.logout,
            text: 'Keluar',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              // Logika Logout
              await AuthService().signOut();
              if (context.mounted) {
                context.go('/login'); // Go mengganti rute (tidak bisa back)
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