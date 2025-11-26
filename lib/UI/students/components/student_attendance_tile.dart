import 'package:admin_app/UI/students/bloc/student_attendance_bloc.dart';
import 'package:admin_app/UI/students/models/student_att_model.dart';
import 'package:admin_app/UI/students/models/student_response_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentAttendanceTile extends StatefulWidget {
  final StudentModel student;
  final List<Remark> remarks;

  const StudentAttendanceTile({
    Key? key,
    required this.student,
    required this.remarks,
  }) : super(key: key);

  @override
  _StudentAttendanceTileState createState() => _StudentAttendanceTileState();
}

class _StudentAttendanceTileState extends State<StudentAttendanceTile> {
  String comment = "";
  // Opens an AlertDialog to enter or update a comment.
  void _openCommentDialog() {
    final TextEditingController commentController =
        TextEditingController(text: comment ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Enter Comment",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: "Type your comment here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel the dialog.
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  comment = commentController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Filter remarks based on type.
    final List<Remark> presentRemarks = widget.remarks
        .where((remark) => remark.remarkType.toLowerCase().contains("0"))
        .toList();
    final List<Remark> absentRemarks = widget.remarks
        .where((remark) => remark.remarkType.toLowerCase().contains("1"))
        .toList();

    return Container(
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
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student details row.
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.055,
                  backgroundImage: NetworkImage(widget.student.photo),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    widget.student.fullname,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Admission No: ${widget.student.studcode}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey,
                  ),
                ),
                // Tapping the comment section opens the comment dialog.
                InkWell(
                  onTap: _openCommentDialog,
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment,
                        size: screenWidth * 0.032,
                        color: Colors.blue,
                      ),
                      Text(
                        " Comment",
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bus No: ${widget.student.dob}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey,
                  ),
                ),
                // Tapping the comment section opens the comment dialog.
                InkWell(
                  onTap: _openCommentDialog,
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        size: screenWidth * 0.032,
                        color: Colors.black,
                      ),
                      Text(
                        " ${widget.student.dob}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            // If a comment exists, show it as a chip.
            if (comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: Text(comment),
                  deleteIcon: Icon(
                    Icons.close,
                    size: screenWidth * 0.032,
                  ),
                  onDeleted: () {
                    setState(() {
                      comment = "";
                    });
                  },
                ),
              ),
            const SizedBox(height: 12),
            // Attendance row with two dropdowns.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Present dropdown container.
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.student.att != null &&
                              widget.student.att!.att == "0"
                          ? Colors.green
                          : Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey,
                        isDense: true,
                        value: widget.student.att != null &&
                                presentRemarks.any((remark) =>
                                    remark.key == widget.student.att!.remark)
                            ? widget.student.att!.remark
                            : null,
                        hint: Text(
                          "Present",
                          style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: widget.student.att != null &&
                                      widget.student.att!.att == "0"
                                  ? Colors.white
                                  : Colors.black54),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue != null) {
                              var selectedRemark = presentRemarks.firstWhere(
                                  (remark) => remark.key == newValue);
                              // Update the student's attendance for present.
                              widget.student.att = StudentAttModel(
                                id: widget.student.att?.id ?? "",
                                studcode: widget.student.studcode,
                                comment: comment,
                                remark: selectedRemark.key,
                                att: "0",
                              );
                              // Update the global attendance list.
                              context.read<StudentAttendanceBloc>().add(
                                    UpdateStudentAttendanceEvent(
                                      studcode: widget.student.studcode,
                                      studentAttendance: widget.student.att!,
                                    ),
                                  );
                            }
                          });
                        },
                        items: presentRemarks.map((remark) {
                          return DropdownMenuItem<String>(
                            value: remark.key,
                            child: Text(
                              remark.value,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: widget.student.att != null &&
                                          widget.student.att!.att == "0"
                                      ? Colors.white
                                      : Colors.black54),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                // Absent dropdown container.
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.student.att != null &&
                              widget.student.att!.att == "1"
                          ? Colors.red
                          : Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey,
                        isDense: true,
                        value: widget.student.att != null &&
                                absentRemarks.any((remark) =>
                                    remark.key == widget.student.att!.remark)
                            ? widget.student.att!.remark
                            : null,
                        hint: Text(
                          "Absent",
                          style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: widget.student.att != null &&
                                      widget.student.att!.att == "1"
                                  ? Colors.white
                                  : Colors.black54),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue != null) {
                              var selectedRemark = absentRemarks.firstWhere(
                                  (remark) => remark.key == newValue);
                              // Update the student's attendance for absent.
                              widget.student.att = StudentAttModel(
                                id: widget.student.att?.id ?? "",
                                studcode: widget.student.studcode,
                                comment: comment,
                                remark: selectedRemark.key,
                                att: "1",
                              );
                              // Update the global attendance list.
                              context.read<StudentAttendanceBloc>().add(
                                    UpdateStudentAttendanceEvent(
                                      studcode: widget.student.studcode,
                                      studentAttendance: widget.student.att!,
                                    ),
                                  );
                            }
                          });
                        },
                        items: absentRemarks.map((remark) {
                          return DropdownMenuItem<String>(
                            value: remark.key,
                            child: Text(
                              remark.value,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: widget.student.att != null &&
                                          widget.student.att!.att == "1"
                                      ? Colors.white
                                      : Colors.black54),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
