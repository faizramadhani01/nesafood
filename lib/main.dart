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
import 'profile_panel_screen.dart';
import 'model/menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(title: 'Nesafood', routerConfig: _router);
      },
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signin', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
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
  ],
);
