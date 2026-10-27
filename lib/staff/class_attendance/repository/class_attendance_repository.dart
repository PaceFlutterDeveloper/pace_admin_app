import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/class_attendance/model/grade_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class ClassAttendanceRepository {
  final ApiService apiService;

  ClassAttendanceRepository({required this.apiService});

  Future<Either<MyError, GradeResponseModel>> getGrades() async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.getclassAttendance(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    } else {
      return Right(GradeResponseModel.fromJson((response.right)));
    }
  }
}
