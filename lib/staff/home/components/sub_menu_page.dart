import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/home/menu/staff_menu_catalog.dart';
import 'package:admin_app/staff/home/menu/staff_menu_tile.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Children of a grouped menu item, shown with the same glass tiles as Menu.
class SubMenuPage extends StatelessWidget {
  final MenuModel menuModel;
  const SubMenuPage({super.key, required this.menuModel});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final items = [
      for (final item in menuModel.subMenu)
        if (!item.isInternalWeb || (item.webUrl?.trim().isNotEmpty ?? false))
          item,
    ];

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                StaffIconButton(
                  glyph: StaffGlyphs.chevronLeft,
                  semanticLabel: 'Back',
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    menuModel.menuName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(
                      22,
                      weight: FontWeight.w700,
                      color: p.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const StaffStateMessage(
                    glyph: StaffGlyphs.grid,
                    title: 'Nothing here yet',
                    message:
                        'No modules are available in this group for your role.',
                  )
                : BlocBuilder<DashboardCubit, StaffDashboard?>(
                    bloc: locator<DashboardCubit>(),
                    builder: (context, dashboard) {
                      final pending = dashboard?.tasksPending;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                        gridDelegate: staffMenuGridDelegate(context),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final style = staffMenuStyleFor(item);
                          return StaffMenuTile(
                            label: item.menuName.trim().isNotEmpty
                                ? item.menuName
                                : item.menuVal,
                            glyph: style.glyph,
                            accent: style.accent,
                            iconUrl: item.networkIconUrl,
                            soon: menuOpensSoon(item),
                            badge: item.page == 'tasks' && pending != null
                                ? pending
                                : item.badge,
                            onTap: () => openStaffMenu(context, item),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
