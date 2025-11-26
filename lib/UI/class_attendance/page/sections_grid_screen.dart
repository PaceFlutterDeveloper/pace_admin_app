import 'package:admin_app/UI/class_attendance/model/grade_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SectionsGridScreen extends StatelessWidget {
  final GradeModel grade;

  const SectionsGridScreen({
    Key? key,
    required this.grade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("${grade.className} - Sections"),
        centerTitle: true,
      ),
      backgroundColor: ConstColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.03,
        ),
        child: GridView.builder(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: screenWidth * 0.015,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 1200
                ? 6
                : screenWidth > 900
                    ? 4
                    : 3,
            crossAxisSpacing: screenWidth * 0.02,
            mainAxisSpacing: screenHeight * 0.02,
            childAspectRatio: screenWidth > 600 ? 1.2 : 1.0,
          ),
          itemCount: grade.sections.length,
          itemBuilder: (context, index) {
            final String section = grade.sections[index];

            return InkWell(
              onTap: () {
                context.pushNamed(
                  Routes.students.name,
                  queryParameters: {
                    "title": "${grade.className} - $section",
                    "grade": grade.className,
                    "section": section, // Ensure key matches with GoRoute
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: ConstColors.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FontAwesomeIcons.chalkboard,
                        color: Colors.blueAccent),
                    SizedBox(height: screenHeight * 0.01),
                    Center(
                      child: Text(
                        section,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
