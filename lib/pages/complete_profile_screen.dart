import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 5.w), // Gunakan Sizer
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
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
                        ? Icon(Icons.person, size: 40.sp) // Gunakan Sizer
                        : null,
                  ),
                  SizedBox(height: 2.h), // Gunakan Sizer
                  Text(
                    "Lengkapi Data",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp, // Gunakan Sizer
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h), // Gunakan Sizer
                  Text(
                    "Satu langkah lagi untuk masuk!",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp, // Gunakan Sizer
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 3.h), // Gunakan Sizer

                  _buildTextField(
                    label: "Nama Lengkap",
                    controller: _nameCtrl,
                    icon: Icons.person,
                  ),
                  SizedBox(height: 2.h), // Gunakan Sizer
                  // Email Read Only
                  _buildTextField(
                    label: "Email (Terkunci)",
                    controller: _emailCtrl,
                    icon: Icons.email,
                    readOnly: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  SizedBox(height: 2.h), // Gunakan Sizer

                  _buildTextField(
                    label: "Nomor WhatsApp",
                    controller: _phoneCtrl,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Wajib diisi" : null,
                  ),
                  SizedBox(height: 2.h), // Gunakan Sizer

                  _buildTextField(
                    label: "Buat Password Login",
                    controller: _passwordCtrl,
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  SizedBox(height: 3.h), // Gunakan Sizer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleFinalize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NesaColors.terracotta,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                      child: Text(
                        "Simpan",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp, // Gunakan Sizer
                          fontWeight: FontWeight.bold,
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
