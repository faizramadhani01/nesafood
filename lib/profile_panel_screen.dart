import 'package:flutter/material.dart';
import 'login_screen.dart';

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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan Akun'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat Pesanan'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Logout: contoh kembali ke login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
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
