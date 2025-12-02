import 'dart:async'; // Tambahkan ini untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart'; // Tambahkan ini

// Import Model & Service
>>>>>>> ca9f5f6e97de9acbfacdeeb3535327dcfbefbc39
import '../model/menu.dart';
import '../model/kantin_data.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart'; // Pastikan import ini ada
import '../services/notification_service.dart'; // Import service notifikasi baru
import '../theme.dart';

// Import UI Components
import 'headbar_screen.dart';
import '../profile_panel_screen.dart';
import 'cart_screen.dart';

// Import Halaman Tab
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
  final FirestoreService _firestoreService = FirestoreService();

  // Data Cart
  final Map<String, int> itemCounts = {};
  final Map<String, Menu> cartItems = {};

  // --- VARIABEL PENTING: ID Kantin Pemilik Keranjang ---
  String? currentCartKantinId;

  String searchQuery = '';

  // --- VARIABEL NOTIFIKASI ---
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    displayUsername = widget.username ?? 'Guest';
    _fetchRealUserName();

    // 1. Inisialisasi Service Notifikasi
    _setupNotifications();

    // 2. Jalankan Listener Firestore untuk Notifikasi
    _listenToOrderUpdates();
  }

  @override
  void dispose() {
    // PENTING: Matikan listener saat halaman ditutup agar tidak memory leak
    _orderSubscription?.cancel();
    super.dispose();
  }

  // --- LOGIKA NOTIFIKASI ---
  Future<void> _setupNotifications() async {
    // Inisialisasi plugin notifikasi
    await NotificationService().init();

    // Minta izin notifikasi (Wajib untuk Android 13+)
    await Permission.notification.request();
  }

  void _listenToOrderUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Stream pesanan khusus user ini
    _orderSubscription = _firestoreService.getOrders(user.uid).listen((
      snapshot,
    ) {
      for (var change in snapshot.docChanges) {
        // Kita hanya bereaksi jika data di-UPDATE (Modified)
        // Kita abaikan 'added' agar tidak notifikasi spam saat baru buka aplikasi
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          final status = data['status'];

          // JIKA STATUS BERUBAH JADI 'READY'
          if (status == 'ready') {
            // Ambil nama menu untuk pesan notifikasi
            String menuName = 'Makanan kamu';
            final items = (data['items'] as List<dynamic>?) ?? [];

            if (items.isNotEmpty) {
              menuName = items[0]['menu_name'];
              if (items.length > 1) {
                menuName += " & ${items.length - 1} lainnya";
              }
            }

            // Panggil fungsi notifikasi suara & popup
            NotificationService().showOrderReadyNotification(
              change.doc.id,
              menuName,
            );
          }
        }
      }
    });
  }

  // --- LOGIKA USERNAME ---
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

  // --- LOGIKA KERANJANG ---
  int get cartTotalCount => itemCounts.values.fold(0, (a, b) => a + b);

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
        return;
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

  void _openCart() {
    Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          counts: itemCounts,
          menuMap: cartItems,
          username: displayUsername,
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
            onAddCart: (m) => _addMenuToCart(m, activeKantin!.id),
            onRemoveCart: _removeOneFromCart,
            itemCounts: itemCounts,
          );
        }
        return LandingPage(
          username: displayUsername,
          onSeeAllKantin: () => setState(() => selectedIndex = 1),
          onAddCart: (m) =>
              _addMenuToCart(m, '1'), // Default kantin 1 untuk landing
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
