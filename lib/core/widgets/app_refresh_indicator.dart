import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/themes/app_design_tokens.dart';

class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? primaryColor,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: 2.5,
      child: child,
    );
  }
}

class AppCupertinoRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppCupertinoRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverToBoxAdapter(child: child),
      ],
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? barrierColor;
  final Widget? loadingWidget;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.barrierColor,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: AppDurations.fast,
              opacity: isLoading ? 1.0 : 0.0,
              child: Container(
                color: barrierColor ?? Colors.black.withOpacity(0.3),
                alignment: Alignment.center,
                child: loadingWidget ?? const AppLoadingIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
          color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class AppLoadingPage extends StatelessWidget {
  final Color? backgroundColor;

  const AppLoadingPage({
    super.key,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      body: const Center(
        child: AppLoadingIndicator(),
      ),
    );
  }
}

class AppPaginationLoader extends StatelessWidget {
  final bool isLoading;

  const AppPaginationLoader({
    super.key,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      alignment: Alignment.center,
      child: const AppLoadingIndicator(size: 24, strokeWidth: 2.5),
    );
  }
}

class AppInlineLoader extends StatelessWidget {
  final String? message;
  final double size;

  const AppInlineLoader({
    super.key,
    this.message,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        if (message != null) ...[
          AppSpacing.hGapSm,
          Text(
            message!,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
