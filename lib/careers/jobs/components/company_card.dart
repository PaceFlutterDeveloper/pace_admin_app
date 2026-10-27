import 'package:admin_app/careers/jobs/components/shared/description_text.dart';
import 'package:admin_app/careers/jobs/components/shared/section_card.dart';
import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompanyCard extends StatelessWidget {
  final JobModel job;

  const CompanyCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final school = job.schoolName.trim();

    return SectionCard(
      title: school.isEmpty ? 'About the school' : 'About $school',
      icon: CupertinoIcons.building_2_fill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DescriptionText(
            text:
                'We are looking for talented individuals to join our team. This '
                'is a great opportunity to work with a dynamic company and grow '
                'your career.',
          ),
          if (job.country?.isNotEmpty ?? false) ...[
            CareersSpacing.gap16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.careers.surfaceMuted,
                borderRadius: CareersRadius.chipAll,
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.globe,
                    size: 15,
                    color: context.careers.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.country!,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
