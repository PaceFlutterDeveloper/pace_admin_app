import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareersBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CareersBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context) {
    final palette = context.careers;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.divider)),
        boxShadow: [
          BoxShadow(
            color: palette.isDark
                ? const Color(0x59000000)
                : const Color(0x0A0F172A),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            children: [
              _NavItem(
                icon: CupertinoIcons.house,
                activeIcon: CupertinoIcons.house_fill,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: CupertinoIcons.doc_text,
                activeIcon: CupertinoIcons.doc_text_fill,
                label: 'Applications',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: CupertinoIcons.person,
                activeIcon: CupertinoIcons.person_fill,
                label: 'Profile',
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final palette = context.careers;
    final color = isSelected ? palette.accentText : palette.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: palette.primarySoft,
          highlightColor: palette.primarySoft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? palette.primarySoft : Colors.transparent,
                  borderRadius: CareersRadius.pillAll,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.0,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
