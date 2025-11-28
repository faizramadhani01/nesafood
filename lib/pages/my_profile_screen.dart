import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Ambil user yang sedang login saat ini
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();

  // Controller untuk Form Input
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  String? _photoUrl;
  bool _isLoading = true;
  bool _isEditing = false; // Mode edit (aktif/mati)

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Ambil data terbaru dari Firestore
  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      final doc = await _authService.getUserData(user!.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _nameCtrl.text = data['nama'] ?? user!.displayName ?? '';
            _phoneCtrl.text = data['phone'] ?? '';
            _photoUrl = data['photoUrl'] ?? user!.photoURL;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error fetching user data: $e");
    }
  }

  // Fungsi Pilih Gambar & Upload
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    // Buka galeri
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        // Upload ke Firebase Storage via AuthService
        final url = await _authService.uploadProfileImage(
          user!.uid,
          File(pickedFile.path),
        );

        if (mounted) {
          setState(() {
            _photoUrl = url; // Update tampilan foto langsung
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
        }
      }
    }
  }

  // Fungsi Simpan Perubahan Teks
  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      await _authService.updateUserProfile(
        user!.uid,
        _nameCtrl.text.trim(),
        _phoneCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditing = false; // Keluar dari mode edit
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inisial nama untuk avatar jika foto kosong
    final initials = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text.substring(0, 1).toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Tombol Ganti Mode Edit / Simpan
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profil',
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: NesaColors.terracotta),
              onPressed: _saveProfile,
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NesaColors.terracotta),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // --- BAGIAN FOTO PROFIL ---
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _photoUrl != null
                                ? NetworkImage(_photoUrl!)
                                : null,
                            child: _photoUrl == null
                                ? Text(
                                    initials,
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          // Ikon Kamera (Hanya muncul saat mode edit)
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickAndUploadImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: NesaColors.terracotta,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- FORM DATA ---
                      _buildTextField(
                        label: 'Nama Lengkap',
                        controller: _nameCtrl,
                        enabled: _isEditing,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Nomor Telepon',
                        controller: _phoneCtrl,
                        enabled: _isEditing,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      // Email Read Only (Tidak bisa diedit)
                      _buildTextField(
                        label: 'Email',
                        controller: TextEditingController(text: user?.email),
                        enabled: false,
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 32),

                      // Tombol Logout (Opsional jika ingin ditaruh di sini juga)
                      if (!_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _authService.signOut();
                              // Navigasi handled by main stream or go router refresh
                              // context.go('/login');
                            },
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: Text(
                              'Keluar',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Widget Helper TextField
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(
          icon,
          color: enabled ? NesaColors.terracotta : Colors.grey,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NesaColors.terracotta),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
