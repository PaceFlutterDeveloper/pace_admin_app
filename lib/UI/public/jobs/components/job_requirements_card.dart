import 'package:admin_app/UI/public/jobs/components/shared/careers_html_text.dart';
import 'package:admin_app/UI/public/jobs/components/shared/section_card.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JobRequirementsCard extends StatelessWidget {
  final JobModel job;

  const JobRequirementsCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final raw = job.requirements ?? '';
    final qualification = job.qualification?.trim() ?? '';

    return SectionCard(
      title: 'Requirements',
      icon: CupertinoIcons.checkmark_seal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (qualification.isNotEmpty) ...[
            Text(
              'Qualification',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            CareersHtmlText(html: qualification),
            const SizedBox(height: 16),
          ],
          _RequirementsBody(raw: raw),
        ],
      ),
    );
  }
}

class _RequirementsBody extends StatelessWidget {
  final String raw;

  const _RequirementsBody({required this.raw});

  /// Comma or newline separated skill lists read far better as bullets; any
  /// other shape is passed through to the HTML renderer untouched.
  List<String>? _asBullets() {
    if (raw.contains('<')) return null;
    final parts = raw
        .split(RegExp(r'[\n\r]+|,(?=\s)'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.length > 1 ? parts : null;
  }

  @override
  Widget build(BuildContext context) {
    final bullets = _asBullets();
    if (bullets != null) return CareersBulletList(items: bullets);
    return CareersHtmlText(html: raw);
  }
}
