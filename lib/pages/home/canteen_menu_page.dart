import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/kantin_data.dart';
import '../../model/menu.dart';
import '../../theme.dart';

class CanteenMenuPage extends StatelessWidget {
  final Kantin kantin;
  final VoidCallback onBack;
  final Function(Menu) onAddCart;
  final Function(Menu) onRemoveCart;
  final Map<String, int> itemCounts;

  const CanteenMenuPage({
    super.key,
    required this.kantin,
    required this.onBack,
    required this.onAddCart,
    required this.onRemoveCart,
    required this.itemCounts,
  });

  @override
  Widget build(BuildContext context) {
    final makanan =
        kantin.menus.where((m) => m.getCategory() == 'Makanan').toList();
    final minuman =
        kantin.menus.where((m) => m.getCategory() == 'Minuman').toList();
    final snack =
        kantin.menus.where((m) => m.getCategory() == 'Snack').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan Tombol Back
          Row(
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
                    kantin.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Silakan pilih menu favoritmu',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
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
            maxCrossAxisExtent: 250,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) => _menuItemCard(menus[i]),
        ),
      ],
    );
  }

  Widget _menuItemCard(Menu m) {
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
                                Container(color: Colors.grey[200]),
                          )
                        : Image.asset(
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
              padding: const EdgeInsets.all(12),
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
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp${m.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: NesaColors.terracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (count == 0)
                        InkWell(
                          onTap: () => onAddCart(m),
                          child: const Icon(
                            Icons.add_circle,
                            color: NesaColors.terracotta,
                          ),
                        )
                      else
                        Row(
                          children: [
                            InkWell(
                              onTap: () => onRemoveCart(m),
                              child: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => onAddCart(m),
                              child: const Icon(
                                Icons.add_circle_rounded,
                                size: 20,
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
    );
  }
}