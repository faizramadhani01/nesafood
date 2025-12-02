import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User googleUser; // Data dari Google

  const CompleteProfileScreen({super.key, required this.googleUser});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  bool _isLoading = false;
  bool _obscure = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Isi otomatis data dari Google
    _nameCtrl = TextEditingController(
      text: widget.googleUser.displayName ?? '',
    );
    _emailCtrl = TextEditingController(text: widget.googleUser.email ?? '');
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleFinalize() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Panggil fungsi khusus Finalisasi
      await _authService.finalizeRegistration(
        uid: widget.googleUser.uid,
        email: _emailCtrl.text,
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        password: _passwordCtrl.text,
        photoUrl: widget.googleUser.photoURL,
      );

      // Sukses -> Masuk Home
      if (mounted) {
        context.go('/home', extra: _nameCtrl.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NesaColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: widget.googleUser.photoURL != null
                        ? NetworkImage(widget.googleUser.photoURL!)
                        : null,
                    child: widget.googleUser.photoURL == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Lengkapi Data",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Satu langkah lagi untuk masuk!",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    label: "Nama Lengkap",
                    controller: _nameCtrl,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Email Read Only
                  _buildTextField(
                    label: "Email (Terkunci)",
                    controller: _emailCtrl,
                    icon: Icons.email,
                    readOnly: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: "Nomor WhatsApp",
                    controller: _phoneCtrl,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: "Buat Password Login",
                    controller: _passwordCtrl,
                    icon: Icons.lock,
                    isPassword: true,
                    validator: (v) =>
                        (v != null && v.length < 6) ? "Min 6 karakter" : null,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleFinalize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NesaColors.terracotta,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "SIMPAN & MASUK",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    Color? fillColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscure,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor ?? Colors.grey.shade50,
        prefixIcon: Icon(icon, color: NesaColors.terracotta),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
