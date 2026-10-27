import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/home/utils/active_staff_user.dart';
import 'package:admin_app/staff/notification/components/notification_panel.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Home header: school mark, greeting, school name and the notification bell.
class DashboardHomeHeader extends StatelessWidget {
  const DashboardHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: staffSessionListenable(),
      builder: (context, box, _) {
        final user = activeStaffUser();
        final first = firstNameOf(user.name);
        final school = user.schoolName.trim().isNotEmpty
            ? user.schoolName.trim()
            : 'PACE International';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              SchoolMark(logoUrl: user.logo, schoolName: school),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      first.isNotEmpty
                          ? '${greetingForNow()}, $first'
                          : greetingForNow(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(12, weight: FontWeight.w400, color: p.muted),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      school,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(
                        15,
                        weight: FontWeight.w700,
                        color: p.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StaffIconButton(
                glyph: StaffGlyphs.bell,
                semanticLabel: 'Notifications',
                showDot: user.notificationCount > 0,
                onTap: () => showStaffNotificationPanel(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Amber school tile: the school logo when available, else initials.
class SchoolMark extends StatelessWidget {
  const SchoolMark({
    super.key,
    required this.logoUrl,
    required this.schoolName,
  });

  final String logoUrl;
  final String schoolName;

  static String initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'P';
    return words.take(3).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final initials = Center(
      child: Text(
        initialsOf(schoolName),
        style: sora(12.5, weight: FontWeight.w800, color: p.onAmber),
      ),
    );
    final hasLogo = logoUrl.trim().isNotEmpty;

    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: hasLogo ? p.surface : p.amber,
        borderRadius: BorderRadius.circular(15),
        border: hasLogo ? Border.all(color: p.border) : null,
      ),
      child: hasLogo
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: p.amber, child: initials),
            )
          : initials,
    );
  }
}
