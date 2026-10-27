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
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
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
      return Right(model);
    }
  }
}
