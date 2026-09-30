import 'package:admin_app/UI/public/jobs/components/shared/careers_html_text.dart';
import 'package:admin_app/UI/public/jobs/components/shared/section_card.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:flutter/cupertino.dart';

class JobDescriptionCard extends StatelessWidget {
  final JobModel job;

  const JobDescriptionCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Job Description',
      icon: CupertinoIcons.text_alignleft,
      child: CareersHtmlText(html: job.description),
    );
  }
}
