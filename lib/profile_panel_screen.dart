import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final initials = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';
    final displayName = username.split('@').first;

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

            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayName, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              username, 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            Divider(),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profil Saya'),
              onTap: () {
                context.go('/my-profile', extra: username);
                onClose();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan Akun'),
              onTap: () {
                onClose(); 
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat Pesanan'),
              onTap: () {
                onClose(); // Tutup panel
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
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