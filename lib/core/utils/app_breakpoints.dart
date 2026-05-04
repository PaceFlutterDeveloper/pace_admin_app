import 'package:flutter/material.dart';

import '../../config/themes/app_design_tokens.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double compactMaxWidth = 600;
  static const double mediumMaxWidth = 900;
  static const double expandedMaxWidth = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < compactMaxWidth;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compactMaxWidth && width < mediumMaxWidth;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= mediumMaxWidth;

  static bool isMediumOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= compactMaxWidth;

  static bool isExpandedOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= mediumMaxWidth;

  static ScreenSize screenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactMaxWidth) return ScreenSize.compact;
    if (width < mediumMaxWidth) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static T valueForScreen<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
  }) {
    final size = screenSize(context);
    switch (size) {
      case ScreenSize.compact:
        return compact;
      case ScreenSize.medium:
        return medium ?? compact;
      case ScreenSize.expanded:
        return expanded ?? medium ?? compact;
    }
  }

  static double responsivePadding(BuildContext context) {
    return valueForScreen(
      context,
      compact: AppSpacing.md,
      medium: AppSpacing.lg,
      expanded: AppSpacing.xl,
    );
  }

  static int gridCrossAxisCount(BuildContext context) {
    return valueForScreen(
      context,
      compact: 1,
      medium: 2,
      expanded: 3,
    );
  }
}

enum ScreenSize {
  compact,
  medium,
  expanded,
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, AppBreakpoints.screenSize(context));
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return AppBreakpoints.valueForScreen(
      context,
      compact: compact,
      medium: medium,
      expanded: expanded,
    );
  }
}

class AppContentConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const AppContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = AppSizes.maxContentWidth,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    if (center) {
      content = Center(child: content);
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}

class AppSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  const AppSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: child,
    );
  }
}

class AppPagePadding extends StatelessWidget {
  final Widget child;
  final bool horizontal;
  final bool vertical;
  final bool responsive;

  const AppPagePadding({
    super.key,
    required this.child,
    this.horizontal = true,
    this.vertical = false,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final padding = responsive
        ? AppBreakpoints.responsivePadding(context)
        : AppSpacing.md;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ? padding : 0,
        vertical: vertical ? padding : 0,
      ),
      child: child,
    );
  }
}

class AppScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool primary;
  final Axis scrollDirection;

  const AppScrollView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.primary = true,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      primary: primary && controller == null,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      scrollDirection: scrollDirection,
      padding: padding,
      child: child,
    );
  }
}

class AppListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  const AppListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && loadingWidget != null) {
      return loadingWidget!;
    }

    if (items.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    Widget listView;
    if (separatorBuilder != null) {
      listView = ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: separatorBuilder!,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          if (index == items.length - 1 && onLoadMore != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore!();
            });
          }

          return itemBuilder(context, items[index], index);
        },
      );
    } else {
      listView = ListView.builder(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          if (index == items.length - 1 && onLoadMore != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore!();
            });
          }

          return itemBuilder(context, items[index], index);
        },
      );
    }

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}
