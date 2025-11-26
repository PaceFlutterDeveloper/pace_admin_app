import 'dart:convert';

class MenuModel {
  final String id;
  final String menuKey;
  final String menuVal;
  final String menuName;
  final String? page;
  final String iconUrl;
  final String parentId;
  final List<MenuModel> subMenu;

  MenuModel({
    required this.id,
    required this.menuKey,
    required this.menuVal,
    required this.menuName,
    required this.page,
    required this.iconUrl,
    required this.parentId,
    required this.subMenu,
  });

  factory MenuModel.fromJson(String str) => MenuModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MenuModel.fromMap(Map<String, dynamic> json) => MenuModel(
        id: json["id"].toString(),
        menuKey: json["menu_key"].toString(),
        menuVal: json["menu_val"],
        menuName: json["menu_name"],
        page: json["page"],
        iconUrl: json["icon_url"],
        parentId: json["parent_id"],
        subMenu: json["sub_menu"] != null
            ? List<MenuModel>.from(
                json["sub_menu"].map((x) => MenuModel.fromMap(x)))
            : [],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "menu_key": menuKey,
        "menu_val": menuVal,
        "menu_name": menuName,
        "page": page,
        "icon_url": iconUrl,
        "parent_id": parentId,
        "sub_menu": List<dynamic>.from(subMenu.map((x) => x)),
      };
}
