import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CareersButton extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool showAsCard;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const CareersButton({
    Key? key,
    this.title,
    this.subtitle,
    this.icon,
    this.showAsCard = true,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final buttonTitle = title ?? 'Careers';
    final buttonSubtitle = subtitle ?? 'Explore job opportunities';
    final buttonIcon = icon ?? Icons.work_outline;

    if (showAsCard) {
      return SizedBox(
        child: GestureDetector(
          onTap: () {
            context.pushNamed('careers');
          },
          child: Container(
            padding: padding ?? EdgeInsets.all(w * 0.03),
            decoration: BoxDecoration(
              color: ConstColors.whiteColor,
              borderRadius: BorderRadius.circular(w * 0.03),
              border: Border.all(
                color: ConstColors.borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(w * 0.03),
                  decoration: BoxDecoration(
                    color: ConstColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(w * 0.02),
                  ),
                  child: Icon(
                    buttonIcon,
                    size: w * 0.06,
                    color: ConstColors.primary,
                  ),
                ),

                SizedBox(width: w * 0.03),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buttonTitle,
                        style: TextStyle(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w700,
                          color: ConstColors.textDark,
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      Text(
                        buttonSubtitle,
                        style: TextStyle(
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.w400,
                          color: ConstColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: w * 0.04,
                  color: ConstColors.textLight,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Simple button style
      return GestureDetector(
        onTap: () {
          context.pushNamed('careers');
        },
        child: Container(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: w * 0.06,
                vertical: h * 0.015,
              ),
          margin: margin,
          decoration: BoxDecoration(
            color: ConstColors.primary,
            borderRadius: BorderRadius.circular(w * 0.025),
            boxShadow: [
              BoxShadow(
                color: ConstColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                buttonIcon,
                size: w * 0.05,
                color: ConstColors.whiteColor,
              ),
              SizedBox(width: w * 0.02),
              Text(
                buttonTitle,
                style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w600,
                  color: ConstColors.whiteColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// Alternative floating action button style
class CareersFloatingButton extends StatelessWidget {
  const CareersFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return FloatingActionButton.extended(
      onPressed: () {
        context.pushNamed(Routes.careers.name);
      },
      backgroundColor: ConstColors.primary,
      icon: const Icon(Icons.work_outline, color: Colors.white),
      label: Text(
        'Careers',
        style: TextStyle(
          fontSize: w * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Menu-style button similar to MenuComponent
class CareersMenuButton extends StatelessWidget {
  const CareersMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('careers');
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Tile-relative sizing:
          final iconSize = constraints.maxWidth * 0.5; // 50% of tile width
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
                // Icon
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: ConstColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(iconSize * 0.2),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    size: iconSize * 0.6,
                    color: ConstColors.primary,
                  ),
                ),

                SizedBox(height: spacing),

                // Label
                Flexible(
                  child: Text(
                    'Careers',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: ConstColors.textDark,
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
