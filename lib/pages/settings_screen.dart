import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  const SettingsScreen({super.key, required this.username});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Preferensi'),
          _buildSwitchTile(
            'Notifikasi Pesanan',
            'Dapatkan update status pesanan',
            _notifEnabled,
            (v) => setState(() => _notifEnabled = v),
          ),
          _buildSwitchTile(
            'Mode Gelap',
            'Tampilan aplikasi gelap',
            _darkMode,
            (v) => setState(() => _darkMode = v),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Tentang'),
          _buildActionTile(
            Icons.info_outline,
            'Versi Aplikasi',
            '1.0.0',
            () {},
          ),
          _buildActionTile(
            Icons.privacy_tip_outlined,
            'Kebijakan Privasi',
            '',
            () {},
          ),
          _buildActionTile(Icons.help_outline, 'Bantuan & Support', '', () {}),

          const SizedBox(height: 24),
          _buildSectionHeader('Akun'),
          _buildActionTile(Icons.delete_forever, 'Hapus Akun', '', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur hapus akun permanen akan segera hadir.'),
              ),
            );
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: NesaColors.terracotta,
      ),
    ),
  );

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: NesaColors.terracotta,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
    ),
  );

  Widget _buildActionTile(
    IconData icon,
    String title,
    String trailing,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: trailing.isEmpty
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : Text(trailing, style: GoogleFonts.poppins(color: Colors.grey)),
    ),
  );
}
