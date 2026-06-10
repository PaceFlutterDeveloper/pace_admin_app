import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_shimmer.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Generic list-section tab (Education / Experience / Family / References /
/// Certificates) for the complete-profile page.
///
/// Handles the full Loading → Loaded → Error flow for its [section], plus
/// add / edit / delete via [editor] and saving through [saveEventBuilder].
class ProfileSectionTab<T> extends StatefulWidget {
  final ProfileSection section;
  final String addLabel;
  final String emptyTitle;
  final String emptySubtitle;

  /// Returns the records when [state] is this section's loaded state.
  final List<T>? Function(CareersProfileState state) recordsOf;

  /// Opens the add/edit dialog and resolves with the new/updated record.
  final Future<T?> Function(BuildContext context, T? existing) editor;

  /// Title line of a record card.
  final String Function(T record) titleOf;

  /// Detail lines of a record card (label/value pairs already formatted).
  final List<String> Function(T record) detailsOf;

  final CareersProfileEvent Function(List<T> records) saveEventBuilder;

  const ProfileSectionTab({
    super.key,
    required this.section,
    required this.addLabel,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.recordsOf,
    required this.editor,
    required this.titleOf,
    required this.detailsOf,
    required this.saveEventBuilder,
  });

  @override
  State<ProfileSectionTab<T>> createState() => _ProfileSectionTabState<T>();
}

class _ProfileSectionTabState<T> extends State<ProfileSectionTab<T>>
    with AutomaticKeepAliveClientMixin {
  List<T> _records = [];
  bool _loading = true;
  bool _dirty = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _loading = true;
      _error = null;
    });
    context.read<CareersProfileBloc>().add(
      LoadProfileSectionEvent(widget.section),
    );
  }

  Future<void> _addOrEdit({T? existing, int? index}) async {
    final record = await widget.editor(context, existing);
    if (record == null) return;
    setState(() {
      if (index != null) {
        _records[index] = record;
      } else {
        _records.add(record);
      }
      _dirty = true;
    });
  }

  void _save() {
    context.read<CareersProfileBloc>().add(widget.saveEventBuilder(_records));
  }

  void _onStateChange(BuildContext context, CareersProfileState state) {
    final loaded = widget.recordsOf(state);
    if (loaded != null) {
      setState(() {
        _records = List<T>.of(loaded);
        _loading = false;
        _error = null;
        _dirty = false;
      });
      return;
    }
    if (state is ProfileSectionLoading && state.section == widget.section) {
      setState(() => _loading = true);
    } else if (state is ProfileSectionError &&
        state.section == widget.section) {
      setState(() {
        _loading = false;
        _error = state.message;
      });
    } else if (state is ProfileSaved && state.section == widget.section) {
      AppToast.success(context, 'Changes saved successfully');
      _load();
    } else if (state is ProfileSaveError && state.section == widget.section) {
      AppToast.error(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<CareersProfileBloc, CareersProfileState>(
      listener: _onStateChange,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton.secondary(
              label: widget.addLabel,
              leadingIcon: CupertinoIcons.add,
              onPressed: _loading ? null : () => _addOrEdit(),
            ),
            AppSpacing.vGapMd,
            if (_loading)
              const ShimmerList(itemCount: 3, showAvatar: false)
            else if (_error != null)
              AppErrorState.generic(message: _error, onRetry: _load)
            else if (_records.isEmpty)
              AppEmptyState.noData(
                title: widget.emptyTitle,
                subtitle: widget.emptySubtitle,
              )
            else
              ..._records.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _RecordCard<T>(
                    title: widget.titleOf(entry.value),
                    details: widget.detailsOf(entry.value),
                    onEdit: () =>
                        _addOrEdit(existing: entry.value, index: entry.key),
                    onDelete: () {
                      setState(() {
                        _records.removeAt(entry.key);
                        _dirty = true;
                      });
                    },
                  ),
                ),
              ),
            if (!_loading &&
                _error == null &&
                (_dirty || _records.isNotEmpty)) ...[
              AppSpacing.vGapMd,
              BlocBuilder<CareersProfileBloc, CareersProfileState>(
                buildWhen: (previous, current) =>
                    (current is ProfileSaving &&
                        current.section == widget.section) ||
                    (current is ProfileSaved &&
                        current.section == widget.section) ||
                    (current is ProfileSaveError &&
                        current.section == widget.section),
                builder: (context, state) {
                  final saving =
                      state is ProfileSaving && state.section == widget.section;
                  return AppButton.primary(
                    label: 'Save Changes',
                    isLoading: saving,
                    onPressed: saving ? null : _save,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordCard<T> extends StatelessWidget {
  final String title;
  final List<String> details;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecordCard({
    super.key,
    required this.title,
    required this.details,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dangerColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    return ProfileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.vGapXs,
                for (final detail in details)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AppIconButton(
            icon: CupertinoIcons.pencil,
            size: AppSizes.touchTarget,
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          AppIconButton(
            icon: CupertinoIcons.trash,
            size: AppSizes.touchTarget,
            color: dangerColor,
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
