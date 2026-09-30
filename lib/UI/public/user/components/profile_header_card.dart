import 'package:admin_app/UI/public/shared/components/careers_glass_card.dart';
import 'package:admin_app/UI/public/shared/components/careers_hero_surface.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/UI/public/user/components/careers_profile_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Header showing the candidate's identity and completion status on the
/// careers hero gradient.
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  /// API-driven completion state; null while unknown.
  final bool? isComplete;
  final int? completionPercentage;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isComplete,
    this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return CareersHeroSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: CareersSpacing.cardPadding,
        vertical: CareersSpacing.section,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
            ),
            child: CareersProfileImage(remoteSource: avatarUrl, size: 84),
          ),
          CareersSpacing.gap16,
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (isComplete != null) ...[
            CareersSpacing.gap16,
            _CompletionStrip(
              isComplete: isComplete ?? false,
              percentage: completionPercentage,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletionStrip extends StatelessWidget {
  final bool isComplete;
  final int? percentage;

  const _CompletionStrip({required this.isComplete, this.percentage});

  @override
  Widget build(BuildContext context) {
    final label = isComplete
        ? 'Profile complete'
        : percentage != null
        ? 'Profile $percentage% complete'
        : 'Profile incomplete';
    final progress = ((percentage ?? (isComplete ? 100 : 0)) / 100).clamp(
      0.0,
      1.0,
    );

    return CareersGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete
                    ? CupertinoIcons.checkmark_seal_fill
                    : CupertinoIcons.exclamationmark_circle_fill,
                size: 17,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: CareersRadius.pillAll,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
