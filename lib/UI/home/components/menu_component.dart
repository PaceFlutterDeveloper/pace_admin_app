import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuComponent extends StatelessWidget {
  const MenuComponent({
    super.key,
    required this.item,
  });

  final MenuModel item;

  IconData _getIconForPage(String? page) {
    switch (page) {
      case 'faceAttendance':
        return CupertinoIcons.person_crop_circle_badge_checkmark;
      case 'userAttendance':
        return CupertinoIcons.calendar;
      default:
        return CupertinoIcons.square_grid_2x2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: () {
        if (item.page == null || item.page!.isEmpty) {
          context.pushNamed(
            Routes.subMenuPage.name,
            extra: item,
          );
        } else {
          context.pushNamed(item.page!, extra: item);
        }
      },
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = constraints.maxWidth * 0.38;
          final fontSize = (constraints.maxWidth * 0.11).clamp(10.0, 14.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with subtle background
              Container(
                width: iconSize + 16,
                height: iconSize + 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: item.iconUrl.isEmpty
                      ? Icon(
                          _getIconForPage(item.page),
                          size: iconSize * 0.6,
                          color: theme.colorScheme.primary,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Image.network(
                            item.iconUrl,
                            width: iconSize * 0.7,
                            height: iconSize * 0.7,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              _getIconForPage(item.page),
                              size: iconSize * 0.6,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Label
              Text(
                item.menuName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
