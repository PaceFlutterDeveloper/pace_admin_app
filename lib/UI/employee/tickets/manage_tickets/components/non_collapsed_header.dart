import 'package:admin_app/UI/employee/tickets/manage_tickets/components/build_status_tile.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class NonCollapsedHeader extends StatelessWidget {
  final int all;
  final int inProgress;
  final int finished;
  final double topPadding;

  const NonCollapsedHeader({
    Key? key,
    required this.topPadding,
    required this.all,
    required this.inProgress,
    required this.finished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // adjust these ratios as needed
    final horizontalMargin = w * 0.04; // ~16px on a 400px-wide device
    final backgroundBottom = h * 0.10; // ~60px on a 600px-high device
    final headerTopOffset = topPadding + h * 0.02; // ~8px + safe-area
    final cardTopOffset = topPadding + h * 0.06; // ~44px + safe-area
    final cardPadding = w * 0.04; // ~16px
    final iconSize = w * 0.07; // ~28px
    final titleFontSize = w * 0.045; // ~18px
    final subtitleFontSize = w * 0.035; // ~14px
    final tileFontSize = w * 0.04; // ~16px
    final borderRadius = w * 0.08; // ~32px

    return Stack(
      children: [
        // Purple header background
        Positioned.fill(
          bottom: backgroundBottom,
          child: Container(
            decoration: BoxDecoration(
              color: ConstColors.purple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
            ),
          ),
        ),

        // Back button + title
        Positioned(
          top: headerTopOffset,
          left: horizontalMargin,
          right: horizontalMargin,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: ConstColors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(width: w * 0.03),
              Text(
                'Manage Your Tickets',
                style: TextStyle(
                  color: ConstColors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // White summary card
        Positioned(
          top: cardTopOffset,
          left: horizontalMargin,
          right: horizontalMargin,
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: ConstColors.white,
              borderRadius: BorderRadius.circular(w * 0.04),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: w * 0.02,
                  offset: Offset(0, w * 0.01),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary of Your Work',
                  style: TextStyle(
                    color: ConstColors.textDark,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h * 0.005),
                Text(
                  'Your current ticket progress',
                  style: TextStyle(
                    color: ConstColors.textLight,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: h * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: BuildStatusTile(
                        icon: Icons.list_alt,
                        label: 'To Do',
                        count: all,
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    Expanded(
                      child: BuildStatusTile(
                        icon: Icons.timelapse,
                        label: 'In Progress',
                        count: inProgress,
                        iconColor: const Color(0xFFF79009),
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    Expanded(
                      child: BuildStatusTile(
                        icon: Icons.check_circle,
                        label: 'Done',
                        count: finished,
                        iconColor: const Color(0xFF19B36E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
