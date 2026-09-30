import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton list matching [ApplicationCard]'s dimensions.
class ApplicationLoadingState extends StatelessWidget {
  final int itemCount;

  const ApplicationLoadingState({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CareersColors.surfaceMuted,
      highlightColor: CareersColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          CareersSpacing.screenH,
          CareersSpacing.cardPadding,
          CareersSpacing.screenH,
          CareersSpacing.section,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, __) => const _ApplicationCardSkeleton(),
      ),
    );
  }
}

class _ApplicationCardSkeleton extends StatelessWidget {
  const _ApplicationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(CareersSpacing.cardPadding),
      decoration: BoxDecoration(
        color: CareersColors.surface,
        borderRadius: CareersRadius.cardAll,
        border: Border.all(color: CareersColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Block(width: double.infinity, height: 15),
                    SizedBox(height: 7),
                    _Block(width: 120, height: 12),
                  ],
                ),
              ),
              SizedBox(width: 10),
              _Block(width: 74, height: 24, radius: CareersRadius.chip),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _Block(width: 92, height: 26, radius: CareersRadius.chip),
              SizedBox(width: 8),
              _Block(width: 76, height: 26, radius: CareersRadius.chip),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _Block(width: double.infinity, height: 30)),
              SizedBox(width: 16),
              Expanded(child: _Block(width: double.infinity, height: 30)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Block({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CareersColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
