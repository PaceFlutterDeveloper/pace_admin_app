import 'package:admin_app/UI/class_attendance/cubit/grade_attendance_cubit.dart';
import 'package:admin_app/UI/class_attendance/model/grade_model.dart';
import 'package:admin_app/UI/class_attendance/page/sections_grid_screen.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class GradeAttendanceScreen extends StatefulWidget {
  final String appTitle;
  const GradeAttendanceScreen({Key? key, required this.appTitle})
      : super(key: key);

  @override
  State<GradeAttendanceScreen> createState() => _GradeAttendanceScreenState();
}

class _GradeAttendanceScreenState extends State<GradeAttendanceScreen> {
  @override
  void initState() {
    context.read<GradeAttendanceCubit>().getGrades();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.chalkboardTeacher,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              widget.appTitle,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: ConstColors.backgroundColor,
      body: BlocConsumer<GradeAttendanceCubit, GradeAttendanceState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.fetchGrades) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.gradeDataModel == null) {
            return const Center(child: Text("No grades available"));
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.04,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.gradeDataModel!.dataDefault.gr.isNotEmpty &&
                      state.gradeDataModel!.dataDefault.sec.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.userGraduate,
                                color: Colors.black54),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              "My Class",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        InkWell(
                          onTap: () {
                            context.pushNamed(
                              Routes.students.name,
                              queryParameters: {
                                "title":
                                    "${state.gradeDataModel!.dataDefault.gr} - ${state.gradeDataModel!.dataDefault.sec}",
                                "grade": state.gradeDataModel!.dataDefault.gr,
                                "section": state.gradeDataModel!.dataDefault
                                    .sec, // Ensure key matches with GoRoute
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.green.shade300,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.bookOpen,
                                    color: Colors.white),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  "${state.gradeDataModel!.dataDefault.gr} - ${state.gradeDataModel!.dataDefault.sec}",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.school,
                          color: Colors.black54),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "Other Classes",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: screenWidth * 0.03,
                      mainAxisSpacing: screenHeight * 0.02,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: state.gradeDataModel!.grades.length,
                    itemBuilder: (context, index) {
                      final GradeModel grade =
                          state.gradeDataModel!.grades[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SectionsGridScreen(grade: grade),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.chalkboard,
                                    color: Colors.blueAccent),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  grade.className,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
