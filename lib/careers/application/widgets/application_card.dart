import 'package:admin_app/careers/jobs/components/shared/aed_currency_icon.dart';
import 'package:admin_app/careers/jobs/components/shared/card_decoration.dart';
import 'package:admin_app/careers/jobs/utils/job_date_format.dart';
import 'package:admin_app/careers/shared/components/careers_status_chip.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/application_models.dart';

/// Summary card for one submitted application.
class ApplicationCard extends StatelessWidget {
  final Application application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final job = application.job;
    final details = application.application;
    final status = ApplicationStatus.fromString(details.status);
    final appliedDate = JobDateFormat.absolute(details.appliedDate);

    return Container(
      padding: const EdgeInsets.all(CareersSpacing.cardPadding),
      decoration: CardDecoration.build(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (job.school.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        job.school,
                        style: textTheme.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CareersStatusChip(
                label: status.displayName,
                style: CareersStatusColors.application(status.name),
              ),
            ],
          ),
          CareersSpacing.gap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job.location.isNotEmpty)
                CareersMetaChip(
                  label: job.location,
                  icon: CupertinoIcons.location_solid,
                ),
              if (job.employmentType.isNotEmpty)
                CareersMetaChip(
                  label: job.employmentType,
                  icon: CupertinoIcons.briefcase,
                ),
              if (job.salaryRange.isNotEmpty) _SalaryChip(job.salaryRange),
            ],
          ),
          if (details.coverLetter.isNotEmpty) ...[
            CareersSpacing.gap12,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: CardDecoration.nested(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cover letter', style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    details.coverLetter,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.careers.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          CareersSpacing.gap12,
          const Divider(height: 1),
          CareersSpacing.gap12,
          Row(
            children: [
              Expanded(
                child: _Fact(
                  label: 'Applied',
                  value: appliedDate ?? '—',
                  icon: CupertinoIcons.calendar,
                ),
              ),
              Expanded(
                child: _Fact(
                  label: 'Availability',
                  value: details.availabilityOk ? 'Available' : 'Not available',
                  icon: CupertinoIcons.checkmark_circle,
                  valueColor: details.availabilityOk
                      ? CareersColors.success
                      : context.careers.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalaryChip extends StatelessWidget {
  final String range;

  const _SalaryChip(this.range);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CareersColors.success.withValues(alpha: 0.1),
        borderRadius: CareersRadius.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AedCurrencyIcon(color: CareersColors.success, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              range,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CareersColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _Fact({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: context.careers.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodySmall),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
