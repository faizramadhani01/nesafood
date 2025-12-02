import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'cubit/login_cubit.dart';
import 'theme.dart';

enum LoginType { user, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginType _loginType = LoginType.user;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          // 1. JIKA LOGIN SUKSES (User Lama)
          if (state.isSuccess) {
            String user = emailController.text.trim();

            // FIX: Jika login via Google, text controller kosong.
            // Beri nama placeholder agar HomeScreen tidak crash saat ambil inisial.
            // Nanti di Home, nama asli akan diambil ulang dari database.
            if (user.isEmpty) {
              user = "Google User";
            }

            context.go('/home', extra: user);
          }

          // 2. JIKA USER BARU GOOGLE (Belum Lengkap Data)
          if (state.isNewUser) {
            // Arahkan ke layar khusus pelengkapan data
            // Bawa object User Google sebagai parameter extra
            context.go('/complete-profile', extra: state.googleUser);
          }

          // 3. JIKA ADMIN SUKSES
          if (state.isAdminSuccess) {
            context.go('/admin-dashboard', extra: state.kantinId);
          }

          // 4. JIKA ERROR
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!, style: GoogleFonts.poppins()),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: NesaColors.background,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.asset(
                  'assets/image.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                ),

                // Login Card
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: 100.w > 600 ? 420 : 90.w, // Responsif
                      padding: EdgeInsets.symmetric(
                        vertical: 5.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Toggle User/Admin
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _buildToggleButton('User', LoginType.user),
                                _buildToggleButton('Admin', LoginType.admin),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Input Fields
                          _buildTextField(
                            controller: emailController,
                            hint: 'Email Address',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Tambahkan logika reset password di sini jika diperlukan
                              },
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      if (_loginType == LoginType.user) {
                                        context.read<LoginCubit>().login(
                                          emailController.text,
                                          passwordController.text,
                                        );
                                      } else {
                                        context.read<LoginCubit>().loginAdmin(
                                          emailController.text,
                                          passwordController.text,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NesaColors.terracotta,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'LOGIN',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          // Social Login Section
                          if (_loginType == LoginType.user) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Colors.white38),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'OR LOGIN WITH',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Colors.white38),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialButton(
                                  'assets/google.png',
                                  onTap: () {
                                    // Trigger Login Google
                                    context.read<LoginCubit>().loginGoogle();
                                  },
                                ),
                                const SizedBox(width: 24),
                                _socialButton(
                                  'assets/facebook.png',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Fitur Facebook segera hadir!",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 20),
                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors
                                    .click, // Mengubah kursor menjadi tangan
                                child: GestureDetector(
                                  onTap: () => context.go('/signin'),
                                  child: Text(
                                    'Daftar',
                                    style: GoogleFonts.poppins(
                                      color: NesaColors.terracotta,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleButton(String label, LoginType type) {
    final isSelected = _loginType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _loginType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? NesaColors.terracotta : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => showPassword = !showPassword),
              )
            : null,
      ),
    );
  }

  Widget _socialButton(String assetPath, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Image.asset(
          assetPath,
          height: 24,
          width: 24,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.link, size: 24, color: Colors.grey),
        ),
      ),
    );
  }
}
