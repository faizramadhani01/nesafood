import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- TAMBAHKAN IMPORT INI ---
import 'services/notification_service.dart';

// Pages
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signin_screen.dart';
import 'pages/complete_profile_screen.dart';
import 'pages/home_screen.dart';
import 'pages/detail_menu_screen.dart';
import 'pages/cart_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/order_history_screen.dart';
import 'profile_panel_screen.dart';
import 'pages/my_profile_screen.dart';
import 'admin/dashboard_admin_screen.dart';
import 'pages/privacy_policy_screen.dart';

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

  // --- WAJIB: Inisialisasi Notifikasi ---
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
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signin', builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) {
        final googleUser = state.extra as User;
        return CompleteProfileScreen(googleUser: googleUser);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final username = state.extra as String?;
        return HomeScreen(username: username);
      },
    ),
    GoRoute(
      path: '/detail/:menuId',
      builder: (context, state) {
        // Ambil data menu dari state.extra
        final menu = state.extra as Menu?;
        if (menu == null) {
          // Jika menu tidak ditemukan, tampilkan pesan error atau halaman kosong
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Menu')),
            body: const Center(child: Text('Menu tidak ditemukan.')),
          );
        }
        // Kirim data menu ke DetailMenuScreen
        return DetailMenuScreen(
          menu: menu,
          onAddCart: (menu) {
            // Tambahkan logika untuk menambahkan ke keranjang
          },
        );
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) {
        return const CartScreen(counts: {}, menuMap: {}, kantinId: '');
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          ProfilePanel(username: 'User', onClose: () {}),
    ),
    GoRoute(
      path: '/my-profile',
      builder: (context, state) {
        return const MyProfileScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        final username = state.extra as String? ?? 'User';
        return SettingsScreen(username: username);
      },
    ),
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
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) {
        final kantinId = state.extra as String? ?? '';
        return DashboardAdminScreen(kantinId: kantinId);
      },
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
