import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:sizer/sizer.dart';
import '../theme.dart';

class HeadBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;
  final VoidCallback? onProfileTap;
  final ValueChanged<String>? onSearch;
  final int cartCount;
  final VoidCallback? onCartTap;
  final String searchQuery;

  const HeadBar({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.onMenuTap,
    this.onProfileTap,
    this.onSearch,
    this.cartCount = 0,
    this.onCartTap,
    this.searchQuery = '',
  });

  @override
  State<HeadBar> createState() => _HeadBarState();

  @override
  Size get preferredSize => Size.fromHeight(8.h);
}

class _HeadBarState extends State<HeadBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant HeadBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _ctrl.text != widget.searchQuery) {
      _ctrl.text = widget.searchQuery;
      _ctrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _ctrl.text.length),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 8.h,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 2.w : 2.5.w),
          child: Row(
            children: [
              // Logo - responsive dengan Sizer
              SizedBox(
                height: 7.h,
                width: isMobile ? 10.w : 12.w,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
              SizedBox(width: 1.5.w),

              // Menu buttons - di sebelah logo (kiri dari search)
              _MenuButton(
                label: 'Home',
                selected: widget.selectedIndex == 0,
                onTap: () => widget.onMenuTap(0),
                selectedColor: NesaColors.terracotta,
                compact: isMobile,
              ),
              SizedBox(width: isMobile ? 1.w : 1.w),
              _MenuButton(
                label: 'Menu',
                selected: widget.selectedIndex == 1,
                onTap: () => widget.onMenuTap(1),
                selectedColor: NesaColors.terracotta,
                compact: isMobile,
              ),
              SizedBox(width: isMobile ? 1.w : 1.w),
              _MenuButton(
                label: 'About',
                selected: widget.selectedIndex == 2,
                onTap: () => widget.onMenuTap(2),
                selectedColor: NesaColors.terracotta,
                compact: isMobile,
              ),

              // Flexible spacer to push search and icons to the right
              if (!isMobile) const Spacer() else const Spacer(),

              // Search field - responsive dengan Sizer (lebih lebar di desktop)
              if (!isMobile)
                SizedBox(width: 30.w, child: _buildSearchField(compact: false))
              else
                SizedBox(width: 30.w, child: _buildSearchField(compact: true)),

              SizedBox(width: isMobile ? 0.5.w : 1.w),

              // Cart icon with badge
              badges.Badge(
                showBadge: widget.cartCount > 0,
                badgeContent: Text(
                  '${widget.cartCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: IconButton(
                  onPressed: widget.onCartTap,
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),

              SizedBox(width: 0.5.w),

              // Profile icon
              GestureDetector(
                onTap: widget.onProfileTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, color: Colors.black87, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField({bool compact = false}) {
    return TextField(
      controller: _ctrl,
      onChanged: (v) {
        if (widget.onSearch != null) widget.onSearch!(v);
        setState(() {}); // update clear icon
      },
      onSubmitted: (v) {
        if (widget.onSearch != null) widget.onSearch!(v);
      },
      decoration: InputDecoration(
        hintText: 'Search menu or kantin',
        prefixIcon: Icon(Icons.search, size: compact ? 18 : 20),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 20 : 12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: _ctrl.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _ctrl.clear();
                  if (widget.onSearch != null) widget.onSearch!('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final bool compact;

  const _MenuButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = compact ? 10.0 : 12.0;
    final vertical = compact ? 6.0 : 8.0;
    final fontSize = compact ? 13.sp : 12.sp;
    final radius = selected ? 12.0 : 8.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
