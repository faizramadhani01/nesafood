import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../model/menu.dart';
import '../theme.dart';

class DetailMenuScreen extends StatelessWidget {
  final Menu menu;
  const DetailMenuScreen({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    const terracotta = NesaColors.terracotta;
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          menu.name,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 90.w),
          child: Card(
            margin: EdgeInsets.all(isMobile ? 4.w : 6.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 4.w : 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: isMobile ? 22.h : 28.h,
                    child: Image.asset(
                      menu.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, size: 80),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.8.h),
                  Text(
                    menu.name,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 20.sp : 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    'Rp${menu.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 18.sp : 20.sp,
                      color: terracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  Text(
                    menu.description,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 14.sp : 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  isMobile
                      ? Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: terracotta,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.8.h,
                                ),
                              ),
                              child: Text(
                                'Lakukan Pemesanan',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            SizedBox(height: 1.6.h),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.8.h,
                                ),
                              ),
                              child: Text('Back', style: GoogleFonts.poppins()),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                              ),
                              child: Text('Back', style: GoogleFonts.poppins()),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: terracotta,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                'Lakukan Pemesanan',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
