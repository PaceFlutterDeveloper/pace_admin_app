import 'package:admin_app/UI/students/models/student_att_model.dart';
import 'package:admin_app/UI/students/models/student_response_model.dart';
import 'package:admin_app/UI/students/repository/students_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'students_cubit.freezed.dart';
part 'students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit() : super(const StudentsState.initial());

  final StudentsRepository _studentsRepository = locator<StudentsRepository>();

  Future<void> getSterudents({
    required String grade,
    required String section,
  }) async {
    emit(StudentsState.loading(
      attlist: state.attlist,
      students: state.students,
    ));
    var res =
        await _studentsRepository.getStudents(grade: grade, section: section);
    res.fold(
      (left) => emit(StudentsState.failure(
        left.message,
        attlist: state.attlist,
        students: state.students,
      )),
      (right) {
        emit(StudentsState.success(
          students: right.data.students,
          remarks: right.data.remarks,
          attlist: state.attlist,
        ));
      },
    );
  }

  /// Update or add a single student's attendance record.
  void updateStudentAttendance(StudentAttModel updatedAtt) {
    final updatedAttlist = List<StudentAttModel>.from(state.attlist);
    final index =
        updatedAttlist.indexWhere((att) => att.studcode == updatedAtt.studcode);
    if (index != -1) {
      updatedAttlist[index] = updatedAtt;
    } else {
      updatedAttlist.add(updatedAtt);
    }
    emit(state.copyWith(attlist: updatedAttlist));
  }

  /// Mark attendance for all students.
  /// [attValue] should be "0" for present or "1" for absent.
  /// [remarkKey] is the remark key to assign.
  /// [comment] is optional.
  void markAllAttendance({
    required String attValue,
    required String remarkKey,
    String comment = "",
  }) {
    final updatedAttlist = state.students.map((student) {
      return StudentAttModel(
        id: "",
        studcode: student.studcode,
        comment: comment,
        remark: remarkKey,
        att: attValue,
      );
    }).toList();

    emit(state.copyWith(attlist: updatedAttlist));
  }
}
