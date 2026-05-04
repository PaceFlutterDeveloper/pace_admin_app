import 'package:admin_app/UI/employee/attendance/cubit/attendance_cubit.dart';
import 'package:admin_app/UI/employee/attendance/models/attendance_model.dart';
import 'package:admin_app/UI/employee/attendance/utils/attendance_record_status.dart';
import 'package:admin_app/UI/home/models/menu_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

class EmpAttendancePage extends StatefulWidget {
  final MenuModel menuModel;
  const EmpAttendancePage({Key? key, required this.menuModel})
      : super(key: key);

  @override
  EmpAttendancePageState createState() => EmpAttendancePageState();
}

class EmpAttendancePageState extends State<EmpAttendancePage> {
  DateTime? _selectedDay;
  // Track the currently displayed month and year.
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch attendance for the current month.
    context.read<AttendanceCubit>().getAttendance(
          month: _currentDate.month,
          year: _currentDate.year,
        );
  }

  /// Build a marked dates map from the attendance list.
  EventList<Event> _buildMarkedDatesMap(List<AttendanceModel> attendanceList) {
    final markers = EventList<Event>(events: {});
    for (final attendance in attendanceList) {
      final normalizedDate = DateUtils.dateOnly(attendance.attDate);
      final status = attendanceRecordStatusLabel(attendance);
      markers.add(
        normalizedDate,
        Event(
          date: normalizedDate,
          title: status,
          dot: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            height: 5.0,
            width: 5.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: attendanceRecordStatusColor(status),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  /// Build a widget to display attendance details for the selected day.
  Widget _buildAttendanceDetailWidget(
    DateTime selectedDay,
    List<AttendanceModel> attendanceList,
    double screenWidth,
    double screenHeight,
  ) {
    // Attempt to find the attendance record for the selected day.
    AttendanceModel? attendanceRecord;
    try {
      attendanceRecord = attendanceList.firstWhere(
        (attendance) => DateUtils.isSameDay(attendance.attDate, selectedDay),
      );
    } catch (e) {
      attendanceRecord = null;
    }

    // If no attendance record is found, display a message.
    if (attendanceRecord == null) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Text(
          "No attendance record found for ${DateFormat('yyyy-MM-dd').format(selectedDay)}",
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final status = attendanceRecordStatusLabel(attendanceRecord);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy-MM-dd').format(selectedDay),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Attendance Status"),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: attendanceRecordStatusColor(status),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Check In Time"),
                Text(
                  attendanceRecord.checkInTime,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Check Out Time"),
                Text(
                  attendanceRecord.checkOutTime.isNotEmpty
                      ? attendanceRecord.checkOutTime
                      : "N/A",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Custom header widget for the calendar.
  Widget _buildCalendarHeader({
    required DateTime currentDate,
    required VoidCallback onLeftArrowPressed,
    required VoidCallback onRightArrowPressed,
    required double screenWidth,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.01,
        horizontal: screenWidth * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: onLeftArrowPressed,
          ),
          Text(
            DateFormat('MMMM yyyy').format(currentDate),
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: onRightArrowPressed,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuModel.menuName),
      ),
      backgroundColor: ConstColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.03,
        ),
        child: BlocConsumer<AttendanceCubit, AttendanceState>(
          listener: (context, state) {
            // Add any side effects here if needed.
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loadingSuccess: (attendanceList) => Column(
                children: [
                  // Legend
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.03,
                        horizontal: screenWidth * 0.03,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _legendIndicator(
                              "Present", Colors.green, screenWidth),
                          _legendIndicator("Absent", Colors.red, screenWidth),
                          _legendIndicator("Leave", Colors.brown, screenWidth),
                          _legendIndicator("Holiday", Colors.blue, screenWidth),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Custom calendar header
                  _buildCalendarHeader(
                    currentDate: _currentDate,
                    screenWidth: screenWidth,
                    onLeftArrowPressed: () {
                      // Decrement month (reset _selectedDay).
                      final newDate = DateTime(
                        _currentDate.year,
                        _currentDate.month - 1,
                      );
                      setState(() {
                        _currentDate = newDate;
                        _selectedDay = null;
                      });
                      context.read<AttendanceCubit>().getAttendance(
                            month: newDate.month,
                            year: newDate.year,
                          );
                    },
                    onRightArrowPressed: () {
                      // Calculate the next month.
                      final newDate = DateTime(
                        _currentDate.year,
                        _currentDate.month + 1,
                      );
                      // Prevent navigating to future months.
                      final now = DateTime.now();
                      if (newDate.year > now.year ||
                          (newDate.year == now.year &&
                              newDate.month > now.month)) {
                        return;
                      }
                      setState(() {
                        _currentDate = newDate;
                        _selectedDay = null;
                      });
                      context.read<AttendanceCubit>().getAttendance(
                            month: newDate.month,
                            year: newDate.year,
                          );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Calendar widget with built-in header disabled.
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      // Provide a key that depends on _currentDate to force rebuild.
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.02),
                          child: CalendarCarousel<Event>(
                            key: ValueKey(_currentDate),
                            showHeader: false,
                            onDayPressed: (DateTime date, List<Event> events) {
                              setState(() {
                                _selectedDay = date;
                              });
                            },
                            isScrollable: false,
                            weekdayTextStyle:
                                const TextStyle(color: Colors.black),
                            weekendTextStyle:
                                const TextStyle(color: Colors.red),
                            selectedDateTime: _selectedDay,
                            targetDateTime: _currentDate,
                            markedDatesMap:
                                _buildMarkedDatesMap(attendanceList),
                            todayBorderColor: Colors.blue,
                            todayButtonColor: Colors.blue,
                            selectedDayButtonColor: Colors.blueGrey,
                            selectedDayBorderColor: Colors.blueGrey,
                            daysHaveCircularBorder: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Attendance details for the selected day (if available).
                  if (_selectedDay != null)
                    _buildAttendanceDetailWidget(
                      _selectedDay!,
                      attendanceList,
                      screenWidth,
                      screenHeight,
                    ),
                ],
              ),
              laodingFailure: (String failureText) => Center(
                child: Text(failureText),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Legend widget to show the status indicator.
Widget _legendIndicator(String title, Color color, double screenWidth) {
  return Row(
    children: [
      Container(
        width: screenWidth * 0.03,
        height: screenWidth * 0.03,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: screenWidth * 0.01),
      Text(title, style: TextStyle(fontSize: screenWidth * 0.03)),
    ],
  );
}
