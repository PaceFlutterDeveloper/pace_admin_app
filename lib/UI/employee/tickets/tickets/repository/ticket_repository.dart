import 'dart:developer';
import 'dart:io';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/form_config_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/raise_ticket_response.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/single_ticket_response_model.dart';
import 'package:admin_app/UI/employee/tickets/tickets/models/ticket_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:path/path.dart' as p;

class TicketRepository {
  final ApiService apiService;

  TicketRepository({required this.apiService});
  Future<Either<MyError, SingleTicketResponseModel>> getSingleTicket(
      {required int id}) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
      "ticket_id": id,
    });
    // if (kDebugMode) {
    //   log('Form Data:');
    // }
    // for (MapEntry<String, dynamic> entry in formData.fields) {
    //   if (kDebugMode) {
    //     log('${entry.key}: ${entry.value}');
    //   }
    // }

    var response = await apiService.postAPI(
      url: await ApiConstants.getTickets(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("ManageTicket error \n${response.left}");
      return Left(response.left);
    } else {
      log("ManageTicket response \n${(response.right)}");
      return Right(SingleTicketResponseModel.fromJson((response.right)));
    }
  }

  Future<Either<MyError, TicketResponseModel>> getTickets() async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
      'action': "my_tickets",
      "requester_id": authModel.userId,
    });
    // if (kDebugMode) {
    //   log('Form Data:');
    // }
    // for (MapEntry<String, dynamic> entry in formData.fields) {
    //   if (kDebugMode) {
    //     log('${entry.key}: ${entry.value}');
    //   }
    // }

    var response = await apiService.postAPI(
      url: await ApiConstants.getTickets(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("ManageTicket error \n${response.left}");
      return Left(response.left);
    } else {
      // log("ManageTicket response \n${(response.right)}");
      return Right(TicketResponseModel.fromJson((response.right)));
    }
  }

  Future<Either<MyError, FormConfigModel>> getTcketFormConfig() async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
      "action": "get_ticket_config",
    });
    // if (kDebugMode) {
    //   log('Form Data:');
    // }
    // for (MapEntry<String, dynamic> entry in formData.fields) {
    //   if (kDebugMode) {
    //     log('${entry.key}: ${entry.value}');
    //   }
    // }

    var response = await apiService.postAPI(
      url: await ApiConstants.getTickets(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("ManageTicket error \n${response.left}");
      return Left(response.left);
    } else {
      log("ManageTicket response \n${(response.right)}");
      return Right(FormConfigModel.fromRawJson((response.right)));
    }
  }

  /// Raises a new ticket.
  /// Returns either a [MyError] or the API’s simple success response.
  Future<Either<MyError, RaiseTicketResponse>> createTicket({
    required int ticketTypeId,
    required int categoryId,
    required int locationId,
    required int priorityId,
    required String description,
    File? attachment,
  }) async {
    // 1) get the logged-in user
    AuthModel? authModel = await AuthData.getActiveUser();

    if (authModel == null) {
      return const Left(
        MyError(
          key: AppError.unauthorized,
          message: 'User not authenticated',
        ),
      );
    }

    // 2) build the form data
    final formData = FormData.fromMap({
      'action': 'raise_ticket',
      'admin_id': authModel!.userId,
      'token': authModel.token,
      'requester_id': authModel.userId,
      'ticket_type_id': ticketTypeId,
      'category_id': categoryId,
      'location_id': locationId,
      'priority_id': priorityId,
      'description': description,
      // we omit 'attachment' for now, handle below
    });

    if (attachment != null) {
      final fileName = p.basename(attachment.path);
      formData.files.add(
        MapEntry(
          'attachment',
          await MultipartFile.fromFile(
            attachment.path,
            filename: fileName,
          ),
        ),
      );
    }

    // 3) debug‐print the payload
    // if (kDebugMode) {
    //   log('→ Raising ticket with:');
    //   formData.fields.forEach((f) => log('${f.key}: ${f.value}'));
    //   formData.files
    //       .forEach((f) => log('file: ${f.key} → ${f.value.filename}'));
    // }

    // 4) POST it
    final response = await apiService.postAPI(
      url: await ApiConstants.getTickets(), // or your raise endpoint
      body: formData,
    );

    // 5) handle errors
    if (response.isLeft) {
      return Left(response.left);
    } else {
      return Right(RaiseTicketResponse.fromJson(response.right));
    }
  }
}
