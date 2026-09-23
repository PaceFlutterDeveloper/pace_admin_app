import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/core/utils/constants/job_share_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Native share sheet payload for a listed job.
class JobShare {
  static String message(JobModel job) {
    final salary =
        job.salaryRange.isNotEmpty ? job.salaryRange : 'Not specified';
    return '''
${job.title} at ${job.schoolName}
Location: ${job.location}
Employment Type: ${job.employmentType}
Salary: $salary

Apply in the Pace Careers app:
${JobShareLinks.httpsUrl(job.jobId)}
'''.trim();
  }

  static Future<void> share(BuildContext context, JobModel job) async {
    Rect? origin;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }

    await SharePlus.instance.share(
      ShareParams(
        text: message(job),
        subject: '${job.title} at ${job.schoolName}',
        sharePositionOrigin: origin,
      ),
    );
  }
}
