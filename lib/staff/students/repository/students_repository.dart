import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';
import 'package:admin_app/staff/students/models/student_response_model.dart';
import 'package:either_dart/either.dart';
import 'package:intl/intl.dart';

class StudentsRepository {
  final ApiService apiService;

  StudentsRepository({required this.apiService});

  Future<Either<MyError, StudenstsResponseModel>> getStudents({
    required String grade,
    required String section,
  }) async {
    try {
      final body = await postStaffPage(
        api: apiService,
        url: ApiConstants.getclassAttendance(),
        fields: {'gr': grade, 'sec': section, 'date': _today()},
      );
      return Right(StudenstsResponseModel.fromMap(body));
    } on StaffApiException catch (error) {
      return Left(
        MyError(
          key: AppError.apiError,
          message: _message(error.message, 'Could not load this class'),
        ),
      );
    } catch (_) {
      return const Left(
        MyError(key: AppError.unknown, message: 'Could not load this class'),
      );
    }
  }

  Future<Either<MyError, String>> markAttendance({
    required String grade,
    required String section,
    required String status,
    required List<Map<String, String>> attList,
  }) async {
    if (attList.isEmpty) {
      return const Left(
        MyError(key: AppError.badRequest, message: 'Mark at least one student'),
      );
    }
    try {
      final body = await postStaffPage(
        api: apiService,
        url: ApiConstants.getclassAttendance(),
        fields: {
          'gr': grade,
          'sec': section,
          'status': status,
          'date': _today(),
          // One row per student: id, studcode, comment, remark, att.
          'attList': attList,
        },
      );
      final message = plainText(readString(body['message']));
      return Right(message.isEmpty ? 'Attendance saved' : message);
    } on StaffApiException catch (error) {
      return Left(
        MyError(
          key: AppError.apiError,
          message: _message(error.message, 'Could not save attendance'),
        ),
      );
    } catch (_) {
      return const Left(
        MyError(key: AppError.unknown, message: 'Could not save attendance'),
      );
    }
  }
}

String _today() => DateFormat('dd/MM/yyyy').format(DateTime.now());

String _message(String raw, String fallback) {
  final text = plainText(raw);
  return text.isEmpty ? fallback : text;
}
