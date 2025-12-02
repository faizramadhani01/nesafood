import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../model/kantin_data.dart';
import '../../model/menu.dart';
import '../../theme.dart';
import '../../services/meal_service.dart';
import '../detail_menu_screen.dart';

class CanteenMenuPage extends StatefulWidget {
  final Kantin kantin;
  final String searchQuery; // <--- 1. TAMBAHKAN INI
  final VoidCallback onBack;
  final Function(Menu) onAddCart;
  final Function(Menu) onRemoveCart;
  final Map<String, int> itemCounts;

  const CanteenMenuPage({
    super.key,
    required this.kantin,
    required this.searchQuery, // <--- 2. WAJIB DIISI
    required this.onBack,
    required this.onAddCart,
    required this.onRemoveCart,
    required this.itemCounts,
  });

  @override
  State<CanteenMenuPage> createState() => _CanteenMenuPageState();
}

class _CanteenMenuPageState extends State<CanteenMenuPage> {
  final MealService _mealService = MealService();
  List<Menu> _menus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuFromApi();
  }

  Future<void> _loadMenuFromApi() async {
    try {
      final apiMenus = await _mealService.fetchMenuByCategory(
        widget.kantin.categoryApi,
      );
      if (mounted) {
        setState(() {
          _menus = [...apiMenus, ...widget.kantin.menus];
          // Hapus duplikat (opsional)
          final ids = <String>{};
          _menus.retainWhere((x) => ids.add(x.name));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _menus = widget.kantin.menus;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 3. LOGIKA FILTER PENCARIAN DI SINI ---
    final bool isSearching = widget.searchQuery.isNotEmpty;
    
    // Jika sedang mencari, filter _menus. Jika tidak, pakai semua _menus.
    final List<Menu> displayedMenus = isSearching
        ? _menus.where((m) => 
            m.name.toLowerCase().contains(widget.searchQuery.toLowerCase())
          ).toList()
        : _menus;

    return Scaffold(
      backgroundColor: NesaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              color: NesaColors.background,
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.kantin.name,
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Kategori: ${widget.kantin.categoryApi}',
                          style: GoogleFonts.poppins(fontSize: 13, color: NesaColors.terracotta),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // CONTENT
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: NesaColors.terracotta))
                  : displayedMenus.isEmpty // Cek hasil filter kosong atau tidak
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                isSearching 
                                  ? "Menu tidak ditemukan" 
                                  : "Menu belum tersedia",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  isSearching 
                                    ? 'Hasil Pencarian' 
                                    : 'Daftar Menu',
                                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayedMenus.length, // Pakai list yang sudah difilter
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.70,
                                ),
                                itemBuilder: (context, i) => _menuItemCard(displayedMenus[i]),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItemCard(Menu m) {
    final count = widget.itemCounts[m.name] ?? 0;
    return InkWell(
      onTap: () {
        Navigator.push<Menu>(
          context,
          MaterialPageRoute(builder: (context) => DetailMenuScreen(menu: m, onAddCart: widget.onAddCart)),
        ).then((updatedMenu) {
          if (updatedMenu != null) setState(() => m.rating = updatedMenu.rating);
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    m.image, fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Image.asset(m.image, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200])),
                  ),
                ),
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
                    Text(m.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    RatingStars(
                      value: m.rating,
                      onValueChanged: (v) => setState(() => m.rating = v),
                      starBuilder: (index, color) => Icon(Icons.star, color: color, size: 14),
                      starCount: 5, starSize: 14, maxValue: 5, starColor: Colors.amber, valueLabelVisibility: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rp${m.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: NesaColors.terracotta, fontWeight: FontWeight.bold, fontSize: 14)),
                        InkWell(
                          onTap: () => widget.onAddCart(m),
                          child: const Icon(Icons.add_circle, color: NesaColors.terracotta),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}