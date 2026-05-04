import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

/// Full-screen loading skeleton shaped like the home dashboard.
class HomeDashboardShimmer extends StatelessWidget {
  const HomeDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE0E0E0);
    final highlight = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF5F5F5);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm + 6,
            AppSpacing.sm,
            AppSpacing.sm + 6,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(AppSpacing.sm + 2),
                    ),
                  ),
                  const Gap(AppSpacing.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 140,
                          decoration: BoxDecoration(
                            color: base,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Container(
                          height: 12,
                          width: 180,
                          decoration: BoxDecoration(
                            color: base,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: base,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.md),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(AppRadius.hero),
                ),
              ),
              const Gap(AppSpacing.md),
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              const Gap(AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.md),
              Container(
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
              const Gap(AppSpacing.sm),
              Container(
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
              const Gap(AppSpacing.md),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
