import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class NfcMappRepository {
  final ApiService apiService;

  NfcMappRepository({required this.apiService});
  Future<Either<MyError, dynamic>> addNfctag({
    required String studcode,
    required String nfcTag,
    required bool isAdd,
  }) async {
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'page': 'assignNFCTag',
      'ACTION': isAdd ? 'ADD' : "DELETE",
      "STUD_CODE": studcode,
      'NFC_TAG': nfcTag,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.nfcMappy(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    } else {
      return Right(response.right);
    }
  }
}
