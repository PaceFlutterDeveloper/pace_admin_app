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

  /// Page opened inside the app when [isInternalWeb] is true.
  /// Prefer `url`; `web_url` is used when `url` is absent.
  final String? webUrl;

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
    this.webUrl,
  });

  /// Backend key for a page hosted on the server and opened in the app.
  bool get isInternalWeb => isInternalWebKey(menuKey);

  /// Icon URL for an internal-web tile. Other modules keep their glyphs.
  String? get networkIconUrl {
    if (!isInternalWeb) return null;
    final url = iconUrl.trim();
    return url.isEmpty ? null : url;
  }

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
    webUrl: _menuWebUrl(json),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "menu_key": menuKey,
    "menu_val": menuVal,
    "menu_name": menuName,
    "page": page,
    "icon_url": iconUrl,
    "url": webUrl,
    "parent_id": parentId,
    "pos": pos,
    "badge": badge,
    "sub_menu": subMenu.map((x) => x.toMap()).toList(),
  };
}

/// `internalWeb`, `internal_web`, and `internal web` are the same key.
bool isInternalWebKey(String key) {
  final compact = key.trim().toLowerCase().replaceAll(RegExp(r'[\s_]+'), '');
  return compact == 'internalweb';
}

String _menuString(dynamic value) => value == null ? '' : value.toString();

String? _menuWebUrl(Map<String, dynamic> json) {
  final url = _menuString(json['url']);
  if (url.isNotEmpty) return url;
  final fallback = _menuString(json['web_url']);
  return fallback.isEmpty ? null : fallback;
}

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
