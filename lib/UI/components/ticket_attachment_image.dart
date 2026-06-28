import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:flutter/material.dart';

/// Displays a ticket attachment with bounded layout, loading placeholder,
/// error fallback, and tap-to-zoom.
class TicketAttachmentImage extends StatelessWidget {
  final String url;

  const TicketAttachmentImage({super.key, required this.url});

  void _openFullScreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const AppLoadingIndicator(size: 32);
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.7),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cacheWidth =
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context))
            .round();

    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return ColoredBox(
                color: colors.surfaceContainer,
                child: const Center(
                  child: AppLoadingIndicator(size: 24, strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: colors.surfaceContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: colors.textSecondary,
                    ),
                    AppSpacing.vGapSm,
                    Text(
                      'Unable to load image',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
