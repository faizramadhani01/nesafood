import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'headbar_screen.dart';
import '../model/menu.dart';
import '../model/kantin_data.dart';
import '../profile_panel_screen.dart';
import 'detail_menu_screen.dart';
import 'cart_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  final String? username;
  const HomeScreen({super.key, this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showProfilePanel = false;
  late String username;
  Kantin? activeKantin;
  final Map<String, int> itemCounts = {}; // quantity per menu name
  final Map<String, Menu> cartItems = {}; // menu object per name
  static const Color terracotta = NesaColors.terracotta;

  // search
  String searchQuery = '';

  // hero carousel controller
  final PageController _heroController = PageController(viewportFraction: 0.98);

  // ratings for kantins
  late Map<String, double> kantinRatings;

  @override
  void initState() {
    super.initState();
    username = (widget.username?.trim().isEmpty ?? true)
        ? 'Guest'
        : widget.username!.trim();
    kantinRatings = {for (var k in kantinList) k.name: k.rating};
  }

  void _showRatingDialog(Kantin k) {
    double selectedRating = k.rating;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Rate ${k.name}', style: GoogleFonts.poppins()),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 80),
            alignment: Alignment.center,
            child: RatingStars(
              value: selectedRating,
              onValueChanged: (v) {
                setStateDialog(() {
                  selectedRating = v;
                });
              },
              starBuilder: (index, color) => Icon(Icons.star, color: color),
              starCount: 5,
              starSize: 24,
              valueLabelColor: const Color(0xff9b9b9b),
              valueLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
              ),
              valueLabelRadius: 10,
              maxValue: 5,
              starSpacing: 6,
              maxValueVisibility: false,
              valueLabelVisibility: false,
              animationDuration: Duration(milliseconds: 300),
              valueLabelPadding: const EdgeInsets.symmetric(
                vertical: 1,
                horizontal: 8,
              ),
              valueLabelMargin: const EdgeInsets.only(right: 8),
              starOffColor: const Color(0xffe7e8ea),
              starColor: Colors.yellow,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                k.rating = selectedRating;
                kantinRatings[k.name] = k.rating;
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

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

  void handleSearch(String q) {
    setState(() {
      searchQuery = q.trim();
    });
  }

  void _openCart() async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          counts: Map<String, int>.from(itemCounts),
          menuMap: Map<String, Menu>.from(cartItems),
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

  // helper to add one item (keeps cartItems in sync)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
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
          LayoutBuilder(
            builder: (context, constraints) {
              // allow wider content on large screens (reduce left/right gutters)
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
          if (showProfilePanel)
            Positioned(
              // place profile panel directly under the app bar (statusBar + toolbar)
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
  // LANDING / HOME DESIGN
  // -----------------------
  Widget _buildLanding() {
    final heroItems = kantinList.take(4).toList();
    final featuredMenus = kantinList.isNotEmpty
        ? kantinList.first.menus.take(6).toList()
        : <Menu>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero + CTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: hero carousel + quick stats
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 14,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        height: 220,
                        child: PageView.builder(
                          controller: _heroController,
                          itemCount: heroItems.length,
                          itemBuilder: (context, i) {
                            final k = heroItems[i];
                            return _heroCard(k);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.restaurant,
                            'Kantin',
                            '${kantinList.length}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            Icons.fastfood,
                            'Menu',
                            '${kantinList.fold<int>(0, (p, e) => p + e.menus.length)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            Icons.star,
                            'Rating',
                            (kantinList
                                        .map((k) => k.rating)
                                        .reduce((a, b) => a + b) /
                                    kantinList.length)
                                .toStringAsFixed(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              // Right: quick search + promo / user greeting
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/logo.png',
                                  height: 52,
                                  width: 52,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, $username',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Temukan makanan favoritmu hari ini',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => selectedIndex = 1),
                            icon: const Icon(Icons.storefront),
                            label: Text(
                              'Pesan Sekarang',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: terracotta,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Promo Hari Ini',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _promoCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kantin Terdekat',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(height: 90, child: _nearbyKantinList()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Featured Kantin Strip
          Text(
            'Kantin Populer',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemBuilder: (context, i) =>
                  _featuredKantinTile(kantinList[i % kantinList.length]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: kantinList.length,
            ),
          ),

          const SizedBox(height: 26),

          // Recommended Menus grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Hari Ini',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => selectedIndex = 1),
                child: Text(
                  'Lihat semua',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredMenus.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            // disable direct add on landing: allowAdd = false
            itemBuilder: (context, i) =>
                _menuCard(featuredMenus[i], allowAdd: false),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _heroCard(Kantin k) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                k.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.38),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      k.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      activeKantin = k;
                      selectedIndex = 1;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: terracotta,
                    ),
                    child: Text('Lihat Menu', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: terracotta.withOpacity(0.12),
            child: Icon(icon, color: terracotta),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [terracotta, terracotta.withOpacity(0.86)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diskon 20% untuk pemesanan pertama',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gunakan kode: NESA20',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _nearbyKantinList() {
    final nearby = kantinList.take(4).toList();
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: nearby.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, i) {
        final k = nearby[i];
        return InkWell(
          onTap: () => setState(() => activeKantin = k),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      k.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  k.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _featuredKantinTile(Kantin k) {
    // richer featured tile used on landing (wider card)
    return InkWell(
      onTap: () => setState(() {
        activeKantin = k;
        selectedIndex = 1;
      }),
      onLongPress: () => _showRatingDialog(k),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 14,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        k.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200]),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.32),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Text(
                        k.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: GestureDetector(
                        onTap: () => _showRatingDialog(k),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                kantinRatings[k.name]?.toStringAsFixed(1) ??
                                    '4.8',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                k.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------
  // KANTIN SELECTION / MENU VIEWS
  // -----------------------
  Widget _buildKantinSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _sectionHeaderWithBack(
          title: 'Pilih Kantin',
          onBack: () => setState(() => selectedIndex = 0),
        ),
        const SizedBox(height: 12),
        ExpandedGridKantin(),
      ],
    );
  }

  Widget _buildKantinMenuView(Kantin k) {
    final makanan = k.menus.where((m) => m.getCategory() == 'Makanan').toList();
    final minuman = k.menus.where((m) => m.getCategory() == 'Minuman').toList();
    final snack = k.menus.where((m) => m.getCategory() == 'Snack').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _sectionHeaderWithBack(
          title: k.name,
          subtitle: null,
          onBack: () => setState(() => activeKantin = null),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (makanan.isNotEmpty) _buildGridSection('Makanan', makanan),
                if (minuman.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildGridSection('Minuman', minuman),
                ],
                if (snack.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildGridSection('Snack', snack),
                ],
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // grid for kantin list
  Widget ExpandedGridKantin() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          childAspectRatio: 1.05,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: kantinList.length,
        itemBuilder: (context, i) {
          final k = kantinList[i];
          // modern card design: image with gradient overlay, info chip and subtle shadow
          return InkWell(
            onTap: () => setState(() => activeKantin = k),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image area with overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: Image.asset(
                            k.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.28),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        // small badge top-left
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  size: 14,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kantin',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // rating / ETA chip bottom-left
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '4.7 • 15 mnt',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // info row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            k.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            activeKantin = k;
                            selectedIndex = 1;
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: terracotta,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Lihat',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridSection(String title, List<Menu> menus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // reuse _menuCard for consistent, polished menu tiles
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menus.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) {
            final m = menus[i];
            return _menuCard(m);
          },
        ),
      ],
    );
  }

  // -----------------------
  // SEARCH RESULTS
  // -----------------------
  Widget _buildSearchResults(String q) {
    final qLower = q.toLowerCase();
    final matchingKantins = kantinList
        .where((k) => k.name.toLowerCase().contains(qLower))
        .toList();

    if (activeKantin != null) {
      final filtered = activeKantin!.menus
          .where((m) => m.name.toLowerCase().contains(qLower))
          .toList();
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Hasil pencarian di "${activeKantin!.name}" untuk "$q"',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Tidak ada hasil untuk "$q"',
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              )
            else
              _buildGridSection('Hasil', filtered),
          ],
        ),
      );
    }

    if (matchingKantins.isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Hasil pencarian untuk "$q"',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Kantin',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: matchingKantins.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final k = matchingKantins[i];
                  return InkWell(
                    onTap: () => setState(() {
                      activeKantin = k;
                      searchQuery = '';
                    }),
                    child: Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
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
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.store, size: 36),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              k.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        'Tidak ada hasil untuk "$q"',
        style: GoogleFonts.poppins(color: Colors.black54),
      ),
    );
  }

  // -----------------------
  // ABOUT
  // -----------------------
  Widget _buildAbout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final left = Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tentang Nesa Food',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nesa Food adalah platform pemesanan makanan untuk kantin Baseball UNESA5. '
                      'Kami memudahkan pemesanan dari berbagai kantin kampus sehingga mahasiswa dapat '
                      'mendapatkan makanan cepat, aman, dan praktis tanpa mengantri panjang.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dibuat oleh',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: NesaColors.terracottaLight,
                                child: Text(
                                  'D',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: NesaColors.terracotta,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dicky',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jl. Maospati - Bar. No.358-360, Kleco, Maospati, Kabupaten Magetan, Jawa Timur 63392',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 18,
                                color: NesaColors.terracotta,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+62 895 3673 48576',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              const SizedBox(width: 18),
                              Icon(
                                Icons.email,
                                size: 18,
                                color: NesaColors.terracotta,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'dickysanjayaputra2101@gmail.com',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // social placeholders (replace with links if needed)
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: NesaColors.terracottaLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.public,
                                        size: 16,
                                        color: NesaColors.terracotta,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Website',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.facebook,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Facebook',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.pink,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Instagram',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final right = Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isWide ? 28 : 0,
                    top: isWide ? 0 : 20,
                  ),
                  child: Container(
                    height: 340,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 260,
                          width: 260,
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [left, right],
                    )
                  : Column(children: [left, right]);
            },
          ),
        ),
      ),
    );
  }

  // -----------------------
  // Reusable UI widgets
  // -----------------------
  Widget _menuCard(Menu m, {bool allowAdd = true}) {
    final count = itemCounts[m.name] ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 120,
              child: Image.asset(
                m.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rp${m.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: terracotta,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.eco, color: Colors.green.shade700, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: count == 0
                ? (allowAdd
                      // normal add button (when in Menu section)
                      ? ElevatedButton(
                          onPressed: () => _addMenuToCart(m),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: terracotta,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Add to Dish',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      // on landing: show "Lihat di Menu" CTA that navigates user to Menu and selects parent kantin
                      : ElevatedButton(
                          onPressed: () {
                            // find parent kantin that contains this menu (safe nullable logic)
                            Kantin? parent;
                            for (final k in kantinList) {
                              if (k.menus.any((mm) => mm.name == m.name)) {
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
                            backgroundColor: Colors.grey.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Lihat di Menu',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                : Row(
                    children: [
                      IconButton(
                        onPressed: () => _removeOneFromCart(m),
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: terracotta,
                        ),
                      ),
                      Text(
                        '${itemCounts[m.name]}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () => _addMenuToCart(m),
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailMenuScreen(menu: m),
                          ),
                        ),
                        child: Text('Details', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // reusable section header with improved back UI
  Widget _sectionHeaderWithBack({
    required String title,
    String? subtitle,
    required VoidCallback onBack,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.chevron_left, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
        // optional small action (e.g., favorite / share) placeholder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: NesaColors.terracottaLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.place, size: 16, color: NesaColors.terracotta),
              const SizedBox(width: 6),
              Text(
                'Nearby',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: NesaColors.terracotta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
