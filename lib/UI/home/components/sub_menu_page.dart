import 'package:admin_app/UI/home/components/menu_component.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class SubMenuPage extends StatelessWidget {
  final MenuModel menuModel;
  const SubMenuPage({super.key, required this.menuModel});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(menuModel.menuName),
      ),
      backgroundColor: ConstColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.03,
        ),
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.015,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 1200
                ? 6
                : screenWidth > 900
                    ? 4
                    : 3,
            crossAxisSpacing: screenWidth * 0.02,
            mainAxisSpacing: screenHeight * 0.02,
            childAspectRatio: screenWidth > 600 ? 1.2 : 1.0,
          ),
          itemBuilder: (context, index) {
            final item = menuModel.subMenu[index];

            return MenuComponent(
              item: item,
            );
          },
          itemCount: menuModel.subMenu.length,
        ),
      ),
    );
  }
}
