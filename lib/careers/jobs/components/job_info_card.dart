import 'package:admin_app/careers/jobs/components/shared/aed_currency_icon.dart';
import 'package:admin_app/careers/jobs/components/shared/info_row.dart';
import 'package:admin_app/careers/jobs/components/shared/section_card.dart';
import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';

class JobInfoCard extends StatelessWidget {
  final JobModel job;

  const JobInfoCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final hasMinYears = (job.salary?.minYears ?? 0) > 0;

    return SectionCard(
      title: 'Overview',
      icon: CupertinoIcons.doc_text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (job.employmentType.isNotEmpty) ...[
            InfoRow(
              label: 'Employment type',
              value: job.employmentType,
              icon: CupertinoIcons.briefcase,
            ),
            CareersSpacing.gap12,
          ],
          InfoRow(
            label: 'Experience level',
            value: hasMinYears
                ? '${job.salary!.minYears}+ years'
                : job.experienceLevel,
            icon: CupertinoIcons.chart_bar_alt_fill,
          ),
          if (job.location.isNotEmpty) ...[
            CareersSpacing.gap12,
            InfoRow(
              label: 'Location',
              value: job.location,
              icon: CupertinoIcons.location_solid,
            ),
          ],
          if (job.department?.isNotEmpty ?? false) ...[
            CareersSpacing.gap12,
            InfoRow(
              label: 'Department',
              value: job.department!,
              icon: CupertinoIcons.building_2_fill,
            ),
          ],
          if (job.salaryRange.isNotEmpty) ...[
            CareersSpacing.gap12,
            InfoRow(
              label: 'Salary',
              value: job.salaryRange,
              valueColor: CareersColors.success,
              leading: AedCurrencyIcon(
                color: context.careers.accentText,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
