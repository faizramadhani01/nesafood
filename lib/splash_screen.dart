import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// --- Halaman Splash Screen ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo di tengah
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: 27.w,
                height: 27.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 4.h),
            // Lingkaran loading hitam
            const CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 4,
            ),
            const Spacer(),
            // Nama pembuat di bawah
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Text(
                'Kelompok 3',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
