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
  Size get preferredSize => const Size.fromHeight(70.0); // Sedikit lebih ramping
}

class _HeadBarState extends State<HeadBar> {
  late final TextEditingController _ctrl;
  bool _isMobileSearchActive = false; // State untuk mode pencarian di HP

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

  void _toggleMobileSearch() {
    setState(() {
      _isMobileSearchActive = !_isMobileSearchActive;
      if (!_isMobileSearchActive) {
        // Jika menutup search, clear text
        _ctrl.clear();
        if (widget.onSearch != null) widget.onSearch!('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint mobile/tablet vs Desktop
        final isMobile = constraints.maxWidth <= 900;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
          ),
        );
      },
    );
  }

  // --- LAYOUT UNTUK DESKTOP (Layar Lebar) ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 1. Logo Area
        SizedBox(
          height: 40,
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: NesaColors.terracotta,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),

        // 2. Menu Navigation (Teks)
        _MenuButton(
          label: 'Home',
          selected: widget.selectedIndex == 0,
          onTap: () => widget.onMenuTap(0),
        ),
        const SizedBox(width: 8),
        _MenuButton(
          label: 'Menu',
          selected: widget.selectedIndex == 1,
          onTap: () => widget.onMenuTap(1),
        ),
        const SizedBox(width: 8),
        _MenuButton(
          label: 'About',
          selected: widget.selectedIndex == 2,
          onTap: () => widget.onMenuTap(2),
        ),

        const Spacer(),

        // 3. Search Bar Panjang
        SizedBox(width: 280, child: _buildSearchField(isExpanded: true)),
        const SizedBox(width: 24),

        // 4. Cart & Profile
        _buildCartButton(),
        const SizedBox(width: 16),
        _buildProfileButton(),
      ],
    );
  }

  // --- LAYOUT UNTUK MOBILE (Layar Sempit) ---
  Widget _buildMobileLayout() {
    // Jika mode pencarian aktif di HP, tampilkan Search Bar full width
    if (_isMobileSearchActive) {
      return Row(
        children: [
          IconButton(
            onPressed: _toggleMobileSearch,
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          Expanded(child: _buildSearchField(isExpanded: true, autoFocus: true)),
        ],
      );
    }

    // Tampilan Normal Mobile
    return Row(
      children: [
        // Logo Saja
        SizedBox(
          height: 36,
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.fastfood, color: NesaColors.terracotta),
          ),
        ),

        const Spacer(),

        // Icon Search (bukan field panjang)
        IconButton(
          onPressed: _toggleMobileSearch,
          icon: const Icon(Icons.search, color: Colors.black87),
          tooltip: 'Search',
        ),

        // Cart
        _buildCartButton(),

        // Dropdown Menu (Pengganti tombol Home/Menu/About)
        PopupMenuButton<int>(
          icon: const Icon(Icons.menu_rounded, color: Colors.black87),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (index) {
            if (index == 99) {
              // Logic jika profile diklik di dalam menu (opsional)
              if (widget.onProfileTap != null) widget.onProfileTap!();
            } else {
              widget.onMenuTap(index);
            }
          },
          itemBuilder: (context) => [
            _buildPopupMenuItem(0, 'Home', Icons.home_rounded),
            _buildPopupMenuItem(1, 'Menu', Icons.restaurant_menu_rounded),
            _buildPopupMenuItem(2, 'About', Icons.info_rounded),
            const PopupMenuDivider(),
            // Opsi Profil di dalam menu hamburger juga untuk akses cepat
            PopupMenuItem(
              value: 99,
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: NesaColors.terracotta,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- WIDGET PENDUKUNG (REUSABLE) ---

  Widget _buildSearchField({bool isExpanded = false, bool autoFocus = false}) {
    return TextField(
      controller: _ctrl,
      autofocus: autoFocus,
      onChanged: (v) {
        if (widget.onSearch != null) widget.onSearch!(v);
        setState(() {});
      },
      onSubmitted: (v) {
        if (widget.onSearch != null) widget.onSearch!(v);
      },
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Cari makanan...',
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape
          borderSide: BorderSide.none,
        ),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () {
                  _ctrl.clear();
                  if (widget.onSearch != null) widget.onSearch!('');
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  Widget _buildCartButton() {
    return badges.Badge(
      showBadge: widget.cartCount > 0,
      position: badges.BadgePosition.topEnd(top: -2, end: -2),
      badgeStyle: const badges.BadgeStyle(badgeColor: NesaColors.terracotta),
      badgeContent: Text(
        '${widget.cartCount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: IconButton(
        onPressed: widget.onCartTap,
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
        tooltip: 'Keranjang',
      ),
    );
  }

  Widget _buildProfileButton() {
    return InkWell(
      onTap: widget.onProfileTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 20, color: NesaColors.terracotta),
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(
    int value,
    String label,
    IconData icon,
  ) {
    final isSelected = widget.selectedIndex == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? NesaColors.terracotta : Colors.black54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? NesaColors.terracotta : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget tombol menu untuk Desktop
class _MenuButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? NesaColors.terracotta.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? NesaColors.terracotta : Colors.black54,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
