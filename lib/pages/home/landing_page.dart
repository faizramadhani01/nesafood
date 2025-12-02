import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart'; // PAKAI LIBRARY KAMU

import '../../model/menu.dart';
import '../../model/kantin_data.dart';
import '../../theme.dart';
import '../../services/meal_service.dart';
import '../detail_menu_screen.dart'; 

class LandingPage extends StatefulWidget {
  final String username;
  final String searchQuery;
  final VoidCallback onSeeAllKantin;
  final Function(Menu) onAddCart;
  final Function(Menu) onRemoveCart;
  final Map<String, int> itemCounts;
  final Function(Kantin) onSelectKantin; 

  const LandingPage({
    super.key,
    required this.username,
    required this.searchQuery,
    required this.onSeeAllKantin,
    required this.onAddCart,
    required this.onRemoveCart,
    required this.itemCounts,
    required this.onSelectKantin,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _heroController = PageController(viewportFraction: 0.9);
  final MealService _mealService = MealService();
  List<Menu> apiMenus = [];
  bool isLoadingApi = true;

  @override
  void initState() {
    super.initState();
    _fetchApiMenus();
  }

  Future<void> _fetchApiMenus() async {
    try {
      final menus = await _mealService.fetchMeals();
      if (mounted) {
        setState(() {
          apiMenus = menus.take(8).toList();
          isLoadingApi = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingApi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroItems = kantinList.take(5).toList();
    
    final List<Menu> allMenus = [
      ...apiMenus,
      ...kantinList.expand((k) => k.menus),
    ];

    final bool isSearching = widget.searchQuery.isNotEmpty;
    
    List<Menu> displayedMenus = isSearching 
        ? allMenus.where((m) => m.name.toLowerCase().contains(widget.searchQuery.toLowerCase())).toList()
        : apiMenus;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          if (isSearching) ...[
            if (displayedMenus.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text("Menu tidak ditemukan", style: GoogleFonts.poppins()),
                ),
              )
            else
              _buildGridMenu(displayedMenus),
          ] 
          else ...[
            Text(
              'Halo, ${widget.username}!',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: NesaColors.terracotta,
              ),
            ),
            Text(
              'Mau makan apa hari ini?',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 24.h,
              child: PageView.builder(
                controller: _heroController,
                padEnds: false,
                itemCount: heroItems.length,
                itemBuilder: (context, i) => _heroCard(heroItems[i]),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                const Icon(Icons.public, color: NesaColors.terracotta),
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
            const SizedBox(height: 16),
            
            if (isLoadingApi)
              const Center(
                child: CircularProgressIndicator(color: NesaColors.terracotta),
              )
            else
              _buildGridMenu(apiMenus),

            const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }

  Widget _buildGridMenu(List<Menu> menus) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.68, 
      ),
      itemBuilder: (context, i) => _menuItemCard(menus[i]),
    );
  }

  Widget _menuItemCard(Menu m) {
    final count = widget.itemCounts[m.name] ?? 0;
    final isNetwork = m.image.startsWith('http');
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMenuScreen(
              menu: m, 
              onAddCart: widget.onAddCart
            ),
          ),
        ).then((updatedMenu) {
           if (updatedMenu != null) setState(() => m.rating = updatedMenu.rating);
        });
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
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: isNetwork
                          ? Image.network(
                              m.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                            )
                          : Image.asset(
                              m.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
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
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    
                    // --- BINTANG + ANGKA ---
                    Row(
                      children: [
                        RatingStars(
                          value: m.rating,
                          onValueChanged: (v) {
                            // setState(() => m.rating = v); // Read-only di sini
                          },
                          starBuilder: (index, color) => Icon(Icons.star, color: color, size: 12),
                          starCount: 5, 
                          starSize: 12, 
                          maxValue: 5, 
                          starSpacing: 1,
                          maxValueVisibility: false,
                          valueLabelVisibility: false,
                          animationDuration: const Duration(milliseconds: 1000),
                          valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                          valueLabelMargin: const EdgeInsets.only(right: 8),
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
                          style: GoogleFonts.poppins(color: NesaColors.terracotta, fontWeight: FontWeight.bold),
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

  Widget _heroCard(Kantin k) {
    return InkWell(
      onTap: () => widget.onSelectKantin(k), 
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    k.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    k.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}