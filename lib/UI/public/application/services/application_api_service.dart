import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/UI/public/shared/models/careers_api_models.dart';
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
      log(
        'API call: ${ApiConstants.myApplicationsUrl} with candId: $candId, page: $page, limit: $limit',
      );

      final result = await _apiService.getRequest(
        ApiConstants.myApplicationsUrl,
        token,
        queryParameters: {
          'cand_id': candId,
          'page': page,
          'limit': limit,
        },
        useSessionToken: true,
      );

      return result.fold(
        (error) => Left(error),
        (data) {
          try {
            final parsed = json.decode(data) as Map<String, dynamic>;
            final response = MyApplicationsResponse.fromJson(parsed);
            log(
              'Successfully fetched ${response.data.applications.length} applications',
            );
            return Right(response);
          } catch (e) {
            log('Error parsing applications response: $e');
            return Left(
              MyError(
                key: AppError.apiError,
                message: 'Failed to parse applications data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('Error fetching applications: $e');
      return Left(
        MyError(
          key: AppError.apiError,
          message: 'Failed to fetch applications: $e',
        ),
      );
    }
  }

  Future<Either<MyError, CheckApplicationResponse>> checkApplication({
    required int jobId,
    required int candId,
    String? token,
  }) async {
    try {
      log(
        'API call: ${ApiConstants.checkApplicationUrl} with jobId: $jobId, candId: $candId',
      );

      final result = await _apiService.getRequest(
        ApiConstants.checkApplicationUrl,
        token,
        queryParameters: {
          'job_id': jobId,
          'cand_id': candId,
        },
        useSessionToken: true,
      );

      return result.fold(
        (error) => Left(error),
        (data) {
          try {
            final parsed = json.decode(data) as Map<String, dynamic>;
            if (parsed['status'] == true) {
              return Right(
                CheckApplicationResponse.fromJson(
                  (parsed['data'] as Map<String, dynamic>?) ?? const {},
                ),
              );
            }
            return Left(
              MyError(
                key: AppError.apiError,
                message: careersApiErrorMessage(parsed),
              ),
            );
          } catch (e) {
            return Left(
              MyError(
                key: AppError.apiError,
                message: 'Failed to parse check-application response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        MyError(
          key: AppError.apiError,
          message: 'Failed to check application: $e',
        ),
      );
    }
  }

  Future<Either<MyError, ApplyJobResponse>> applyJob({
    required int candId,
    required int jobId,
    String? coverLetter,
    String? source,
    String? token,
  }) async {
    try {
      log(
        'API call: ${ApiConstants.applyJobUrl} with candId: $candId, jobId: $jobId',
      );

      // The profile itself serves as the CV; the backend no longer requires
      // a cv_file on apply.
      final body = <String, dynamic>{
        'cand_id': candId,
        'job_id': jobId,
      };
      if (coverLetter != null && coverLetter.isNotEmpty) {
        body['cover_letter'] = coverLetter;
      }
      body['source'] = source?.isNotEmpty == true ? source : 'Mobile App';

      final result = await _apiService.postAPI(
        url: ApiConstants.applyJobUrl,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) => Left(error),
        (data) {
          try {
            final parsed = json.decode(data) as Map<String, dynamic>;
            if (parsed['status'] == true) {
              return Right(
                ApplyJobResponse.fromJson(
                  (parsed['data'] as Map<String, dynamic>?) ?? const {},
                ),
              );
            }

            final errorData = parsed['data'] is Map<String, dynamic>
                ? ApplyJobErrorData.fromJson(
                    parsed['data'] as Map<String, dynamic>,
                  )
                : null;

            return Left(
              MyError(
                key: AppError.badRequest,
                message: careersApiErrorMessage(parsed),
                data: errorData != null
                    ? {
                        'profile_completion': errorData.profileCompletion,
                        'required_completion': errorData.requiredCompletion,
                        'is_fresher': errorData.isFresher,
                        'missing_fields': errorData.missingFields,
                      }
                    : null,
              ),
            );
          } catch (e) {
            return Left(
              MyError(
                key: AppError.apiError,
                message: 'Failed to parse apply-job response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        MyError(
          key: AppError.apiError,
          message: 'Failed to apply for job: $e',
        ),
      );
    }
  }
}
