import 'package:admin_app/UI/public/jobs/components/shared/card_decoration.dart';
import 'package:admin_app/UI/public/jobs/components/shared/info_row.dart';
import 'package:admin_app/UI/public/jobs/components/shared/section_title.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:flutter/material.dart';

class JobInfoCard extends StatelessWidget {
  final JobModel job;

  const JobInfoCard({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: CardDecoration.build(w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'Job Information', width: w),
          SizedBox(height: h * 0.012),
          InfoRow(
            label: 'Employment Type',
            value: job.employmentType,
            icon: Icons.work,
            width: w,
          ),
          SizedBox(height: h * 0.01),
          InfoRow(
            label: 'Experience Level',
            value: '${job.salary.minYears}+ years',
            icon: Icons.trending_up,
            width: w,
          ),
          if (job.salaryRange.isNotEmpty) ...[
            SizedBox(height: h * 0.01),
            InfoRow(
              label: 'Salary',
              value: job.salaryRange,
              icon: Icons.attach_money,
              width: w,
            ),
          ],
        ],
      ),
    );
  }
}
