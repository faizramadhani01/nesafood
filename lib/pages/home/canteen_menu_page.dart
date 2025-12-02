import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../model/kantin_data.dart';
import '../../model/menu.dart';
import '../../theme.dart';
import '../../services/meal_service.dart';
import '../detail_menu_screen.dart'; // Import halaman detail menu

class CanteenMenuPage extends StatefulWidget {
  final Kantin kantin;
  final VoidCallback onBack;
  final Function(Menu) onAddCart;
  final Function(Menu) onRemoveCart;
  final Map<String, int> itemCounts;
  final String searchQuery;

  const CanteenMenuPage({
    super.key,
    required this.kantin,
    required this.onBack,
    required this.onAddCart,
    required this.onRemoveCart,
    required this.itemCounts,
    required this.searchQuery,
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
      final menus = await _mealService.fetchMenuByCategory(
        widget.kantin.categoryApi,
      );
      if (mounted) {
        setState(() {
          _menus = menus;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenus = widget.searchQuery.isEmpty
        ? _menus
        : _menus
              .where(
                (menu) => menu.name.toLowerCase().contains(
                  widget.searchQuery.toLowerCase(),
                ),
              )
              .toList();

    return Scaffold(
      backgroundColor: NesaColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: widget.onBack,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 2.h,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.kantin.name,
                        style: GoogleFonts.poppins(
                          fontSize: 2.5.h,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Menu Spesial: ${widget.kantin.categoryApi}',
                        style: GoogleFonts.poppins(
                          fontSize: 1.5.h,
                          color: NesaColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: NesaColors.terracotta,
                  ),
                ),
              )
            else if (filteredMenus.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    "Menu tidak ditemukan",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              )
            else
              _buildGridSection('Daftar Menu', filteredMenus),
            SizedBox(height: 5.h),
          ],
        ),
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
              Container(width: 4, height: 24, color: NesaColors.terracotta),
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
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.70,
          ),
          itemBuilder: (context, i) => _menuItemCard(menus[i]),
        ),
      ],
    );
  }

  Widget _menuItemCard(Menu m) {
    final count = widget.itemCounts[m.name] ?? 0;

    return InkWell(
      onTap: () {
        // Navigasi ke halaman DetailMenuScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMenuScreen(
              menu: m, // Kirim data menu ke halaman detail
              onAddCart: widget.onAddCart,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        m.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200]),
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
                          color: NesaColors.terracotta,
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      m.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Rp${(m.price / 1000).toStringAsFixed(0)}k',
                            style: GoogleFonts.poppins(
                              color: NesaColors.terracotta,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (count == 0)
                          InkWell(
                            onTap: () => widget.onAddCart(m),
                            child: const Icon(
                              Icons.add_circle,
                              color: NesaColors.terracotta,
                              size: 28,
                            ),
                          )
                        else
                          Row(
                            children: [
                              InkWell(
                                onTap: () => widget.onRemoveCart(m),
                                child: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 24,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => widget.onAddCart(m),
                                child: const Icon(
                                  Icons.add_circle_rounded,
                                  size: 24,
                                  color: NesaColors.terracotta,
                                ),
                              ),
                            ],
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
