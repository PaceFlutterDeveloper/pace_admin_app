import 'package:admin_app/UI/public/jobs/components/shared/card_decoration.dart';
import 'package:admin_app/UI/public/jobs/components/shared/description_text.dart';
import 'package:admin_app/UI/public/jobs/components/shared/section_title.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:flutter/material.dart';

class CompanyCard extends StatelessWidget {
  final JobModel job;

  const CompanyCard({
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
          SectionTitle(title: 'About ${job.schoolName}', width: w),
          SizedBox(height: h * 0.012),
          DescriptionText(
            text:
                'We are looking for talented individuals to join our team. This is a great opportunity to work with a dynamic company and grow your career.',
            width: w,
          ),
        ],
      ),
    );
  }
}
