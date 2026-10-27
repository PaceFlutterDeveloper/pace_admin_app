import 'package:admin_app/careers/jobs/components/shared/aed_currency_icon.dart';
import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/jobs/utils/job_date_format.dart';
import 'package:admin_app/careers/jobs/utils/job_share.dart';
import 'package:admin_app/careers/shared/components/careers_status_chip.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The canonical job card. Used by every list that shows jobs so radius,
/// padding, typography and shadow never drift between screens.
class CareersJobCard extends StatelessWidget {
  final JobModel job;

  const CareersJobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.careers;
    final postedLabel = JobDateFormat.relative(job.postedDate);
    final isClosed = !job.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: CareersRadius.cardAll,
          boxShadow: palette.cardShadow,
        ),
        child: Material(
          color: palette.surface,
          borderRadius: CareersRadius.cardAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                context.pushNamed(Routes.jobDetail.name, extra: job.jobId),
            splashColor: palette.primarySoft,
            highlightColor: palette.primarySoft,
            child: Container(
              padding: const EdgeInsets.all(CareersSpacing.cardPadding),
              decoration: BoxDecoration(
                borderRadius: CareersRadius.cardAll,
                border: Border.all(color: palette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SchoolBadge(
                        name: job.schoolName,
                        logoUrl: job.schoolLogo,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // The job title is the strongest element on the card.
                            Text(
                              job.title,
                              style: textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (job.schoolName.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                job.schoolName,
                                style: textTheme.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      _ShareButton(job: job),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (job.location.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 13,
                          color: palette.textTertiary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            job.location,
                            style: textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (postedLabel != null)
                          Text(postedLabel, style: textTheme.bodySmall),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (isClosed) CareersStatusChip.job(job.status),
                      if (job.employmentType.isNotEmpty)
                        CareersMetaChip(
                          label: job.employmentType,
                          icon: CupertinoIcons.briefcase,
                        ),
                      if ((job.salary?.minYears ?? 0) > 0)
                        CareersMetaChip(
                          label: '${job.salary!.minYears}+ yrs',
                          icon: CupertinoIcons.chart_bar,
                        ),
                      if (job.salaryRange.isNotEmpty) _SalaryChip(job: job),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// School logo from the jobs API. Falls back to the school initial when the
/// URL is missing or the image fails to load.
class _SchoolBadge extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _SchoolBadge({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '#' : trimmed[0].toUpperCase();
    final url = logoUrl?.trim() ?? '';
    final palette = context.careers;

    return Container(
      width: 46,
      height: 46,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // School logos are usually dark artwork on transparency, so they
        // keep a light plate in both themes.
        color: palette.isDark ? Colors.white : palette.surface,
        borderRadius: BorderRadius.circular(CareersRadius.chip),
        border: Border.all(color: palette.border),
      ),
      child: url.isEmpty
          ? _Initial(initial)
          : Padding(
              padding: const EdgeInsets.all(4),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _Initial(initial),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String initial;

  const _Initial(this.initial);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(gradient: CareersGradients.cta),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: CareersColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final JobModel job;

  const _ShareButton({required this.job});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      tooltip: 'Share job',
      onPressed: () => JobShare.share(context, job),
      icon: Icon(
        Icons.share_outlined,
        size: 18,
        color: context.careers.textTertiary,
      ),
    );
  }
}

class _SalaryChip extends StatelessWidget {
  final JobModel job;

  const _SalaryChip({required this.job});

  @override
  Widget build(BuildContext context) {
    final isDark = context.careers.isDark;
    final accent = isDark ? const Color(0xFF6EE7B7) : CareersColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: CareersRadius.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AedCurrencyIcon(color: accent, size: 13),
          const SizedBox(width: 5),
          Text(
            job.salaryRange,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
