import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/jobs/utils/job_date_format.dart';
import 'package:admin_app/core/utils/constants/job_share_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Native share sheet payload for a listed job.
///
/// The body is plain text, not a bare URL. Chat apps still attach a link
/// preview, and the message itself carries a short glimpse of the post.
class JobShare {
  static const int _aboutLimit = 280;
  static const int _qualificationLimit = 160;

  static String message(JobModel job) {
    final lines = <String>[];

    final title = job.title.trim();
    final school = job.schoolName.trim();
    if (title.isNotEmpty) lines.add(title);
    if (school.isNotEmpty) lines.add(school);

    final meta = <String>[?_place(job), ?_facts(job), ?_deadline(job)];
    if (meta.isNotEmpty) {
      if (lines.isNotEmpty) lines.add('');
      lines.addAll(meta);
    }

    final about = _clip(_plain(job.description), _aboutLimit);
    if (about.isNotEmpty) {
      if (lines.isNotEmpty) lines.add('');
      lines.add(about);
    }

    final qualification = _clip(
      _plain(job.qualification ?? ''),
      _qualificationLimit,
    );
    if (qualification.isNotEmpty) {
      if (lines.isNotEmpty) lines.add('');
      lines.add('Qualification: $qualification');
    }

    if (lines.isNotEmpty) lines.add('');
    lines.add('Apply in the Pace Careers app:');
    lines.add(JobShareLinks.httpsUrl(job.jobId));
    return lines.join('\n');
  }

  static Future<void> share(BuildContext context, JobModel job) async {
    Rect? origin;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }

    final title = job.title.trim();
    final school = job.schoolName.trim();
    final subject = [
      if (title.isNotEmpty) title,
      if (school.isNotEmpty) school,
    ].join(' at ');

    await SharePlus.instance.share(
      ShareParams(
        text: message(job),
        subject: subject.isEmpty ? null : subject,
        sharePositionOrigin: origin,
      ),
    );
  }

  static String? _place(JobModel job) {
    final location = job.location.trim();
    final country = (job.country ?? '').trim();
    final parts = <String>[
      if (location.isNotEmpty) location,
      if (country.isNotEmpty && country.toLowerCase() != location.toLowerCase())
        country,
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static String? _facts(JobModel job) {
    final parts = <String>[
      if (job.employmentType.trim().isNotEmpty) job.employmentType.trim(),
      ?_salary(job),
      ?_experience(job),
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static String? _salary(JobModel job) {
    final range = job.salaryRange.trim();
    if (range.isEmpty) return null;
    final hasCurrency = RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(range);
    return hasCurrency ? 'Salary: $range' : 'Salary: AED $range';
  }

  static String? _experience(JobModel job) {
    final min = job.salary?.minYears ?? 0;
    if (min <= 0) return null;
    final max = job.salary?.maxYears;
    if (max != null && max > min) return '$min–$max years';
    return '$min+ years';
  }

  static String? _deadline(JobModel job) {
    final label = JobDateFormat.absolute(job.deadline);
    if (label == null) return null;
    return 'Apply by $label';
  }

  static String _plain(String raw) {
    var text = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|div|li|h[1-6])>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ');
    const entities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&apos;': "'",
    };
    entities.forEach((entity, value) {
      text = text.replaceAll(entity, value);
    });
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]*\n[ \t]*'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
  }

  static String _clip(String text, int max) {
    if (text.length <= max) return text;
    final slice = text.substring(0, max);
    final lastSpace = slice.lastIndexOf(' ');
    final cut = lastSpace > (max * 0.6).round()
        ? slice.substring(0, lastSpace)
        : slice;
    return '${cut.trim()}…';
  }
}
