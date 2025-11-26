import 'dart:developer';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_single_ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/manage_tickets/models/manage_ticket_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

class ManageTicketRepository {
  final ApiService apiService;

  ManageTicketRepository({required this.apiService});
  Future<Either<MyError, ManageTicketResponseModel>> getTickets({
    String? action,
    int? endStat,
  }) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
      'action': action,
      'end_stat': endStat,
    });
    if (kDebugMode) {
      log('Form Data:');
    }
    for (MapEntry<String, dynamic> entry in formData.fields) {
      if (kDebugMode) {
        log('${entry.key}: ${entry.value}');
      }
    }

    var response = await apiService.postAPI(
      url: await ApiConstants.getManageTickets(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("ManageTicket error \n${response.left}");
      return Left(response.left);
    } else {
      log("ManageTicket response \n${(response.right)}");
      return Right(ManageTicketResponseModel.fromJson((response.right)));
    }
  }

  Future<Either<MyError, ManageTicketResponseModel>> updateManageTicket({
    required int id,
    required String actiion,
    int? statusId,
    String? comment,
  }) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
      "ticket_id": id,
      "action": actiion,
      "status_id": statusId,
      "comment": comment,
    });
    if (kDebugMode) {
      log('Form Data:');
    }
    for (MapEntry<String, dynamic> entry in formData.fields) {
      if (kDebugMode) {
        log('${entry.key}: ${entry.value}');
      }
    }

    var response = await apiService.postAPI(
      url: await ApiConstants.getManageTickets(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("ManageTicket error \n${response.left}");
      return Left(response.left);
    } else {
      log("ManageTicket response \n${(response.right)}");
      return Right(ManageTicketResponseModel.fromJson((response.right)));
    }
  }

  Future<Either<MyError, ManageSingleTicketResponseModel>> getSingleTicket(
      {required int id}) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
      "ticket_id": id,
    });
    if (kDebugMode) {
      log('Form Data:');
    }
    for (MapEntry<String, dynamic> entry in formData.fields) {
      if (kDebugMode) {
        log('${entry.key}: ${entry.value}');
      }
    }

    var response = await apiService.postAPI(
      url: await ApiConstants.getManageTickets(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("ManageTicket error \n${response.left}");
      return Left(response.left);
    } else {
      log("ManageTicket response \n${(response.right)}");
      return Right(ManageSingleTicketResponseModel.fromJson((response.right)));
    }
  }
}
