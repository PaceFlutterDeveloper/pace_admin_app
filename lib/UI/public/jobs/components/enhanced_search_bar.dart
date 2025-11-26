import 'dart:developer';

import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

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
    Key? key,
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
  }) : super(key: key);

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
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Debug: Check for duplicate schools
    final uniqueSchools = widget.schools.toSet().toList();
    if (uniqueSchools.length != widget.schools.length) {
      print(
          'Warning: Duplicate schools detected. Original: ${widget.schools.length}, Unique: ${uniqueSchools.length}');
    }

    // Debug: Check selected school
    if (widget.selectedSchool != null) {
      print(
          'Selected school: ${widget.selectedSchool!.name} (ID: ${widget.selectedSchool!.id})');
      print(
          'Is selected school in unique schools: ${uniqueSchools.contains(widget.selectedSchool)}');
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
      child: Column(
        children: [
          // Main Search Bar
          Container(
            height: h * 0.05,
            decoration: BoxDecoration(
              color: ConstColors.whiteColor,
              borderRadius: BorderRadius.circular(w * 0.025),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      isDense: false,
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: ConstColors.textLight,
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: widget.isSearching
                          ? SizedBox(
                              width: w * 0.05,
                              height: w * 0.05,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ConstColors.primary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.search,
                              color: ConstColors.textLight,
                              size: w * 0.05,
                            ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: w * 0.04,
                        vertical: h * 0.01,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: w * 0.04,
                      color: ConstColors.textDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                // Vertical Divider
                Container(
                  height: h * 0.03,
                  width: 1,
                  color: ConstColors.borderColor,
                ),

                // Location Field
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _locationController,
                    onChanged: widget.onLocationChanged,
                    decoration: InputDecoration(
                      isDense: false,
                      hintText: 'Location',
                      hintStyle: TextStyle(
                        color: ConstColors.textLight,
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: ConstColors.textLight,
                        size: w * 0.05,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: w * 0.04,
                        vertical: h * 0.01,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: w * 0.04,
                      color: ConstColors.textDark,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.01),

          // School Dropdown
          Container(
            height: h * 0.05,
            decoration: BoxDecoration(
              color: ConstColors.whiteColor,
              borderRadius: BorderRadius.circular(w * 0.025),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // School Icon
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: Icon(
                    Icons.school,
                    color: ConstColors.textLight,
                    size: w * 0.05,
                  ),
                ),

                // Vertical Divider
                Container(
                  height: h * 0.03,
                  width: 1,
                  color: ConstColors.borderColor,
                ),

                // School Dropdown
                Expanded(
                  child: widget.isLoadingSchools
                      ? Center(
                          child: SizedBox(
                            width: w * 0.04,
                            height: w * 0.04,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ConstColors.primary,
                              ),
                            ),
                          ),
                        )
                      : widget.schools.isEmpty
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No schools available',
                                    style: TextStyle(
                                      color: ConstColors.textLight,
                                      fontSize: w * 0.035,
                                    ),
                                  ),
                                  if (widget.onRetrySchools != null) ...[
                                    SizedBox(width: w * 0.02),
                                    GestureDetector(
                                      onTap: widget.onRetrySchools,
                                      child: Icon(
                                        Icons.refresh,
                                        color: ConstColors.primary,
                                        size: w * 0.04,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<SchoolModel?>(
                                value: uniqueSchools
                                        .contains(widget.selectedSchool)
                                    ? widget.selectedSchool
                                    : null,
                                isExpanded: true,
                                hint: Text(
                                  'Select School',
                                  style: TextStyle(
                                    color: ConstColors.textLight,
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: w * 0.04,
                                  color: ConstColors.textDark,
                                  fontWeight: FontWeight.w400,
                                ),
                                items: [
                                  // All Schools option
                                  DropdownMenuItem<SchoolModel?>(
                                    value: null,
                                    child: Text('All Schools'),
                                  ),
                                  // School options - ensure no duplicates
                                  ...uniqueSchools.map((school) {
                                    return DropdownMenuItem<SchoolModel?>(
                                      value: school,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              school.name,
                                              style: TextStyle(
                                                fontSize: w * 0.04,
                                                color: ConstColors.textDark,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (school.jobCount > 0) ...[
                                            SizedBox(width: w * 0.02),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: w * 0.02,
                                                vertical: h * 0.003,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ConstColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        w * 0.01),
                                              ),
                                              child: Text(
                                                '${school.jobCount}',
                                                style: TextStyle(
                                                  fontSize: w * 0.03,
                                                  color: ConstColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (SchoolModel? newValue) {
                                  log('Dropdown onChanged called with: ${newValue?.name} (ID: ${newValue?.id})');
                                  widget.onSchoolChanged(newValue);
                                },
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
