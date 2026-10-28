import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

MenuModel? menuForPage(List<MenuModel> menus, String page) {
  for (final m in menus) {
    if (m.page == page) return m;
    final nested = menuForPage(m.subMenu, page);
    if (nested != null) return nested;
  }
  return null;
}

/// True when [page] is a named route this app can open.
bool staffRouteExists(String? page) {
  final name = page?.trim() ?? '';
  if (name.isEmpty) return false;
  for (final route in Routes.values) {
    if (route.name == name) return true;
  }
  return false;
}

/// The API listed a page the installed app has no screen for yet.
bool menuOpensSoon(MenuModel item) {
  final page = item.page?.trim() ?? '';
  return page.isNotEmpty && !staffRouteExists(page);
}

MenuModel fallbackMenu({required String page, required String menuName}) {
  return MenuModel(
    id: 'local-$page',
    menuKey: page,
    menuVal: page,
    menuName: menuName,
    page: page,
    iconUrl: '',
    parentId: '',
    subMenu: const [],
  );
}

/// Back control for a page opened from somewhere else.
/// Hidden on a dock tab, because that switch has nothing to pop.
Widget? staffOriginBack(BuildContext context) {
  if (!context.canPop()) return null;
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: StaffIconButton(
      glyph: StaffGlyphs.chevronLeft,
      semanticLabel: 'Back',
      onTap: () => context.pop(),
    ),
  );
}

/// Opens a top-level menu route with API [menus] when present, else [fallbackName].
void pushMenuPage(
  BuildContext context,
  List<MenuModel> menus,
  String page,
  String fallbackName,
) {
  final item =
      menuForPage(menus, page) ??
      fallbackMenu(page: page, menuName: fallbackName);
  final routeName = item.page;
  if (routeName == null || routeName.isEmpty) {
    context.pushNamed(Routes.subMenuPage.name, extra: item);
    return;
  }
  context.pushNamed(routeName, extra: item);
}

/// Opens an API menu item: its route when it has a page, else its sub menu.
void openMenuItem(BuildContext context, MenuModel item) {
  final page = item.page;
  if (page == null || page.isEmpty) {
    context.pushNamed(Routes.subMenuPage.name, extra: item);
    return;
  }
  context.pushNamed(page, extra: item);
}
