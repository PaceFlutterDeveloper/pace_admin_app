import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/jobs/utils/job_date_format.dart';
import 'package:admin_app/UI/public/jobs/utils/job_share.dart';
import 'package:admin_app/UI/public/shared/components/careers_glass_card.dart';
import 'package:admin_app/UI/public/shared/components/careers_hero_surface.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Gradient hero for the job detail screen: school monogram, title, school,
/// location and the posted / deadline dates.
class JobHeaderCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onShare;

  const JobHeaderCard({super.key, required this.job, this.onShare});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final postedLabel =
        JobDateFormat.relative(job.postedDate) ??
        JobDateFormat.absolute(job.createdAt);
    final deadline = _DeadlineLabel.from(job.deadline);

    return CareersHeroSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SchoolMonogram(name: job.schoolName, logoUrl: job.schoolLogo),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.25,
                      ),
                    ),
                    if (job.schoolName.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        job.schoolName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _HeroIconButton(
                icon: Icons.share_outlined,
                tooltip: 'Share job',
                onTap: () => _shareJob(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(
                icon: CupertinoIcons.circle_fill,
                label: job.status,
                emphasised: true,
              ),
              if (job.location.isNotEmpty)
                _HeroPill(
                  icon: CupertinoIcons.location_solid,
                  label: job.location,
                ),
              if (job.employmentType.isNotEmpty)
                _HeroPill(
                  icon: CupertinoIcons.briefcase_fill,
                  label: job.employmentType,
                ),
            ],
          ),
          const SizedBox(height: 16),
          CareersGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: CareersRadius.chipAll,
            child: Row(
              children: [
                Expanded(
                  child: _HeroFact(
                    label: 'Posted',
                    value: postedLabel ?? 'Recently',
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _HeroFact(
                    label: 'Deadline',
                    value: deadline.text,
                    isUrgent: deadline.isUrgent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareJob(BuildContext context) {
    if (onShare != null) {
      onShare!();
      return;
    }
    JobShare.share(context, job);
  }
}

class _SchoolMonogram extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _SchoolMonogram({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '#' : trimmed[0].toUpperCase();
    final url = logoUrl?.trim() ?? '';

    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      padding: url.isEmpty ? EdgeInsets.zero : const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: url.isEmpty
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white,
        borderRadius: CareersRadius.chipAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: url.isEmpty
          ? Text(
              initial,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                initial,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: context.careers.accentText,
                  fontSize: 22,
                ),
              ),
            ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool emphasised;

  const _HeroPill({
    required this.icon,
    required this.label,
    this.emphasised = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: emphasised ? 0.22 : 0.13),
        borderRadius: CareersRadius.pillAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: emphasised ? 8 : 12, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFact extends StatelessWidget {
  final String label;
  final String value;
  final bool isUrgent;

  const _HeroFact({
    required this.label,
    required this.value,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: isUrgent ? const Color(0xFFFFD9E6) : Colors.white,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

/// Human-readable deadline plus whether it should read as urgent.
class _DeadlineLabel {
  final String text;
  final bool isUrgent;

  const _DeadlineLabel(this.text, {this.isUrgent = false});

  static _DeadlineLabel from(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return const _DeadlineLabel('Not specified');

    final date = _parse(value);
    if (date == null) return _DeadlineLabel(value);

    final now = DateTime.now();
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (days < 0) return const _DeadlineLabel('Expired', isUrgent: true);
    if (days == 0) return const _DeadlineLabel('Today', isUrgent: true);
    if (days == 1) return const _DeadlineLabel('Tomorrow', isUrgent: true);
    if (days < 7) return _DeadlineLabel('$days days left', isUrgent: true);
    return _DeadlineLabel(JobDateFormat.absolute(value) ?? value);
  }

  static DateTime? _parse(String value) {
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 3) {
        return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
    }
    return DateTime.tryParse(value);
  }
}
