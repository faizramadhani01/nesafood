// lib/main.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signin_screen.dart';
import 'pages/home_screen.dart';
import 'pages/detail_menu_screen.dart';
import 'pages/cart_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/order_history_screen.dart';
import 'profile_panel_screen.dart';
import 'model/menu.dart';
import 'model/order.dart';
import 'pages/my_profile_screen.dart';
import 'admin/dashboard_admin_screen.dart'; // Pastikan import ini ada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Menggunakan konfigurasi yang Anda berikan
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCSXSyY0XjTRzGjuEhFsrbWaVdx6hCjQpA",
        authDomain: "nesafoodweb.firebaseapp.com",
        projectId: "nesafoodweb",
        storageBucket: "nesafoodweb.firebasestorage.app",
        messagingSenderId: "782804576113",
        appId: "1:782804576113:web:c18d18b36d21e5600578d0",
        measurementId: "G-DM35BD0T99",
      ),
    );
  } else {
    // Untuk platform lain (Android/iOS)
    await Firebase.initializeApp();
  }
  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          routerConfig: _router,
          title: 'Nesafood',
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signin', builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final username = state.extra as String?;
        return HomeScreen(username: username);
      },
    ),
    GoRoute(
      path: '/detail/:menuId',
      builder: (context, state) => DetailMenuScreen(
        menu: Menu.placeholder(),
      ), // Placeholder, perlu diubah
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(counts: {}, menuMap: {}),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          ProfilePanel(username: 'User', onClose: () {}), // Placeholder
    ),
    GoRoute(
      path: '/my-profile',
      builder: (context, state) {
        final username = state.extra as String? ?? 'Guest';
        return MyProfileScreen(username: username);
      },
    ),

    // 4. TAMBAHKAN RUTE UNTUK HALAMAN PENGATURAN AKUN
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        final username = state.extra as String? ?? 'Guest';
        return SettingsScreen(username: username);
      },
    ),

    // 5. TAMBAHKAN RUTE UNTUK HALAMAN RIWAYAT PESANAN
    GoRoute(
      path: '/order-history',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is List<Order>) {
          // If caller passed a List<Order>, show them in the history
          return OrderHistoryScreen(username: 'Guest', initialOrders: extra);
        }
        final username = extra as String? ?? 'Guest';
        return OrderHistoryScreen(username: username);
      },
    ),

    // Rute untuk Admin Dashboard
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) {
        // Ambil kantinId dari 'extra'
        final kantinId = state.extra as String? ?? '';
        return DashboardAdminScreen(kantinId: kantinId);
      },
    ),
  ],
);
