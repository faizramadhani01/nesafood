import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'cubit/login_cubit.dart';
import 'theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi berhasil! Silakan login.'),
              ),
            );
            context.go('/login'); // Kembali ke login
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          const terracotta = NesaColors.terracotta;
          final isMobile = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/image.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Colors.grey),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.9
                          : 500,
                      margin: EdgeInsets.all(2.w),
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 5.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(3.w),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 1.6.h),
                              Text(
                                'Register to start ordering',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 2.h),

                              // Name
                              TextFormField(
                                controller: _nameCtrl,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Full name',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.06),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Nama wajib diisi'
                                    : null,
                              ),
                              SizedBox(height: 1.5.h),

                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.06),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.white70,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Email wajib diisi';
                                  final emailRe = RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  );
                                  if (!emailRe.hasMatch(v.trim()))
                                    return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                              SizedBox(height: 1.5.h),

                              // Password
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.06),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.white70,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password wajib diisi';
                                  if (v.length < 6) return 'Minimal 6 karakter';
                                  return null;
                                },
                              ),
                              SizedBox(height: 1.5.h),

                              // Confirm
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscure,
                                style: const TextStyle(color: Colors.white),
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: 'Confirm password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.06),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.white70,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Konfirmasi password wajib';
                                  if (v != _passwordCtrl.text)
                                    return 'Password tidak cocok';
                                  return null;
                                },
                              ),
                              SizedBox(height: 2.h),

                              // Sign Up button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          context.read<LoginCubit>().register(
                                            _emailCtrl.text,
                                            _passwordCtrl.text,
                                            _nameCtrl
                                                .text, // <-- kirim nama ke register
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: terracotta,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2.h,
                                    ),
                                  ),
                                  child: state.isLoading
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          'SIGN UP',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: Text(
                                      'Already have an account?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Image.asset(
                                          'assets/google.png',
                                          width: 4.w,
                                          height: 6.w,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.error,
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Image.asset(
                                          'assets/facebook.png',
                                          width: 4.w,
                                          height: 6.w,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.error,
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
}
