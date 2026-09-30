import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Search row for the careers home tab: one prominent search field plus a
/// filter button that opens the location / school filters in a bottom sheet.
///
/// The callback contract is unchanged; only the presentation moved.
class EnhancedSearchBar extends StatefulWidget {
  final String searchQuery;
  final String location;
  final SchoolModel? selectedSchool;
  final List<SchoolModel> schools;
  final bool isLoadingSchools;
  final bool isSearching;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<SchoolModel?> onSchoolChanged;
  final VoidCallback? onRetrySchools;

  const EnhancedSearchBar({
    super.key,
    required this.searchQuery,
    required this.location,
    this.selectedSchool,
    required this.schools,
    this.isLoadingSchools = false,
    this.isSearching = false,
    required this.onSearchChanged,
    required this.onLocationChanged,
    required this.onSchoolChanged,
    this.onRetrySchools,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant EnhancedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    var count = 0;
    if (widget.location.trim().isNotEmpty) count++;
    if (widget.selectedSchool != null) count++;
    return count;
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        location: widget.location,
        selectedSchool: widget.selectedSchool,
        schools: widget.schools,
        isLoadingSchools: widget.isLoadingSchools,
        onLocationChanged: widget.onLocationChanged,
        onSchoolChanged: widget.onSchoolChanged,
        onRetrySchools: widget.onRetrySchools,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.careers;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: CareersRadius.inputAll,
              border: Border.all(color: palette.border),
              boxShadow: palette.cardShadow,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search job title or keyword',
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: palette.textTertiary),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: widget.isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(
                        CupertinoIcons.search,
                        size: 20,
                        color: palette.textTertiary,
                      ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          CupertinoIcons.clear_circled_solid,
                          size: 18,
                          color: palette.textTertiary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _FilterButton(activeCount: _activeFilterCount, onTap: _openFilters),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = activeCount > 0;
    final palette = context.careers;

    return Semantics(
      button: true,
      label: 'Filter jobs',
      child: Material(
        color: isActive ? CareersColors.primary : palette.surface,
        borderRadius: CareersRadius.inputAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: CareersRadius.inputAll,
              border: Border.all(
                color: isActive ? CareersColors.primary : palette.border,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 21,
                  color: isActive
                      ? CareersColors.onPrimary
                      : palette.textSecondary,
                ),
                if (isActive)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: CareersColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String location;
  final SchoolModel? selectedSchool;
  final List<SchoolModel> schools;
  final bool isLoadingSchools;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<SchoolModel?> onSchoolChanged;
  final VoidCallback? onRetrySchools;

  const _FilterSheet({
    required this.location,
    required this.selectedSchool,
    required this.schools,
    required this.isLoadingSchools,
    required this.onLocationChanged,
    required this.onSchoolChanged,
    this.onRetrySchools,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TextEditingController _locationController;
  SchoolModel? _school;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.location);
    _school = widget.selectedSchool;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _apply() {
    final location = _locationController.text.trim();
    if (location != widget.location) {
      widget.onLocationChanged(location);
    }
    if (_school?.id != widget.selectedSchool?.id) {
      widget.onSchoolChanged(_school);
    }
    Navigator.of(context).pop();
  }

  void _reset() {
    _locationController.clear();
    setState(() => _school = null);
    if (widget.location.isNotEmpty) widget.onLocationChanged('');
    if (widget.selectedSchool != null) widget.onSchoolChanged(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uniqueSchools = widget.schools.toSet().toList();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.careers.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CareersRadius.hero),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              CareersSpacing.screenH,
              12,
              CareersSpacing.screenH,
              CareersSpacing.screenH,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.careers.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Filter jobs', style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Narrow results by location and school',
                  style: textTheme.bodySmall,
                ),
                CareersSpacing.gap24,
                Text('Location', style: textTheme.titleSmall),
                CareersSpacing.gap8,
                TextField(
                  controller: _locationController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _apply(),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Dubai',
                    prefixIcon: Icon(CupertinoIcons.location, size: 19),
                  ),
                ),
                CareersSpacing.gap24,
                Text('School', style: textTheme.titleSmall),
                CareersSpacing.gap8,
                if (widget.isLoadingSchools)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (uniqueSchools.isEmpty)
                  _EmptySchoolsRow(onRetry: widget.onRetrySchools)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SchoolChip(
                        label: 'All Schools',
                        isSelected: _school == null,
                        onTap: () => setState(() => _school = null),
                      ),
                      ...uniqueSchools.map(
                        (school) => _SchoolChip(
                          label: school.name,
                          count: school.jobCount,
                          isSelected: _school?.id == school.id,
                          onTap: () => setState(() => _school = school),
                        ),
                      ),
                    ],
                  ),
                CareersSpacing.gap32,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _apply,
                        child: const Text('Show results'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SchoolChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SchoolChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final showCount = (count ?? 0) > 0;
    final palette = context.careers;

    return Material(
      color: isSelected ? CareersColors.primary : palette.surfaceMuted,
      borderRadius: CareersRadius.chipAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: CareersRadius.chipAll,
            border: Border.all(
              color: isSelected ? CareersColors.primary : palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? CareersColors.onPrimary
                        : palette.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (showCount) ...[
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? CareersColors.onPrimary.withValues(alpha: 0.8)
                        : palette.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySchoolsRow extends StatelessWidget {
  final VoidCallback? onRetry;

  const _EmptySchoolsRow({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'No schools available',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (onRetry != null)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(CupertinoIcons.refresh, size: 16),
            label: const Text('Retry'),
          ),
      ],
    );
  }
}
