import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- IMPORT SERVICE NOTIFIKASI (BARU) ---
import 'services/notification_service.dart';

// Pages
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signin_screen.dart'; // Register Manual
import 'pages/complete_profile_screen.dart'; // Register Google (Lengkapi Data)
import 'pages/home_screen.dart';
import 'pages/detail_menu_screen.dart';
import 'pages/cart_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/order_history_screen.dart';
import 'profile_panel_screen.dart';
import 'pages/my_profile_screen.dart';
import 'admin/dashboard_admin_screen.dart';

// Models
import 'model/menu.dart';
import 'model/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  if (kIsWeb) {
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
    await Firebase.initializeApp();
  }

  // --- INISIALISASI NOTIFIKASI (BARU) ---
  // Wajib dipanggil di sini agar channel terbentuk dan izin diminta saat aplikasi mulai
  await NotificationService().init();

  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          routerConfig: _router,
          title: 'Nesafood',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
        );
      },
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. Splash Screen
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // 2. Login Screen
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // 3. Register Manual
    GoRoute(path: '/signin', builder: (context, state) => const SignUpScreen()),

    // 4. Register Google (Lengkapi Data)
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) {
        final googleUser = state.extra as User;
        return CompleteProfileScreen(googleUser: googleUser);
      },
    ),

    // 5. Home Screen
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final username = state.extra as String?;
        return HomeScreen(username: username);
      },
    ),

    // 6. Detail Menu
    GoRoute(
      path: '/detail/:menuId',
      builder: (context, state) {
        final menu = state.extra as Menu?;
        return DetailMenuScreen(menu: menu ?? Menu.placeholder());
      },
    ),

    // 7. Cart (Keranjang)
    GoRoute(
      path: '/cart',
      builder: (context, state) {
        // Default kosong jika diakses langsung
        return const CartScreen(
          counts: {},
          menuMap: {},
          kantinId: '', 
        );
      },
    ),

    // 8. Profile Panel
    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          ProfilePanel(username: 'User', onClose: () {}),
    ),

    // 9. My Profile
    GoRoute(
      path: '/my-profile',
      builder: (context, state) {
        return const MyProfileScreen();
      },
    ),

    // 10. Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        final username = state.extra as String? ?? 'User';
        return SettingsScreen(username: username);
      },
    ),

    // 11. Riwayat Pesanan
    GoRoute(
      path: '/order-history',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is List<Order>) {
          return OrderHistoryScreen(username: 'Guest', initialOrders: extra);
        }
        final username = extra as String? ?? 'Guest';
        return OrderHistoryScreen(username: username);
      },
    ),

    // 12. Admin Dashboard
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) {
        final kantinId = state.extra as String? ?? '';
        return DashboardAdminScreen(kantinId: kantinId);
      },
    ),
  ],
);