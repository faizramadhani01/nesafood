import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Controller untuk animasi durasi 1.5 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. Animasi Opacity (Muncul perlahan)
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 3. Animasi Slide (Naik sedikit ke atas agar dinamis)
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.1), // Mulai sedikit dari bawah
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve:
                Curves.easeOutQuart, // Gerakan melambat di akhir (sangat halus)
          ),
        );

    // Jalankan animasi
    _controller.forward();

    // Timer pindah halaman
    _timer = Timer(const Duration(seconds: 3), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ukuran responsif yang proporsional
    double logoSize = 30.w; // Ukuran logo responsif
    double loadingSize = 20.w; // Ukuran animasi loading responsif

    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      body: SafeArea(
        child: Stack(
          children: [
            // --- BAGIAN TENGAH (LOGO & LOADING) ---
            Center(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/logo.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: 4.h), // Jarak yang pas
                        // Loading Animation (Kecil & Minimalis)
                        SizedBox(
                          width: loadingSize,
                          height: loadingSize,
                          child: Lottie.asset(
                            'assets/loading_animation.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- BAGIAN BAWAH (FOOTER) ---
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Created by',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10.sp, // Responsif
                          color: Colors.grey[400],
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Kelompok 3',
                        style: TextStyle(
                          fontSize: 12.sp, // Responsif
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
