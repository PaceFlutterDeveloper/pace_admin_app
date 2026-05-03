import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuComponent extends StatelessWidget {
  const MenuComponent({
    Key? key,
    required this.item,
  }) : super(key: key);

  final MenuModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Tile‐relative sizing:
          final iconSize = constraints.maxWidth * 0.5; // 40% of tile width
          final fontSize = constraints.maxWidth * 0.12; // 12% of tile width
          final padding = constraints.maxWidth * 0.05; // 5% of tile width
          final spacing = constraints.maxHeight * 0.05; // 5% of tile height

          return Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: ConstColors.whiteColor,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon (API tiles use network image; local tiles may omit URL)
                if (item.iconUrl.isEmpty)
                  Icon(
                    item.page == 'faceAttendance'
                        ? Icons.face_retouching_natural
                        : item.page == 'userAttendance'
                            ? Icons.calendar_month_rounded
                            : Icons.menu_book_outlined,
                    size: iconSize,
                    color: ConstColors.textDark,
                  )
                else
                  Image.network(
                    item.iconUrl,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),

                SizedBox(height: spacing),

                // Label, wrapped and ellipsized if too long
                Flexible(
                  child: Text(
                    item.menuName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
