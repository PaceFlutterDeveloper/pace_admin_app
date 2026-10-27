import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const ScrollPhysics staffScrollPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

/// Shows skeleton, error or content for a [LoadCubit], with pull to refresh.
/// [builder] must return a scrollable (usually a `ListView`).
class StaffLoadView<T> extends StatelessWidget {
  const StaffLoadView({
    super.key,
    required this.builder,
    required this.errorGlyph,
    required this.errorTitle,
    this.accent = StaffAccent.amber,
    this.skeletonCount = 4,
    this.skeletonHeight = 84,
  });

  final Widget Function(BuildContext context, T data) builder;
  final String errorGlyph;
  final String errorTitle;
  final StaffAccent accent;
  final int skeletonCount;
  final double skeletonHeight;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final cubit = context.read<LoadCubit<T>>();
    return RefreshIndicator(
      color: p.amberText,
      backgroundColor: p.surface,
      onRefresh: () => cubit.load(quiet: true),
      child: BlocBuilder<LoadCubit<T>, LoadState<T>>(
        builder: (context, state) => switch (state) {
          LoadInProgress<T>() => ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (var i = 0; i < skeletonCount; i++) ...[
                StaffSkeleton(height: skeletonHeight, radius: 20),
                const SizedBox(height: 10),
              ],
            ],
          ),
          LoadFailure<T>(:final message) => ListView(
            physics: staffScrollPhysics,
            children: [
              SizedBox(
                height: 420,
                child: StaffStateMessage(
                  glyph: errorGlyph,
                  title: errorTitle,
                  message: message,
                  actionLabel: 'Try again',
                  onAction: cubit.load,
                  accent: accent,
                ),
              ),
            ],
          ),
          LoadSuccess<T>(:final data) => builder(context, data),
        },
      ),
    );
  }
}

/// Empty list message that still scrolls, so pull to refresh keeps working.
class StaffEmptyList extends StatelessWidget {
  const StaffEmptyList({
    super.key,
    required this.glyph,
    required this.title,
    required this.message,
    this.accent = StaffAccent.amber,
  });

  final String glyph;
  final String title;
  final String message;
  final StaffAccent accent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: staffScrollPhysics,
      children: [
        SizedBox(
          height: 420,
          child: StaffStateMessage(
            glyph: glyph,
            title: title,
            message: message,
            accent: accent,
          ),
        ),
      ],
    );
  }
}
