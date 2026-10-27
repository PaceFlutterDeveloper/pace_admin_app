import 'package:admin_app/staff/students/models/student_att_model.dart';
import 'package:admin_app/staff/students/models/student_model_extension.dart';
import 'package:admin_app/staff/students/models/student_response_model.dart';

bool remarkIsPresent(Remark remark) {
  final type = remark.remarkType.toLowerCase();
  if (type.isEmpty || type.contains('absent')) return false;
  if (type == '1' || type == 'a') return false;
  return type == '0' ||
      type == 'p' ||
      type.contains('present') ||
      type.contains('0');
}

bool remarkIsAbsent(Remark remark) {
  final type = remark.remarkType.toLowerCase();
  if (type.isEmpty || type.contains('present')) return false;
  if (type == '0' || type == 'p') return false;
  return type == '1' ||
      type == 'a' ||
      type.contains('absent') ||
      type.contains('1');
}

List<Remark> uniqueRemarks(Iterable<Remark> remarks) {
  final seen = <String>{};
  return [
    for (final remark in remarks)
      if (remark.key.isNotEmpty && seen.add(remark.key)) remark,
  ];
}

/// Remarks for one side of the roll. When the server sends no types, every
/// remark is offered for both Present and Absent.
List<Remark> remarksFor(List<Remark> remarks, {required bool present}) {
  final typed = uniqueRemarks(
    remarks.where(
      (remark) => present ? remarkIsPresent(remark) : remarkIsAbsent(remark),
    ),
  );
  if (typed.isNotEmpty) return typed;
  final anyTyped = remarks.any(
    (remark) => remarkIsPresent(remark) || remarkIsAbsent(remark),
  );
  if (anyTyped) return const [];
  return uniqueRemarks(remarks);
}

String defaultRemarkKey(List<Remark> remarks, {required bool present}) {
  final pool = remarksFor(remarks, present: present);
  if (pool.isEmpty) return '';
  return pool.first.key;
}

bool attendanceIsMarked(StudentModel student) => student.att?.isMarked ?? false;

int countMarked(List<StudentModel> students, String att) {
  return students.where((student) => student.att?.att == att).length;
}

/// Rows posted as `attList`. Uses the saved attendance id, never the
/// admission number, and skips students who are still unmarked.
List<Map<String, String>> attendanceRows(Iterable<StudentModel> students) {
  return [
    for (final student in students)
      if (student.att != null && student.att!.isMarked)
        {
          'id': student.att!.id,
          'studcode': student.studcode.isNotEmpty
              ? student.studcode
              : student.att!.studcode,
          'comment': student.att!.comment,
          'remark': student.att!.remark,
          'att': student.att!.att,
        },
  ];
}

List<StudentModel> markAllPresent(
  List<StudentModel> students,
  List<Remark> remarks,
) {
  final remark = defaultRemarkKey(remarks, present: true);
  return [
    for (final student in students)
      student.copyWith(
        att: (student.att ?? _blank(student)).copyWith(
          studcode: student.studcode,
          att: attendancePresent,
          remark: _keptPresentRemark(student, remark),
        ),
      ),
  ];
}

/// A student already marked present keeps that remark. Everyone else gets
/// the default present remark.
String _keptPresentRemark(StudentModel student, String fallback) {
  final current = student.att;
  if (current != null &&
      current.att == attendancePresent &&
      current.remark.isNotEmpty) {
    return current.remark;
  }
  return fallback;
}

StudentAttModel _blank(StudentModel student) {
  return StudentAttModel(
    id: '',
    studcode: student.studcode,
    comment: '',
    remark: '',
    att: attendancePresent,
  );
}
