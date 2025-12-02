import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart'; // PAKAI LIBRARY KAMU

import '../../model/kantin_data.dart';
import '../../model/menu.dart';
import '../../theme.dart';
import '../../services/meal_service.dart';
import '../detail_menu_screen.dart';

class CanteenMenuPage extends StatefulWidget {
  final Kantin kantin;
  final String searchQuery;
  final VoidCallback onBack;
  final Function(Menu) onAddCart;
  final Function(Menu) onRemoveCart;
  final Map<String, int> itemCounts;

  const CanteenMenuPage({
    super.key,
    required this.kantin,
    required this.searchQuery,
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
    final bool isSearching = widget.searchQuery.isNotEmpty;
    
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
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: NesaColors.terracotta))
                  : displayedMenus.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.restaurant_menu, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                isSearching ? "Menu tidak ditemukan" : "Menu belum tersedia",
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
                                  isSearching ? 'Hasil Pencarian' : 'Daftar Menu',
                                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: displayedMenus.length,
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.68,
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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        m.image, fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Image.asset(m.image, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200])),
                      ),
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: NesaColors.terracotta,
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
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
                    Text(
                      m.name, 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)
                    ),
                    
                    // --- BINTANG + ANGKA ---
                    Row(
                      children: [
                        RatingStars(
                          value: m.rating,
                          onValueChanged: (v) => setState(() => m.rating = v),
                          starBuilder: (index, color) => Icon(Icons.star, color: color, size: 12),
                          starCount: 5, 
                          starSize: 12, 
                          maxValue: 5, 
                          starSpacing: 1,
                          maxValueVisibility: false, 
                          valueLabelVisibility: false,
                          animationDuration: const Duration(milliseconds: 1000),
                          starOffColor: const Color(0xffe7e8ea),
                          starColor: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.rating.toString(), // Angka Rating (cth: 4.5)
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600]
                          ),
                        )
                      ],
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp${m.price.toStringAsFixed(0)}', 
                          style: GoogleFonts.poppins(color: NesaColors.terracotta, fontWeight: FontWeight.bold, fontSize: 14)
                        ),
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