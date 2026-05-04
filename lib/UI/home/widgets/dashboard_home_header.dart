import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

String greetingForNow() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

class DashboardHomeHeader extends StatelessWidget {
  const DashboardHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: locator<Box<AuthModel>>().listenable(),
      builder: (context, box, _) {
        final user = box.values.firstWhere(
          (u) => u.isActive,
          orElse: () => AuthModel.empty(),
        );

        final first = user.name.trim().split(RegExp(r'\s+')).firstWhere(
              (e) => e.isNotEmpty,
              orElse: () => '',
            );

        final theme = Theme.of(context);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  _SchoolLogoMark(logoUrl: user.logo, schoolName: user.schoolName),
                  const Gap(AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          first.isNotEmpty
                              ? '${greetingForNow()}, $first'
                              : greetingForNow(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                        Text(
                          user.schoolName.isNotEmpty
                              ? user.schoolName
                              : 'PACE International',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _NotificationBell(
              unreadCount: user.notificationCount,
            ),
          ],
        );
      },
    );
  }
}

class _SchoolLogoMark extends StatelessWidget {
  const _SchoolLogoMark({
    required this.logoUrl,
    required this.schoolName,
  });

  final String logoUrl;
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    const radius = 10.0;
    final initial =
        schoolName.isNotEmpty ? schoolName.substring(0, 1).toUpperCase() : 'P';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl.isNotEmpty
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.unreadCount,
  });

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bellBg = theme.colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(Routes.getNotifications.path),
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bellBg,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  CupertinoIcons.bell,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: AppSpacing.sm,
                    height: AppSpacing.sm,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: bellBg,
                        width: 1.5,
                      ),
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
