import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedSearchBar extends StatefulWidget {
  final String searchQuery;
  final String location;
  final SchoolModel? selectedSchool;
  final List<SchoolModel> schools;
  final bool isLoadingSchools;
  final bool isSearching;
  final Function(String) onSearchChanged;
  final Function(String) onLocationChanged;
  final Function(SchoolModel?) onSchoolChanged;
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
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _locationController = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldBg = isDark
        ? AppColors.surfaceContainerDark
        : AppColors.surfaceContainerLight;
    final uniqueSchools = widget.schools.toSet().toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _SearchFieldContainer(
                  backgroundColor: fieldBg,
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search jobs',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      prefixIcon: widget.isSearching
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : Icon(
                              CupertinoIcons.search,
                              size: 20,
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SearchFieldContainer(
                  backgroundColor: fieldBg,
                  child: TextField(
                    controller: _locationController,
                    onChanged: widget.onLocationChanged,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Location',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.location,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SearchFieldContainer(
            backgroundColor: fieldBg,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Icon(
                    CupertinoIcons.building_2_fill,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                Expanded(
                  child: widget.isLoadingSchools
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : widget.schools.isEmpty
                          ? _EmptySchoolsRow(onRetry: widget.onRetrySchools)
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<SchoolModel?>(
                                value: uniqueSchools
                                        .contains(widget.selectedSchool)
                                    ? widget.selectedSchool
                                    : null,
                                isExpanded: true,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: Text(
                                    'All Schools',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                ),
                                dropdownColor: isDark
                                    ? AppColors.surfaceElevatedDark
                                    : AppColors.surfaceElevatedLight,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                items: [
                                  DropdownMenuItem<SchoolModel?>(
                                    value: null,
                                    child: Text(
                                      'All Schools',
                                      style: GoogleFonts.inter(fontSize: 15),
                                    ),
                                  ),
                                  ...uniqueSchools.map((school) {
                                    return DropdownMenuItem<SchoolModel?>(
                                      value: school,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              school.name,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.inter(fontSize: 15),
                                            ),
                                          ),
                                          if (school.jobCount > 0) ...[
                                            const SizedBox(width: AppSpacing.sm),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.sm,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppRadius.xs,
                                                ),
                                              ),
                                              child: Text(
                                                '${school.jobCount}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: widget.onSchoolChanged,
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchFieldContainer extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;

  const _SearchFieldContainer({
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        ),
      ),
      child: child,
    );
  }
}

class _EmptySchoolsRow extends StatelessWidget {
  final VoidCallback? onRetry;

  const _EmptySchoolsRow({this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No schools available',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                CupertinoIcons.refresh,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
