import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

MenuModel? menuForPage(List<MenuModel> menus, String page) {
  for (final m in menus) {
    if (m.page == page) return m;
  }
  return null;
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

/// Opens a top-level menu route with API [menus] when present, else [fallbackName].
void pushMenuPage(
  BuildContext context,
  List<MenuModel> menus,
  String page,
  String fallbackName,
) {
  final item = menuForPage(menus, page) ??
      fallbackMenu(page: page, menuName: fallbackName);
  final routeName = item.page;
  if (routeName == null || routeName.isEmpty) {
    context.pushNamed(Routes.subMenuPage.name, extra: item);
    return;
  }
  context.pushNamed(routeName, extra: item);
}
