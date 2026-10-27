import 'package:admin_app/staff/home/menu/staff_menu_catalog.dart';
import 'package:admin_app/staff/home/menu/staff_menu_tile.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Children of a grouped menu item, shown with the same glass tiles as Menu.
class SubMenuPage extends StatelessWidget {
  final MenuModel menuModel;
  const SubMenuPage({super.key, required this.menuModel});

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final items = menuModel.subMenu;

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
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    gridDelegate: staffMenuGridDelegate(context),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final style = staffMenuStyleFor(item);
                      return StaffMenuTile(
                        label: item.menuName,
                        glyph: style.glyph,
                        accent: style.accent,
                        soon: menuOpensSoon(item),
                        badge: item.badge,
                        onTap: () => openStaffMenu(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
