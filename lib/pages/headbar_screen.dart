import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
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
  Size get preferredSize => const Size.fromHeight(88.0);
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
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              SizedBox(
                height: 56,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
              const SizedBox(width: 12),
              const Spacer(),
              _MenuButton(
                label: 'Home',
                selected: widget.selectedIndex == 0,
                onTap: () => widget.onMenuTap(0),
                selectedColor: NesaColors.terracotta,
              ),
              const SizedBox(width: 8),
              _MenuButton(
                label: 'Menu',
                selected: widget.selectedIndex == 1,
                onTap: () => widget.onMenuTap(1),
                selectedColor: NesaColors.terracotta,
              ),
              const SizedBox(width: 8),
              _MenuButton(
                label: 'About',
                selected: widget.selectedIndex == 2,
                onTap: () => widget.onMenuTap(2),
                selectedColor: NesaColors.terracotta,
              ),
              const SizedBox(width: 18),
              SizedBox(
                width: 320,
                child: TextField(
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
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _ctrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              _ctrl.clear();
                              if (widget.onSearch != null) widget.onSearch!('');
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Cart icon with badge (pakai alias badges.Badge)
              badges.Badge(
                showBadge: widget.cartCount > 0,
                badgeContent: Text(
                  '${widget.cartCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                child: IconButton(
                  onPressed: widget.onCartTap,
                  icon: const Icon(Icons.shopping_cart, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: const CircleAvatar(
                  backgroundColor: Colors.black12,
                  child: Icon(Icons.person, color: Colors.black87),
                ),
              ),
            ],
          ),
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

  const _MenuButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
