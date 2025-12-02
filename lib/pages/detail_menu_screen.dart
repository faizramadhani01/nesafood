import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../model/menu.dart';
import '../theme.dart';

class DetailMenuScreen extends StatefulWidget {
  final Menu menu;
  final Function(Menu)? onAddCart;
  const DetailMenuScreen({super.key, required this.menu, this.onAddCart});

  @override
  State<DetailMenuScreen> createState() => _DetailMenuScreenState();
}

class _DetailMenuScreenState extends State<DetailMenuScreen> {
  int _quantity = 1;

  double get _totalPrice => (widget.menu.price * _quantity);

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    const terracotta = NesaColors.terracotta;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 90.w),
              child: Card(
                margin: EdgeInsets.all(isMobile ? 3.w : 6.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // IMAGE + overlay buttons
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: SizedBox(
                            height: isMobile ? 26.h : 32.h,
                            width: double.infinity,
                            child: Image.network(
                              menu.image,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, prog) {
                                if (prog == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.fastfood, size: 80),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Card(
                            color: Colors.black.withOpacity(0.5),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  Navigator.pop(context, widget.menu),
                            ),
                          ),
                        ),
                        // favorite button removed as requested
                      ],
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4.w : 6.w,
                        vertical: isMobile ? 3.w : 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  menu.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 20.sp : 24.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 14,
                                  vertical: isMobile ? 8 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Rp${menu.price.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isMobile ? 14.sp : 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.w),

                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.local_fire_department,
                                label: '590 Cal',
                              ),
                              const SizedBox(width: 8),
                              // Rating stars menggunakan flutter_rating_stars
                              RatingStars(
                                value: widget.menu.rating,
                                onValueChanged: (val) {
                                  setState(() {
                                    widget.menu.rating = val;
                                  });
                                },
                                starBuilder: (index, color) => Icon(
                                  Icons.star,
                                  color: color,
                                  size: isMobile ? 20 : 24,
                                ),
                                starCount: 5,
                                starSize: isMobile ? 20 : 24,
                                valueLabelColor: const Color(0xff9b9b9b),
                                valueLabelTextStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: isMobile ? 12.sp : 14.sp,
                                ),
                                valueLabelRadius: 10,
                                maxValue: 5,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(icon: Icons.timer, label: '25-35 m'),
                            ],
                          ),

                          SizedBox(height: 3.w),

                          Text(
                            'Deskripsi',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 13.sp : 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.w),
                          Text(
                            menu.description,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 14.sp : 16.sp,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.left,
                          ),

                          SizedBox(height: 3.w),

                          SizedBox(height: 3.w),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Bottom bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4.w : 6.w,
                        vertical: isMobile ? 3.w : 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 13.sp : 15.sp,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Rp${_totalPrice.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 16.sp : 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: terracotta,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () => setState(
                                  () => _quantity = (_quantity > 1)
                                      ? _quantity - 1
                                      : 1,
                                ),
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: isMobile ? 26 : 28,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '$_quantity',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isMobile ? 16.sp : 18.sp,
                                ),
                              ),
                              SizedBox(width: 6),
                              IconButton(
                                onPressed: () => setState(() => _quantity += 1),
                                icon: Icon(
                                  Icons.add_circle_rounded,
                                  color: NesaColors.terracotta,
                                  size: isMobile ? 28 : 30,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 8),

                          ElevatedButton(
                            onPressed: () {
                              if (widget.onAddCart != null) {
                                for (int i = 0; i < _quantity; i++)
                                  widget.onAddCart!(widget.menu);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.menu.name} ditambahkan ($_quantity)',
                                  ),
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
                              Navigator.pop(context, widget.menu);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: terracotta,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 18,
                                vertical: isMobile ? 12 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Tambah ke Keranjang',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: isMobile ? 15.sp : 17.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extras removed — kept only rating functionality.

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({Key? key, required this.icon, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 3.w : 8,
        vertical: isMobile ? 2.w : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 16 : 18, color: Colors.grey[700]),
          SizedBox(width: isMobile ? 3.w : 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: isMobile ? 12.sp : 13.sp),
          ),
        ],
      ),
    );
  }
}
