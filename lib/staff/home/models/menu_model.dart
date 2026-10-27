import 'dart:convert';

class MenuModel {
  final String id;
  final String menuKey;
  final String menuVal;
  final String menuName;
  final String? page;
  final String iconUrl;
  final String parentId;
  final int pos;
  final int badge;
  final List<MenuModel> subMenu;

  MenuModel({
    required this.id,
    required this.menuKey,
    required this.menuVal,
    required this.menuName,
    required this.page,
    required this.iconUrl,
    required this.parentId,
    this.pos = 0,
    this.badge = 0,
    required this.subMenu,
  });

  factory MenuModel.fromJson(String str) => MenuModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MenuModel.fromMap(Map<String, dynamic> json) => MenuModel(
    id: _menuString(json["id"]),
    menuKey: _menuString(json["menu_key"]),
    menuVal: _menuString(json["menu_val"]),
    menuName: _menuString(json["menu_name"]),
    page: json["page"] == null ? null : json["page"].toString(),
    iconUrl: _menuString(json["icon_url"]),
    parentId: _menuString(json["parent_id"]),
    pos: _menuInt(json["pos"]),
    badge: _menuInt(json["badge"]),
    subMenu: _menuChildren(json["sub_menu"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "menu_key": menuKey,
    "menu_val": menuVal,
    "menu_name": menuName,
    "page": page,
    "icon_url": iconUrl,
    "parent_id": parentId,
    "pos": pos,
    "badge": badge,
    "sub_menu": subMenu.map((x) => x.toMap()).toList(),
  };
}

String _menuString(dynamic value) => value == null ? '' : value.toString();

int _menuInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

List<MenuModel> _menuChildren(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) MenuModel.fromMap(Map<String, dynamic>.from(item)),
  ];
}
