import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class JobSearchFilter extends StatefulWidget {
  final String searchQuery;
  final String selectedFilter;
  final List<String> filterOptions;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;

  const JobSearchFilter({
    Key? key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onSearchChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<JobSearchFilter> createState() => _JobSearchFilterState();
}

class _JobSearchFilterState extends State<JobSearchFilter> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: ConstColors.whiteColor,
        borderRadius: BorderRadius.circular(w * 0.03),
        border: Border.all(
          color: ConstColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by job title...',
              hintStyle: TextStyle(
                color: ConstColors.textLight,
                fontSize: w * 0.04,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: ConstColors.textLight,
                size: w * 0.05,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: ConstColors.textLight,
                        size: w * 0.05,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: ConstColors.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.025),
                borderSide: BorderSide(
                  color: ConstColors.borderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.025),
                borderSide: BorderSide(
                  color: ConstColors.borderColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(w * 0.025),
                borderSide: BorderSide(
                  color: ConstColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
            ),
            style: TextStyle(
              fontSize: w * 0.04,
              color: ConstColors.textDark,
            ),
          ),

          SizedBox(height: h * 0.015),

          // Filter Dropdown
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: ConstColors.textLight,
                size: w * 0.05,
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Filter by:',
                style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w600,
                  color: ConstColors.textDark,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                  decoration: BoxDecoration(
                    color: ConstColors.backgroundColor,
                    borderRadius: BorderRadius.circular(w * 0.025),
                    border: Border.all(
                      color: ConstColors.borderColor,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.selectedFilter,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: ConstColors.textLight,
                        size: w * 0.05,
                      ),
                      style: TextStyle(
                        fontSize: w * 0.04,
                        color: ConstColors.textDark,
                      ),
                      items: widget.filterOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: ConstColors.textDark,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          widget.onFilterChanged(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JobFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const JobFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.03,
          vertical: w * 0.015,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ConstColors.primary : ConstColors.backgroundColor,
          borderRadius: BorderRadius.circular(w * 0.02),
          border: Border.all(
            color: isSelected ? ConstColors.primary : ConstColors.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: w * 0.035,
            fontWeight: FontWeight.w500,
            color: isSelected ? ConstColors.whiteColor : ConstColors.textDark,
          ),
        ),
      ),
    );
  }
}
