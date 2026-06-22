import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplicationEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseJobs;

  const ApplicationEmptyState({super.key, this.onBrowseJobs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Applications Yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "You haven't applied to any jobs yet.\nStart exploring opportunities!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            if (onBrowseJobs != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'Browse Jobs',
                leadingIcon: CupertinoIcons.search,
                isFullWidth: false,
                onPressed: onBrowseJobs,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
