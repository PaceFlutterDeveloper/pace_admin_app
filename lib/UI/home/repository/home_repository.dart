import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/home/models/menu_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeRepository {
  final ApiService apiService;

  HomeRepository({required this.apiService});
  // Add your repository methods and properties here
  Future<Either<MyError, MenuResponseModel>> getMenu() async {
    AuthModel? authModel = await AuthData.getActiveUser();

    // Fetch App Version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version; // e.g., "1.0.0"

    // Create FormData with App Version
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'version': appVersion, // Send app version
      // 'sub_version': month,
      'token': authModel.token,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.getUserMenu(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    }
    return Right(MenuResponseModel.fromJson((response.right)));
  }
}
