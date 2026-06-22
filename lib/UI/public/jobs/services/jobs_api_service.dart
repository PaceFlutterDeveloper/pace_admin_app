import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/UI/public/shared/models/careers_api_models.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:either_dart/either.dart';

class JobsApiService {
  final ApiService _apiService;

  JobsApiService({required ApiService apiService}) : _apiService = apiService;

  Future<Either<MyError, JobResponseModel>> fetchJobs({
    String? search,
    int? schoolId,
    int? countryId,
    String? employmentType,
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['q'] = search;
      }
      if (schoolId != null && schoolId > 0) {
        queryParams['school_id'] = schoolId;
      }
      if (countryId != null && countryId > 0) {
        queryParams['country_id'] = countryId;
      }

      log('API call: ${ApiConstants.jobsUrl} with params: $queryParams');
      final result = await _apiService.getRequest(
        ApiConstants.jobsUrl,
        token,
        queryParameters: queryParams,
      );

      return result.fold((error) => Left(error), (responseData) {
        try {
          final Map<String, dynamic> jsonData = json.decode(responseData);

          if (jsonData['status'] == true) {
            final List<dynamic> jobsData = jsonData['data'] ?? [];
            final List<JobModel> jobs = jobsData
                .map((job) => JobModel.fromMap(job))
                .toList();

            final jobResponse = JobResponseModel(
              data: jobs,
              pagination: CareersPagination.fromJson(
                jsonData['pagination'] as Map<String, dynamic>?,
              ),
            );

            return Right(jobResponse);
          } else {
            return Left(
              MyError(
                key: AppError.unknown,
                message: careersApiErrorMessage(jsonData),
              ),
            );
          }
        } catch (e) {
          return Left(
            MyError(
              key: AppError.unknown,
              message: 'Failed to parse jobs data: $e',
            ),
          );
        }
      });
    } catch (e) {
      return Left(
        MyError(key: AppError.unknown, message: 'Failed to fetch jobs: $e'),
      );
    }
  }

  Future<Either<MyError, JobModel>> fetchJobDetails(
    int jobId, {
    String? token,
  }) async {
    try {
      final result = await _apiService.getRequest(
        ApiConstants.jobDetailsUrl,
        token,
        queryParameters: {'id': jobId},
      );

      return result.fold((error) => Left(error), (responseData) {
        try {
          final Map<String, dynamic> jsonData = json.decode(responseData);

          if (jsonData['status'] == true) {
            final detail = JobDetailModel.fromJson(
              jsonData['data'] as Map<String, dynamic>,
            );
            return Right(detail.toJobModel());
          } else {
            return Left(
              MyError(
                key: AppError.unknown,
                message: careersApiErrorMessage(jsonData),
              ),
            );
          }
        } catch (e) {
          return Left(
            MyError(
              key: AppError.unknown,
              message: 'Failed to parse job details: $e',
            ),
          );
        }
      });
    } catch (e) {
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to fetch job details: $e',
        ),
      );
    }
  }

  Future<Either<MyError, SchoolResponseModel>> fetchSchools({
    String? token,
  }) async {
    try {
      final result = await _apiService.getRequest(
        ApiConstants.schoolsUrl,
        token,
      );

      return result.fold(
        (error) => Left(error),
        (responseData) {
          try {
            final Map<String, dynamic> jsonData = json.decode(responseData);

            if (jsonData['status'] == true) {
              final schoolResponse = SchoolResponseModel.fromMap(jsonData);
              return Right(schoolResponse);
            } else {
              return Left(
                MyError(
                  key: AppError.unknown,
                  message: careersApiErrorMessage(jsonData),
                ),
              );
            }
          } catch (e) {
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse schools data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        MyError(key: AppError.unknown, message: 'Failed to fetch schools: $e'),
      );
    }
  }

  Future<Either<MyError, JobResponseModel>> searchJobs(
    String query, {
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    return fetchJobs(search: query, page: page, limit: limit, token: token);
  }

  Future<Either<MyError, JobResponseModel>> filterJobsBySchool(
    int schoolId, {
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    return fetchJobs(
      schoolId: schoolId,
      page: page,
      limit: limit,
      token: token,
    );
  }

  Future<Either<MyError, JobResponseModel>> filterJobsByCountry(
    int countryId, {
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    return fetchJobs(
      countryId: countryId,
      page: page,
      limit: limit,
      token: token,
    );
  }

  Future<Either<MyError, JobResponseModel>> filterJobsByEmploymentType(
    String employmentType, {
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    final result = await fetchJobs(page: page, limit: limit, token: token);

    return result.fold((error) => Left(error), (response) {
      final filteredJobs = response.data
          .where(
            (job) =>
                job.employmentType.toLowerCase() ==
                employmentType.toLowerCase(),
          )
          .toList();

      return Right(
        JobResponseModel(
          data: filteredJobs,
          pagination: response.pagination,
        ),
      );
    });
  }
}
