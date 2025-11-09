import 'package:flutter/material.dart';
// Import file splash_screen.dart yang baru
import 'splash_screen.dart';

// Fungsi utama yang menjalankan aplikasi
void main() => runApp(const MyApp());

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NESAFOOD',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      // Aplikasi dimulai dengan SplashScreen dari file terpisah
      home: const SplashScreen(),
    );
  }
}

// Catatan: Kelas SplashScreen dan HomeScreen kini berada di file terpisah.
