import 'package:admin_app/staff/class_attendance/model/grade_response_model.dart';
import 'package:admin_app/staff/students/models/attendance_marks.dart';
import 'package:admin_app/staff/students/models/student_att_model.dart';
import 'package:admin_app/staff/students/models/student_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('class list reads numeric keys and section values', () {
    final model = GradeResponseModel.fromJson('''
{
  "status": 1,
  "message": "ok",
  "data": {
    "grades": [
      {"class_key": 5, "class_value": "Grade 5", "sections": [1, "A"]}
    ],
    "default": {"gr": 5, "sec": "A"}
  }
}
''');

    final grade = model.data.grades.single;
    expect(model.status, isTrue);
    expect(grade.gradeCode, '5');
    expect(grade.label, 'Grade 5');
    expect(grade.sections, ['1', 'A']);
    expect(model.data.dataDefault.gr, '5');
    expect(model.data.dataDefault.sec, 'A');
    expect(model.data.labelFor('5'), 'Grade 5');
  });

  test('student roll survives nulls and numeric attendance fields', () {
    final parsed = StudenstsResponseModel.fromJson('''
{
  "status": true,
  "message": "ok",
  "data": {
    "students": [
      {
        "studcode": 1001,
        "fullname": null,
        "photo": null,
        "DOB": null,
        "att": {"id": 9, "att": 0, "remark": 2, "comment": null, "studcode": 1001}
      }
    ],
    "remarks": [
      {"key": 2, "value": "On time", "remark_type": 0},
      {"key": 3, "value": "Sick", "remark_type": 1}
    ]
  }
}
''');

    final student = parsed.data.students.single;
    expect(student.studcode, '1001');
    expect(student.fullname, isEmpty);
    expect(student.photo, isEmpty);
    expect(student.att, isNotNull);
    expect(student.att!.id, '9');
    expect(student.att!.att, attendancePresent);
    expect(student.att!.isMarked, isTrue);

    final present = remarksFor(parsed.data.remarks, present: true);
    final absent = remarksFor(parsed.data.remarks, present: false);
    expect(present.map((remark) => remark.key), ['2']);
    expect(absent.map((remark) => remark.key), ['3']);
    expect(defaultRemarkKey(parsed.data.remarks, present: true), '2');
  });

  test('attendance rows keep the record id and skip unmarked students', () {
    final rows = attendanceRows([
      StudentModel.fromMap({
        'studcode': '1001',
        'fullname': 'Ada',
        'att': {
          'id': '9',
          'studcode': '1001',
          'comment': 'Late bus',
          'remark': '2',
          'att': '0',
        },
      }),
      StudentModel.fromMap({'studcode': '1002', 'fullname': 'Bea'}),
    ]);

    expect(rows, hasLength(1));
    expect(rows.single, {
      'id': '9',
      'studcode': '1001',
      'comment': 'Late bus',
      'remark': '2',
      'att': '0',
    });
  });

  test('mark all present keeps the saved id and note', () {
    final marked = markAllPresent(
      [
        StudentModel.fromMap({
          'studcode': '1001',
          'fullname': 'Ada',
          'att': {
            'id': '9',
            'studcode': '1001',
            'comment': 'Called home',
            'remark': '3',
            'att': '1',
          },
        }),
        StudentModel.fromMap({'studcode': '1002', 'fullname': 'Bea'}),
        StudentModel.fromMap({
          'studcode': '1003',
          'fullname': 'Cara',
          'att': {
            'id': '11',
            'studcode': '1003',
            'comment': '',
            'remark': '4',
            'att': '0',
          },
        }),
      ],
      [
        Remark(key: '2', value: 'On time', remarkType: '0'),
        Remark(key: '4', value: 'Late', remarkType: '0'),
        Remark(key: '3', value: 'Sick', remarkType: '1'),
      ],
    );

    expect(marked[0].att!.id, '9');
    expect(marked[0].att!.comment, 'Called home');
    expect(marked[0].att!.att, attendancePresent);
    expect(marked[0].att!.remark, '2');
    expect(marked[1].att!.att, attendancePresent);
    expect(marked[1].att!.id, isEmpty);
    expect(marked[2].att!.remark, '4');
    expect(marked[2].att!.id, '11');
  });

  test('untyped remarks are offered for both present and absent', () {
    final remarks = [Remark(key: 'late', value: 'Late', remarkType: '')];
    expect(remarksFor(remarks, present: true).single.key, 'late');
    expect(remarksFor(remarks, present: false).single.key, 'late');
  });
}
