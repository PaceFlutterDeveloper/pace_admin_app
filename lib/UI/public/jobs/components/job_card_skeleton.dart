import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton that mirrors [CareersJobCard]'s real dimensions so the list does
/// not jump when data arrives.
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.careers;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: palette.surfaceMuted,
        highlightColor: palette.isDark
            ? Color.lerp(palette.surfaceMuted, Colors.white, 0.08)!
            : palette.surface,
        child: Container(
          padding: const EdgeInsets.all(CareersSpacing.cardPadding),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: CareersRadius.cardAll,
            border: Border.all(color: palette.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 46, height: 46, radius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Block(width: double.infinity, height: 15),
                        SizedBox(height: 7),
                        _Block(width: 130, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _Block(width: 170, height: 11),
              SizedBox(height: 16),
              Row(
                children: [
                  _Block(width: 84, height: 26, radius: CareersRadius.chip),
                  SizedBox(width: 8),
                  _Block(width: 66, height: 26, radius: CareersRadius.chip),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A column of skeleton cards, used while the first page of jobs loads.
///
/// Not scrollable: it is always placed inside an existing scroll view, so a
/// nested viewport here would be given unbounded height.
class JobCardSkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const JobCardSkeletonList({
    super.key,
    this.itemCount = 4,
    this.padding = const EdgeInsets.symmetric(
      horizontal: CareersSpacing.screenH,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(itemCount, (_) => const JobCardSkeleton()),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Block({required this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.careers.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
