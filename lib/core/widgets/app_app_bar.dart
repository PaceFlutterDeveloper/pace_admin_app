import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = AppBackButton(onPressed: onBackPressed);
    }

    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
                )
              : null),
      leading: leadingWidget,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: 0.5,
      bottom: bottom,
    );
  }
}

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: AppSizes.touchTarget,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      child: Icon(
        CupertinoIcons.back,
        size: 28,
        color: color ?? theme.colorScheme.primary,
      ),
    );
  }
}

class AppCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AppCloseButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: AppSizes.touchTarget,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      child: Icon(
        CupertinoIcons.xmark,
        size: 22,
        color: color ?? theme.colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}

class AppSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool pinned;
  final bool floating;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final Widget? bottom;

  const AppSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight = 120,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = AppBackButton(onPressed: onBackPressed);
    }

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      leading: leadingWidget,
      actions: actions,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      flexibleSpace: flexibleSpace ??
          FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.only(
              left: AppSpacing.md,
              bottom: AppSpacing.md,
              right: AppSpacing.md,
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            collapseMode: CollapseMode.pin,
          ),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: bottom!,
            )
          : null,
    );
  }
}

class AppLargeTitleScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double expandedHeight;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? tabBar;

  const AppLargeTitleScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showBackButton = true,
    this.onBackPressed,
    this.expandedHeight = 120,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.tabBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            AppSliverAppBar(
              title: title,
              actions: actions,
              showBackButton: showBackButton,
              onBackPressed: onBackPressed,
              expandedHeight: expandedHeight,
              bottom: tabBar,
            ),
          ];
        },
        body: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AppSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final Widget? leading;
  final List<Widget>? actions;

  const AppSearchAppBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = true,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      leading: leading ?? const AppBackButton(),
      titleSpacing: 0,
      title: Container(
        height: 36,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHigh
              : AppColors.iosSystemGray6,
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Search...',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.iosSystemGray,
            ),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              size: 20,
              color: AppColors.iosSystemGray,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
            ),
            suffixIcon: controller != null && controller!.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller?.clear();
                      onClear?.call();
                    },
                    child: const Icon(
                      CupertinoIcons.clear_circled_solid,
                      size: 18,
                      color: AppColors.iosSystemGray3,
                    ),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
        ),
      ),
      actions: actions,
    );
  }
}
