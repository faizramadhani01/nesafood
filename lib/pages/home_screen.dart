import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:sizer/sizer.dart';
import 'headbar_screen.dart';
import '../model/menu.dart';
import '../model/kantin_data.dart';
import '../profile_panel_screen.dart';
import 'detail_menu_screen.dart';
import 'cart_screen.dart';
import '../theme.dart';
import '../services/meal_service.dart'; // Import Service API

class HomeScreen extends StatefulWidget {
  final String? username;
  const HomeScreen({super.key, this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE VARIABLES ---
  int selectedIndex = 0;
  bool showProfilePanel = false;
  late String username;
  Kantin? activeKantin;

  // State Keranjang (Cart)
  final Map<String, int> itemCounts = {};
  final Map<String, Menu> cartItems = {};

  // Warna Tema (Shortcut)
  static const Color terracotta = NesaColors.terracotta;
  static const Color terracottaLight = NesaColors.terracottaLight;

  // Search & Carousel
  String searchQuery = '';
  final PageController _heroController = PageController(viewportFraction: 0.9);
  late Map<String, double> kantinRatings;

  // --- API VARIABLES (TheMealDB) ---
  List<Menu> apiMenus = [];
  bool isLoadingApi = true;
  final MealService _mealService = MealService();

  @override
  void initState() {
    super.initState();
    username = (widget.username?.trim().isEmpty ?? true)
        ? 'Guest'
        : widget.username!.trim();
    kantinRatings = {for (var k in kantinList) k.name: k.rating};

    // PANGGIL API SAAT APLIKASI DIBUKA
    _fetchApiMenus();
  }

  // Fungsi Fetch Data dari Internet
  Future<void> _fetchApiMenus() async {
    try {
      final menus = await _mealService.fetchMeals();
      if (mounted) {
        setState(() {
          // Ambil 8 menu saja agar layout tetap rapi
          apiMenus = menus.take(8).toList();
          isLoadingApi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingApi = false);
      }
      print("Error fetching API: $e");
    }
  }

  // --- LOGIKA CART & RATING ---

  int get cartTotalCount => itemCounts.values.fold(0, (a, b) => a + b);

  void handleMenuTap(int index) {
    setState(() {
      selectedIndex = index;
      showProfilePanel = false;
      activeKantin = null;
      searchQuery = '';
    });
  }

  void handleProfileTap() =>
      setState(() => showProfilePanel = !showProfilePanel);
  void handleSearch(String q) => setState(() => searchQuery = q.trim());

  void _addMenuToCart(Menu m, {int qty = 1}) {
    setState(() {
      itemCounts[m.name] = (itemCounts[m.name] ?? 0) + qty;
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

  void _openCart() async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          counts: Map<String, int>.from(itemCounts),
          menuMap: Map<String, Menu>.from(cartItems),
          username: username,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        itemCounts
          ..clear()
          ..addAll(result);
        cartItems.removeWhere(
          (name, _) => !(itemCounts.containsKey(name) && itemCounts[name]! > 0),
        );
      });
    }
  }

  void _showRatingDialog(Kantin k) {
    double selectedRating = k.rating;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Beri Rating ${k.name}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingStars(
                value: selectedRating,
                onValueChanged: (v) => setStateDialog(() => selectedRating = v),
                starBuilder: (index, color) =>
                    Icon(Icons.star_rounded, color: color, size: 32),
                starCount: 5,
                starSize: 32,
                starColor: const Color(0xFFFFC107),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  k.rating = selectedRating;
                  kantinRatings[k.name] = k.rating;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: terracotta),
              child: Text(
                'Kirim',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILD UI UTAMA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NesaColors.background,
      appBar: HeadBar(
        title: 'Nesa Food',
        selectedIndex: selectedIndex,
        onMenuTap: handleMenuTap,
        onProfileTap: handleProfileTap,
        onSearch: handleSearch,
        searchQuery: searchQuery,
        cartCount: cartTotalCount,
        onCartTap: _openCart,
      ),
      body: Stack(
        children: [
          // Layout Responsif (Tengah Layar di Desktop)
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 1400
                  ? 1250.0
                  : constraints.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: buildMainContent(),
                ),
              );
            },
          ),
          // Panel Profil Overlay
          if (showProfilePanel)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              right: 24,
              child: ProfilePanel(
                username: username,
                onClose: handleProfileTap,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildMainContent() {
    if (searchQuery.isNotEmpty) return _buildSearchResults(searchQuery);

    switch (selectedIndex) {
      case 0:
        return _buildLanding();
      case 1:
        return activeKantin == null
            ? _buildKantinSelection()
            : _buildKantinMenuView(activeKantin!);
      case 2:
        return _buildAbout();
      default:
        return const SizedBox.shrink();
    }
  }

  // -----------------------
  // 1. LANDING PAGE / HOME
  // -----------------------
  Widget _buildLanding() {
    final heroItems = kantinList.take(5).toList();
    // Ambil data lokal
    final featuredMenus = kantinList.isNotEmpty
        ? kantinList.expand((k) => k.menus).take(8).toList()
        : <Menu>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome & Promo Area
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmall = constraints.maxWidth < 800;
              return Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isSmall ? 0 : 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Halo, ',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(
                                text: '$username!',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: terracotta,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lapar? Ayo pesan makanan favoritmu sekarang.',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isSmall) const SizedBox(width: 24),
                  if (!isSmall) Expanded(flex: 2, child: _promoBannerSmall()),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Hero Carousel (Kantin Pilihan)
          Text(
            'Kantin Pilihan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 24.h,
            child: PageView.builder(
              controller: _heroController,
              padEnds: false,
              itemCount: heroItems.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _heroCard(heroItems[i]),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _cleanStatItem(
                  Icons.storefront,
                  '${kantinList.length}',
                  'Kantin',
                ),
              ),
              Expanded(
                child: _cleanStatItem(
                  Icons.restaurant_menu,
                  '${kantinList.fold<int>(0, (p, e) => p + e.menus.length)}',
                  'Menu',
                ),
              ),
              Expanded(
                child: _cleanStatItem(Icons.star_rounded, '4.8', 'Rating'),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // --- SECTION 1: MENU ONLINE (API) ---
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.public, color: terracotta, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Menu Spesial (Online)',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          if (isLoadingApi)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: terracotta),
              ),
            )
          else if (apiMenus.isEmpty)
            Center(
              child: Text(
                'Gagal memuat menu online.',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          else
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apiMenus.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, i) =>
                  _menuCard(apiMenus[i], allowAdd: true),
            ),

          const SizedBox(height: 40),

          // --- SECTION 2: REKOMENDASI LOKAL ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi Lokal',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Favorit mahasiswa di kampus',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() => selectedIndex = 1),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    color: terracotta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredMenus.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, i) =>
                _menuCard(featuredMenus[i], allowAdd: false),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // -----------------------
  // 2. KANTIN & MENU PAGE
  // -----------------------

  Widget _buildKantinSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeaderWithBack(
            title: 'Pilih Kantin',
            onBack: () => setState(() => selectedIndex = 0),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: kantinList.length,
            itemBuilder: (context, i) {
              final k = kantinList[i];
              return InkWell(
                onTap: () => setState(() => activeKantin = k),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                          child: Image.asset(
                            k.image,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                k.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${kantinRatings[k.name]?.toStringAsFixed(1)}',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                'Lihat Menu →',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: terracotta,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKantinMenuView(Kantin k) {
    final makanan = k.menus.where((m) => m.getCategory() == 'Makanan').toList();
    final minuman = k.menus.where((m) => m.getCategory() == 'Minuman').toList();
    final snack = k.menus.where((m) => m.getCategory() == 'Snack').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeaderWithBack(
            title: k.name,
            subtitle: 'Silakan pilih menu favoritmu',
            onBack: () => setState(() => activeKantin = null),
          ),
          const SizedBox(height: 24),
          if (makanan.isNotEmpty) _buildGridSection('Makanan Berat', makanan),
          if (minuman.isNotEmpty) _buildGridSection('Minuman Segar', minuman),
          if (snack.isNotEmpty) _buildGridSection('Cemilan', snack),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGridSection(String title, List<Menu> menus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(width: 4, height: 24, color: terracotta),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menus.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) => _menuCard(menus[i]),
        ),
      ],
    );
  }

  // -----------------------
  // 3. ABOUT PAGE
  // -----------------------
  Widget _buildAbout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 80,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.fastfood, size: 80, color: terracotta),
          ),
          const SizedBox(height: 20),
          Text(
            'Nesa Food',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('v1.0.0', style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tentang Kami',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aplikasi pemesanan makanan kantin modern untuk memudahkan mahasiswa.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: terracottaLight,
                    child: Icon(Icons.code, color: terracotta),
                  ),
                  title: Text(
                    'Developer',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Mahasiswa UNESA',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------
  // 4. SEARCH RESULTS
  // -----------------------
  Widget _buildSearchResults(String q) {
    final qLower = q.toLowerCase();
    final matchingKantins = kantinList
        .where((k) => k.name.toLowerCase().contains(qLower))
        .toList();
    final matchingApiMenus = apiMenus
        .where((m) => m.name.toLowerCase().contains(qLower))
        .toList();

    // Jika sedang di dalam kantin tertentu
    if (activeKantin != null) {
      final filtered = activeKantin!.menus
          .where((m) => m.name.toLowerCase().contains(qLower))
          .toList();
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pencarian di "${activeKantin!.name}"',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            Text(
              '"$q"',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (filtered.isEmpty)
              _emptyState('Tidak ada menu cocok.')
            else
              _buildGridSection('Hasil Menu', filtered),
          ],
        ),
      );
    }

    // Global Search
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Pencarian',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          Text(
            '"$q"',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          if (matchingKantins.isNotEmpty) ...[
            Text(
              'Kantin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: matchingKantins.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final k = matchingKantins[i];
                  return InkWell(
                    onTap: () => setState(() {
                      activeKantin = k;
                      searchQuery = '';
                    }),
                    child: Container(
                      width: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.asset(
                                k.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              k.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (matchingApiMenus.isNotEmpty) ...[
            Text(
              'Menu Online',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matchingApiMenus.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) => _menuCard(matchingApiMenus[i]),
            ),
          ],

          if (matchingKantins.isEmpty && matchingApiMenus.isEmpty)
            _emptyState('Tidak ada hasil yang cocok.'),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _promoBannerSmall() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: terracotta,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: terracotta.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diskon 20% Pengguna Baru',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kode: NESA20',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cleanStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: terracotta, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _heroCard(Kantin k) {
    return InkWell(
      onTap: () => setState(() {
        activeKantin = k;
        selectedIndex = 1;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  k.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: terracotta,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Open Now',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      k.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber[400],
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${kantinRatings[k.name]?.toStringAsFixed(1)} • 10-15 min',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(Menu m, {bool allowAdd = true}) {
    final count = itemCounts[m.name] ?? 0;
    final isNetworkImage = m.image.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: isNetworkImage
                        ? Image.network(
                            m.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[100]),
                          )
                        : Image.asset(
                            m.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[100]),
                          ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: terracotta,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp${m.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: terracotta,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: count == 0
                        ? (allowAdd
                              ? OutlinedButton(
                                  onPressed: () => _addMenuToCart(m),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: terracotta,
                                    side: const BorderSide(color: terracotta),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('Add'),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    // Logic Navigasi jika di Home
                                    Kantin? parent;
                                    for (final k in kantinList) {
                                      if (k.menus.any(
                                        (mm) => mm.name == m.name,
                                      )) {
                                        parent = k;
                                        break;
                                      }
                                    }
                                    if (parent == null && kantinList.isNotEmpty) {
                                      parent = kantinList.first;
                                    }
                                    setState(() {
                                      selectedIndex = 1;
                                      if (parent != null) activeKantin = parent;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade100,
                                    elevation: 0,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Lihat'),
                                ))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => _removeOneFromCart(m),
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () => _addMenuToCart(m),
                                child: const Icon(
                                  Icons.add_circle_rounded,
                                  color: terracotta,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(msg, style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeaderWithBack({
    required String title,
    String? subtitle,
    required VoidCallback onBack,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }
}
