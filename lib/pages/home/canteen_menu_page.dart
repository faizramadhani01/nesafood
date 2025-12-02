import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/kantin_data.dart';
import '../../model/menu.dart';
import '../../theme.dart';
import '../../services/meal_service.dart';

class CanteenMenuPage extends StatefulWidget {
  final Kantin kantin;
  final VoidCallback onBack;
  // Update Type Function: Menerima Menu saja (Wrapper di HomeScreen yang handle ID)
  // ATAU kita panggil dengan ID di sini?
  // Lebih baik: Biarkan HomeScreen mengatur ID lewat wrapper yang kita buat di atas.
  // Jadi signature di sini TETAP (Menu) -> void, tapi di HomeScreen kita bungkus.
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
      final menus = await _mealService.fetchMenuByCategory(widget.kantin.categoryApi);
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
    return Scaffold(
      backgroundColor: NesaColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: widget.onBack,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.kantin.name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('Menu Spesial: ${widget.kantin.categoryApi}', style: GoogleFonts.poppins(fontSize: 13, color: NesaColors.terracotta)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator(color: NesaColors.terracotta)))
            else if (_menus.isEmpty)
              Center(child: Padding(padding: const EdgeInsets.only(top: 50), child: Text("Menu belum tersedia", style: GoogleFonts.poppins(color: Colors.grey))))
            else
              _buildGridSection('Daftar Menu', _menus),
            const SizedBox(height: 40),
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
          child: Row(children: [Container(width: 4, height: 24, color: NesaColors.terracotta), const SizedBox(width: 10), Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))]),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menus.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.70),
          itemBuilder: (context, i) => _menuItemCard(menus[i]),
        ),
      ],
    );
  }

  Widget _menuItemCard(Menu m) {
    final count = widget.itemCounts[m.name] ?? 0;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(width: double.infinity, child: Image.network(m.image, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(color: Colors.grey[200]))),
                ),
                if (count > 0) Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: NesaColors.terracotta, shape: BoxShape.circle), child: Text('$count', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(m.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, height: 1.2)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Rp${m.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(color: NesaColors.terracotta, fontWeight: FontWeight.bold, fontSize: 14)),
                  if (count == 0)
                    InkWell(onTap: () => widget.onAddCart(m), child: const Icon(Icons.add_circle, color: NesaColors.terracotta))
                  else
                    Row(children: [
                      InkWell(onTap: () => widget.onRemoveCart(m), child: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey)),
                      const SizedBox(width: 4),
                      InkWell(onTap: () => widget.onAddCart(m), child: const Icon(Icons.add_circle_rounded, size: 20, color: NesaColors.terracotta)),
                    ])
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}