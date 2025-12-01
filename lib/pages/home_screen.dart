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

// Import Halaman Baru
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
  int selectedIndex = 0;
  Kantin? activeKantin;
  bool showProfilePanel = false;
  late String displayUsername;
  final AuthService _authService = AuthService();

  // Data Cart
  final Map<String, int> itemCounts = {};
  final Map<String, Menu> cartItems = {};

  // --- VARIABEL PENTING: ID Kantin Pemilik Keranjang ---
  String? currentCartKantinId;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    displayUsername = widget.username ?? 'Guest';
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
        // Ignore error
      }
    }
  }

  // --- LOGIKA KERANJANG (DENGAN PENGECEKAN KANTIN) ---
  int get cartTotalCount => itemCounts.values.fold(0, (a, b) => a + b);

  // Fungsi Add Menu yang Cerdas: Menerima ID Kantin
  void _addMenuToCart(Menu m, String originKantinId) {
    setState(() {
      // 1. Jika keranjang masih kosong, tetapkan kantin ini sebagai pemilik
      if (itemCounts.isEmpty) {
        currentCartKantinId = originKantinId;
      }

      // 2. Cek Konflik: Apakah user belanja di kantin yang berbeda?
      if (currentCartKantinId != null &&
          currentCartKantinId != originKantinId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selesaikan pesanan di kantin sebelumnya dulu!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return; // Batalkan, jangan dimasukkan ke cart
      }

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

        // Jika keranjang jadi kosong, reset ID agar bisa belanja di kantin lain
        if (itemCounts.isEmpty) {
          currentCartKantinId = null;
        }
      } else {
        itemCounts[m.name] = v;
      }
    });
  }

  // Buka Cart dengan membawa ID Kantin
  void _openCart() {
    Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          counts: itemCounts,
          menuMap: cartItems,
          username: displayUsername,
          // PENTING: Kirim ID Kantin ke CartScreen
          kantinId: currentCartKantinId ?? '1',
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          itemCounts
            ..clear()
            ..addAll(result);
          cartItems.removeWhere(
            (name, _) =>
                !(itemCounts.containsKey(name) && itemCounts[name]! > 0),
          );

          // Jika user mengosongkan cart di halaman cart
          if (itemCounts.isEmpty) {
            currentCartKantinId = null;
          }
        });
      }
    });
  }

  void handleMenuTap(int index) {
    setState(() {
      selectedIndex = index;
      activeKantin = null;
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: _buildMainContent(),
            ),
          ),
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

  Widget _buildMainContent() {
    if (searchQuery.isNotEmpty) {
      return Center(child: Text("Hasil pencarian: $searchQuery"));
    }

    switch (selectedIndex) {
      case 0: // HOME
        if (activeKantin != null) {
          return CanteenMenuPage(
            kantin: activeKantin!,
            onBack: () => setState(() => activeKantin = null),
            // Kirim ID Kantin Aktif ('1', '2', dll) ke fungsi add cart
            onAddCart: (m) => _addMenuToCart(m, activeKantin!.id),
            onRemoveCart: _removeOneFromCart,
            itemCounts: itemCounts,
          );
        }
        return LandingPage(
          username: displayUsername,
          onSeeAllKantin: () => setState(() => selectedIndex = 1),
          // Menu di Landing Page kita anggap masuk Kantin 1 (Default)
          onAddCart: (m) => _addMenuToCart(m, '1'),
          onRemoveCart: _removeOneFromCart,
          itemCounts: itemCounts,
          onSelectKantin: (k) => setState(() => activeKantin = k),
        );

      case 1: // MENU LIST
        if (activeKantin != null) {
          return CanteenMenuPage(
            kantin: activeKantin!,
            onBack: () => setState(() => activeKantin = null),
            onAddCart: (m) => _addMenuToCart(m, activeKantin!.id),
            onRemoveCart: _removeOneFromCart,
            itemCounts: itemCounts,
          );
        }
        return CanteenListPage(
          onKantinTap: (k) => setState(() => activeKantin = k),
          onBack: () => setState(() => selectedIndex = 0),
        );

      case 2: // ABOUT
        return const AboutPage();

      default:
        return const SizedBox.shrink();
    }
  }
}
