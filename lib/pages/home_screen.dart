import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../model/menu.dart';
import '../model/kantin_data.dart';
import 'headbar_screen.dart';
import '../profile_panel_screen.dart';
import 'cart_screen.dart';
import '../theme.dart';
import '../services/auth_service.dart';

// Import Halaman Baru (Modular Pages)
import 'home/landing_page.dart';
import 'home/canteen_list_page.dart';
import 'home/canteen_menu_page.dart';
import 'home/about_page.dart';

class HomeScreen extends StatefulWidget {
  final String? username;
  const HomeScreen({super.key, this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation State
  int selectedIndex = 0;
  Kantin? activeKantin; // Jika null = Landing/List, Jika isi = Menu Page
  bool showProfilePanel = false;

  // Data User
  late String displayUsername;
  final AuthService _authService = AuthService();

  // Data Cart (Lokal State untuk interaksi real-time di UI)
  final Map<String, int> itemCounts = {};
  final Map<String, Menu> cartItems = {};

  // Search
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Set nama awal (bisa dari parameter atau Guest)
    displayUsername = widget.username ?? 'Guest';

    // Ambil nama asli dari Firestore
    _fetchRealUserName();
  }

  Future<void> _fetchRealUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await _authService.getUserData(user.uid);
        if (doc.exists && mounted) {
          setState(() {
            final data = doc.data() as Map<String, dynamic>;
            displayUsername = data['nama'] ?? displayUsername;
          });
        }
      } catch (e) {
        // Ignore error, pakai nama default
      }
    }
  }

  // --- LOGIKA CART (Add/Remove) ---
  int get cartTotalCount => itemCounts.values.fold(0, (a, b) => a + b);

  void _addMenuToCart(Menu m) {
    setState(() {
      itemCounts[m.name] = (itemCounts[m.name] ?? 0) + 1;
      cartItems[m.name] = m;
    });
  }

  void _removeOneFromCart(Menu m) {
    setState(() {
      final v = (itemCounts[m.name] ?? 1) - 1;
      if (v <= 0) {
        itemCounts.remove(m.name);
        cartItems.remove(m.name);
      } else {
        itemCounts[m.name] = v;
      }
    });
  }

  // --- BUKA HALAMAN KERANJANG ---
  void _openCart() {
    // Navigasi ke Cart Screen dan tunggu hasil kembalian (sync jumlah item)
    Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          counts: itemCounts,
          menuMap: cartItems,
          username: displayUsername, // Kirim nama user untuk data order
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          itemCounts
            ..clear()
            ..addAll(result);
          // Bersihkan item yang jumlahnya 0
          cartItems.removeWhere(
            (name, _) =>
                !(itemCounts.containsKey(name) && itemCounts[name]! > 0),
          );
        });
      }
    });
  }

  // --- LOGIKA NAVIGASI HEADBAR ---
  void handleMenuTap(int index) {
    setState(() {
      selectedIndex = index;
      activeKantin = null; // Reset kantin saat pindah tab utama
      showProfilePanel = false;
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: HeadBar(
        title: 'Nesa Food',
        selectedIndex: selectedIndex,
        onMenuTap: handleMenuTap,
        onProfileTap: () =>
            setState(() => showProfilePanel = !showProfilePanel),
        onSearch: (q) => setState(() => searchQuery = q),
        searchQuery: searchQuery,
        cartCount: cartTotalCount,
        onCartTap: _openCart,
      ),
      body: Stack(
        children: [
          // Content Utama (Tengah)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: _buildMainContent(),
            ),
          ),

          // Profile Overlay (Muncul di atas konten)
          if (showProfilePanel)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              right: 24,
              child: ProfilePanel(
                username: displayUsername,
                onClose: () => setState(() => showProfilePanel = false),
              ),
            ),
        ],
      ),
    );
  }

  // --- SWITCHER HALAMAN (INTI MODULAR) ---
  Widget _buildMainContent() {
    // 1. Jika sedang mencari
    if (searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Hasil pencarian: $searchQuery",
              style: const TextStyle(color: Colors.grey),
            ),
            const Text(
              "(Fitur Search belum dipisah ke modul tersendiri)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    switch (selectedIndex) {
      case 0: // TAB HOME
        // A. Jika user sedang lihat detail menu kantin (dari klik Hero Banner)
        if (activeKantin != null) {
          return CanteenMenuPage(
            kantin: activeKantin!,
            onBack: () =>
                setState(() => activeKantin = null), // Back ke Landing
            onAddCart: _addMenuToCart,
            onRemoveCart: _removeOneFromCart,
            itemCounts: itemCounts,
          );
        }
        // B. Default: Landing Page (Dashboard)
        return LandingPage(
          username: displayUsername,
          onSeeAllKantin: () =>
              setState(() => selectedIndex = 1), // Pindah ke Tab Menu
          onAddCart: _addMenuToCart,
          onRemoveCart: _removeOneFromCart,
          itemCounts: itemCounts,
          onSelectKantin: (k) =>
              setState(() => activeKantin = k), // Masuk detail kantin
        );

      case 1: // TAB MENU (DAFTAR KANTIN)
        // A. Jika sedang lihat detail kantin
        if (activeKantin != null) {
          return CanteenMenuPage(
            kantin: activeKantin!,
            onBack: () =>
                setState(() => activeKantin = null), // Back ke List Kantin
            onAddCart: _addMenuToCart,
            onRemoveCart: _removeOneFromCart,
            itemCounts: itemCounts,
          );
        }
        // B. Default: List Semua Kantin
        return CanteenListPage(
          onKantinTap: (k) => setState(() => activeKantin = k),
          onBack: () => setState(() => selectedIndex = 0), // Back ke Home
        );

      case 2: // TAB ABOUT
        return const AboutPage();

      default:
        return const SizedBox.shrink();
    }
  }
}
