import 'dart:developer';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:either_dart/either.dart';

import '../models/application_models.dart';

class ApplicationApiService {
  final ApiService _apiService;

  ApplicationApiService({required ApiService apiService})
      : _apiService = apiService;

  Future<Either<MyError, MyApplicationsResponse>> getMyApplications({
    required int candId,
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    try {
      log('API call: ${ApiConstants.myApplicationsUrl} with candId: $candId, page: $page, limit: $limit');

      final result = await _apiService.getRequest(
        ApiConstants.myApplicationsUrl,
        token,
        queryParameters: {
          'cand_id': candId,
          'page': page,
          'limit': limit,
        },
      );

      return result.fold(
        (error) => Left(error),
        (data) {
          try {
            final response = MyApplicationsResponse.fromJson(data);
            log('Successfully fetched ${response.data.applications.length} applications');
            return Right(response);
          } catch (e) {
            log('Error parsing applications response: $e');
            return Left(MyError(
              key: AppError.apiError,
              message: 'Failed to parse applications data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('Error fetching applications: $e');
      return Left(MyError(
        key: AppError.apiError,
        message: 'Failed to fetch applications: $e',
      ));
    }
  }
}
