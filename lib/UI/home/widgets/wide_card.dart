import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class WideCard extends StatefulWidget {
  const WideCard({
    super.key,
    required this.iconBg,
    required this.iconData,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final Color iconBg;
  final IconData iconData;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  State<WideCard> createState() => _WideCardState();
}

class _WideCardState extends State<WideCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppDurations.fast,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 6,
            vertical: AppSpacing.sm + 4,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.iconData,
                  color: widget.iconColor,
                  size: 20,
                ),
              ),
              const Gap(AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
