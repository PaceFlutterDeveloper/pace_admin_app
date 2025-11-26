import 'package:flutter/material.dart';

/// A pill-shaped tab bar with three segments: “All”, “In Progress”, and “Finish”.
/// Each tab shows a circular badge with a count. The selected tab is purple;
/// unselected tabs are white with gray text and gray badge.
class CustomTicketTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int allCount;
  final int inProgressCount;
  final int finishCount;

  const CustomTicketTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.allCount,
    required this.inProgressCount,
    required this.finishCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive constants (tweak as needed)
    final barHeight = h * 0.06; // ~40px on a 700px-high screen
    final horizontalPadding = w * 0.04; // ~16px on a 400px-wide screen
    final verticalPadding = h * 0.015; // ~10px
    final borderRadius = barHeight * 0.5;
    final labelFontSize = w * 0.035; // ~14px
    final badgeSize = barHeight * 0.5;
    final badgeFontSize = badgeSize * 0.6;
    final itemSpacing = w * 0.02; // space between text & badge

    const purple = Color(0xFF6A4CFF);
    const grayText = Color(0xFF6E6E6E);
    const badgeGray = Color(0xFFD0D0D0);
    const badgeRed = Color(0xFFE74C3C);

    Widget buildTab({
      required String label,
      required int count,
      required bool isSelected,
      required Color selectedBadgeColor,
      BorderRadius? radius,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: () => onTabChanged(
            label == 'All'
                ? 0
                : label == 'In Progress'
                    ? 1
                    : 2,
          ),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: isSelected ? purple : Colors.transparent,
              borderRadius: radius,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : grayText,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: itemSpacing),

                  // Badge
                  Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      color: isSelected ? selectedBadgeColor : badgeGray,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: badgeFontSize,
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: barHeight * 0.15,
              offset: Offset(0, barHeight * 0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            // ALL
            buildTab(
              label: 'All',
              count: allCount,
              isSelected: selectedIndex == 0,
              selectedBadgeColor: badgeGray,
              radius: BorderRadius.horizontal(
                left: Radius.circular(borderRadius),
              ),
            ),

            // IN PROGRESS
            buildTab(
              label: 'In Progress',
              count: inProgressCount,
              isSelected: selectedIndex == 1,
              selectedBadgeColor: badgeRed,
            ),

            // FINISH
            buildTab(
              label: 'Finish',
              count: finishCount,
              isSelected: selectedIndex == 2,
              selectedBadgeColor: badgeGray,
              radius: BorderRadius.horizontal(
                right: Radius.circular(borderRadius),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
