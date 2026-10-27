import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class AttendanceRepository {
  final ApiService apiService;

  AttendanceRepository({required this.apiService});
  Future<Either<MyError, AttendanceResponseModel>> getAttendance(
    int month,
    int year,
  ) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    if (authModel == null || authModel.userId.isEmpty) {
      return const Left(
        MyError(key: AppError.apiError, message: 'Please sign in again'),
      );
    }
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel.userId,
      'month': month,
      'year': year,
      'token': authModel.token,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.getAttendance(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    } else {
      final model = AttendanceResponseModel.fromJson((response.right));
      if (!model.status) {
        return Left(
          MyError(
            key: AppError.apiError,
            message: model.message.isNotEmpty
                ? model.message
                : 'Request failed',
          ),
        );
      }
      // Row `user_id` is the employee id. The login id can be different
      // (this account is 755, the rows say 772), so the token's payload
      // is shown as returned.
      return Right(model);
    }
  }
}
