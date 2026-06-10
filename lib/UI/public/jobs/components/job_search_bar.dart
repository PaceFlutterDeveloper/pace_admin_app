import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class JobSearchBar extends StatefulWidget {
  final String searchQuery;
  final String location;
  final Function(String) onSearchChanged;
  final Function(String) onLocationChanged;

  const JobSearchBar({
    Key? key,
    required this.searchQuery,
    required this.location,
    required this.onSearchChanged,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<JobSearchBar> createState() => _JobSearchBarState();
}

class _JobSearchBarState extends State<JobSearchBar> {
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
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
                prefixIcon: Icon(
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
          Container(height: h * 0.03, width: 1, color: ConstColors.borderColor),

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
    );
  }
}
