import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- 1. IMPORT DITAMBAHKAN

class ProfilePanel extends StatelessWidget {
  final String username;
  final VoidCallback onClose;

  const ProfilePanel({
    required this.username,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      color: Colors.transparent,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Foto profil
            CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage(
                'assets/profile.png',
              ), // Ganti sesuai asset
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 18),
            Divider(),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profil Saya'),
              onTap: () {
                // 2. BAGIAN INI DIUBAH
                // Tutup panel
                onClose();
                // Navigasi ke halaman detail profil baru
                context.go('/my-profile', extra: username);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan Akun'),
              onTap: () {
                onClose(); // Tutup panel
                // Tambahkan navigasi pengaturan jika ada
                // context.go('/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat Pesanan'),
              onTap: () {
                onClose(); // Tutup panel
                // Tambahkan navigasi riwayat jika ada
                // context.go('/order-history');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // 3. MENGGUNAKAN GO_ROUTER UNTUK LOGOUT
                context.go('/login');
              },
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Tutup',
            ),
          ],
        ),
      ),
    );
  }
}
