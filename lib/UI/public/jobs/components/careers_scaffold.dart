import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CareersScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool centerTitle;
  final VoidCallback? onTitleTap;

  /// Hides the app bar when the screen provides its own hero header.
  final bool showAppBar;

  /// Pace Group mark beside the title, with the title set in block capitals.
  final bool brandedTitle;

  const CareersScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.centerTitle = false,
    this.onTitleTap,
    this.showAppBar = true,
    this.brandedTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CareersColors.background,
      appBar: showAppBar
          ? AppBar(
              title: _Title(
                title: title,
                onTap: onTitleTap,
                branded: brandedTitle,
              ),
              centerTitle: centerTitle,
              titleSpacing: CareersSpacing.screenH,
              backgroundColor: CareersColors.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              iconTheme: const IconThemeData(
                color: CareersColors.textPrimary,
                size: 22,
              ),
              shape: const Border(
                bottom: BorderSide(color: CareersColors.divider),
              ),
              actions: [
                ...?actions,
                const SizedBox(width: CareersSpacing.screenH - 8),
              ],
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool branded;

  const _Title({required this.title, this.onTap, this.branded = false});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).appBarTheme.titleTextStyle;
    final text = Text(
      branded ? title.toUpperCase() : title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: branded
          ? base?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 1.15,
              height: 1,
            )
          : base,
    );

    final child = branded
        ? Row(
            children: [
              Image.asset(
                'assets/logo/group.png',
                height: 35,
                fit: BoxFit.contain,
                semanticLabel: 'Pace Group',
              ),
              const SizedBox(width: 10),
              Expanded(child: text),
            ],
          )
        : text;

    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
