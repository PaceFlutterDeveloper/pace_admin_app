import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

class NfcMappRepository {
  final ApiService apiService;

  NfcMappRepository({required this.apiService});
  Future<Either<MyError, dynamic>> addNfctag(
      {required String studcode,
      required String nfcTag,
      required bool isAdd}) async {
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'page': 'assignNFCTag',
      'ACTION': isAdd ? 'ADD' : "DELETE",
      "STUD_CODE": studcode,
      'NFC_TAG': nfcTag
    });
    if (kDebugMode) {
      print('Form Data:');
    }
    for (MapEntry<String, dynamic> entry in formData.fields) {
      if (kDebugMode) {
        print('${entry.key}: ${entry.value}');
      }
    }

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
