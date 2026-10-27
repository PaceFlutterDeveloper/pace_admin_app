import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/class_attendance/model/grade_response_model.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/shared/staff_post.dart';
import 'package:either_dart/either.dart';

class ClassAttendanceRepository {
  final ApiService apiService;

  ClassAttendanceRepository({required this.apiService});

  Future<Either<MyError, GradeResponseModel>> getGrades() async {
    try {
      final body = await postStaffPage(
        api: apiService,
        url: ApiConstants.getclassAttendance(),
        fields: const {},
      );
      return Right(GradeResponseModel.fromMap(body));
    } on StaffApiException catch (error) {
      return Left(
        MyError(key: AppError.apiError, message: _message(error.message)),
      );
    } catch (_) {
      return const Left(
        MyError(key: AppError.unknown, message: 'Could not load classes'),
      );
    }
  }
}

String _message(String raw) {
  final text = plainText(raw);
  return text.isEmpty ? 'Could not load classes' : text;
}
