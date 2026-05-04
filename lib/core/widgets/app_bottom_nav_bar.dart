import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final effectiveBgColor = backgroundColor ??
        (isDark ? AppColors.cardDark : Colors.white);
    final effectiveSelectedColor = selectedColor ?? primaryColor;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.iosSystemGray;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _NavBarItem(
                  icon: isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  selectedColor: effectiveSelectedColor,
                  unselectedColor: effectiveUnselectedColor,
                  badgeCount: item.badgeCount,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    this.badgeCount,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? widget.selectedColor : widget.unselectedColor;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: AppDurations.fast,
                    child: Icon(
                      widget.icon,
                      key: ValueKey('${widget.icon}_${widget.isSelected}'),
                      size: 24,
                      color: color,
                    ),
                  ),
                  if (widget.badgeCount != null && widget.badgeCount! > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                          color: AppColors.iosRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.badgeCount! > 99 ? '99+' : '${widget.badgeCount}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppDurations.fast,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomNavShell extends StatefulWidget {
  final List<AppBottomNavItem> items;
  final List<Widget> pages;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  const AppBottomNavShell({
    super.key,
    required this.items,
    required this.pages,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<AppBottomNavShell> createState() => _AppBottomNavShellState();
}

class _AppBottomNavShellState extends State<AppBottomNavShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      widget.onIndexChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppDurations.normal,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: widget.pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: widget.items,
      ),
    );
  }
}
