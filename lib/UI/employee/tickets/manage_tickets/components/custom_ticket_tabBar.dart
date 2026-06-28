import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

/// Segmented tab bar for manage tickets: All, In Progress, Finish.
class CustomTicketTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int allCount;
  final int inProgressCount;
  final int finishCount;

  const CustomTicketTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.allCount,
    required this.inProgressCount,
    required this.finishCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final primary = theme.colorScheme.primary;
    final cardShadow = AppThemeExtension.of(context).cardShadow;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final barHeight = h * 0.06;
    final horizontalPadding = w * 0.04;
    final verticalPadding = h * 0.015;
    final borderRadius = barHeight * 0.5;
    final labelFontSize = w * 0.035;
    final badgeSize = barHeight * 0.5;
    final badgeFontSize = badgeSize * 0.6;
    final itemSpacing = w * 0.02;

    Widget buildTab({
      required String label,
      required int count,
      required bool isSelected,
      required Color selectedBadgeColor,
      BorderRadius? radius,
      required int tabIndex,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: () => onTabChanged(tabIndex),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: isSelected ? primary : Colors.transparent,
              borderRadius: radius,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : colors.textSecondary,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: itemSpacing),
                  Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedBadgeColor
                          : colors.systemGray4,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
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
          color: theme.cardTheme.color ?? colors.card,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: cardShadow,
        ),
        child: Row(
          children: [
            buildTab(
              label: 'All',
              count: allCount,
              isSelected: selectedIndex == 0,
              selectedBadgeColor: colors.systemGray3,
              tabIndex: 0,
              radius: BorderRadius.horizontal(
                left: Radius.circular(borderRadius),
              ),
            ),
            buildTab(
              label: 'In Progress',
              count: inProgressCount,
              isSelected: selectedIndex == 1,
              selectedBadgeColor: colors.error,
              tabIndex: 1,
            ),
            buildTab(
              label: 'Finish',
              count: finishCount,
              isSelected: selectedIndex == 2,
              selectedBadgeColor: colors.systemGray3,
              tabIndex: 2,
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
