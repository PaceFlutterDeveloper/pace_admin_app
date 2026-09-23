import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareersScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool centerTitle;
  final VoidCallback? onTitleTap;

  const CareersScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.centerTitle = false,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _Title(
          title: title,
          color: theme.colorScheme.onSurface,
          onTap: onTitleTap,
        ),
        centerTitle: centerTitle,
        backgroundColor: isDark
            ? AppColors.surfaceContainerDark
            : AppColors.surfaceContainerLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface, size: 22),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _Title({required this.title, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      ),
    );
    if (onTap == null) return text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: text,
    );
  }
}
