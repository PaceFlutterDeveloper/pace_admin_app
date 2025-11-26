import 'dart:developer';

import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/UI/components/failure_widget.dart';
import 'package:admin_app/UI/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/UI/students/components/student_attendance_tile.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsPage extends StatefulWidget {
  final String grade;
  final String section;
  final String appTitle;
  const StudentsPage({
    Key? key,
    required this.appTitle,
    required this.grade,
    required this.section,
  }) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch students using the bloc.
    context.read<StudentAttendanceBloc>().add(
          FetchStudentsEvent(
            grade: widget.grade,
            section: widget.section,
          ),
        );
  }

  /// Shows a summary dialog with the attendance counts.
  void showAttendanceSummary(
      BuildContext context, StudentAttendanceState state) {
    if (state is StudentLoadedState) {
      final presentCount = state.students
          .where((student) => student.att != null && student.att!.att == "0")
          .length;
      final absentCount = state.students
          .where((student) => student.att != null && student.att!.att == "1")
          .length;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              "Attendance Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Present:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Text(
                      "$presentCount",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Absent:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Text(
                      "$absentCount",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Cancel button: simply closes the dialog.
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(fontSize: 14)),
              ),
              // Update button: dispatches an update event to allow modifying the attendance.
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // Dispatch an update event.
                  context.read<StudentAttendanceBloc>().add(
                        PostAttendanceEvent(
                          type: "UPDATE",
                          grade: widget.grade,
                          section: widget.section,
                          students: state.students,
                          remarks: state.remarks,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text("Update",
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
              // Confirm button: dispatches the event to post/submit attendance.
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  context.read<StudentAttendanceBloc>().add(
                        PostAttendanceEvent(
                          type: "CONFIRM",
                          grade: widget.grade,
                          section: widget.section,
                          students: state.students,
                          remarks: state.remarks,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text("Confirm",
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appTitle,
          style: TextStyle(
              fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () {
              // Dispatch the Mark All event.
              context.read<StudentAttendanceBloc>().add(MarkAllStudentEvent());
            },
            child: const Text("Read All"),
          ),
        ],
      ),
      backgroundColor: ConstColors.backgroundColor,
      body: BlocConsumer<StudentAttendanceBloc, StudentAttendanceState>(
        listener: (context, state) {
          log(state.toString());
          if (state is StudentErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is StudentPostedState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is StudentInitial || state is StudentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentLoadedState) {
            return ListView.builder(
              itemCount: state.students.length,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01),
              itemBuilder: (context, index) {
                final student = state.students[index];
                return StudentAttendanceTile(
                  student: student,
                  remarks: state.remarks,
                );
              },
            );
          } else if (state is StudentErrorState) {
            return FailureWidget(
              message: state.message,
              onRetry: () => context.read<StudentAttendanceBloc>().add(
                    FetchStudentsEvent(
                      grade: widget.grade,
                      section: widget.section,
                    ),
                  ),
            );
          } else if (state is StudentPostedState) {
            // Optionally, display a success message view.
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar:
          BlocBuilder<StudentAttendanceBloc, StudentAttendanceState>(
        builder: (context, state) {
          if (state is StudentLoadedState &&
              state.students.every((student) => student.att != null)) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonComponent(
                buttonText: "Mark Attendance",
                onTap: () => showAttendanceSummary(context, state),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
