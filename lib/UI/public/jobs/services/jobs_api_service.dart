import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:either_dart/either.dart';

class JobsApiService {
  final ApiService _apiService;

  JobsApiService({required ApiService apiService}) : _apiService = apiService;

  // Endpoints are now managed through ApiConstants

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
      // Build query parameters
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (schoolId != null && schoolId > 0) {
        queryParams['school_id'] = schoolId;
      }
      if (countryId != null && countryId > 0) {
        queryParams['country'] = countryId;
      }
      if (employmentType != null && employmentType != 'All') {
        queryParams['employment_type'] = employmentType;
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

          // Handle the API response format
          if (jsonData['status'] == true) {
            // Convert the API response to our JobResponseModel format
            final List<dynamic> jobsData = jsonData['data'] ?? [];
            final List<JobModel> jobs = jobsData
                .map((job) => JobModel.fromMap(job))
                .toList();

            final jobResponse = JobResponseModel(
              data: jobs,
              total: jsonData['pagination']?['total_count'] ?? jobs.length,
              page: jsonData['pagination']?['current_page'] ?? 1,
              limit: jsonData['pagination']?['per_page'] ?? 20,
            );

            return Right(jobResponse);
          } else {
            return Left(
              MyError(
                key: AppError.unknown,
                message: jsonData['message'] ?? 'Unknown API error',
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
            final jobData = jsonData['data'];

            // Transform the detailed response to match our JobModel structure
            final job = JobModel(
              jobId: jobData['job_id'] ?? 0,
              title: jobData['title'] ?? '',
              location: jobData['location'] ?? '',
              schoolName: jobData['school']?['name'] ?? '',
              country: jobData['country']?['name'],
              createdAt: jobData['dates']?['posted'] ?? '',
              deadline: jobData['dates']?['deadline'] ?? '',
              description: jobData['description']?['html'] ?? '',
              salary: SalaryInfo(
                range: jobData['salary']?['range'] ?? '',
                minYears: jobData['salary']?['min_years'] ?? 0,
                maxYears: jobData['salary']?['max_years'],
              ),
              employmentType: jobData['details']?['employment_type'] ?? '',
              requirements: jobData['requirements']?['skills'] ?? '',
              department: null, // Not provided in detailed response
              isActive: jobData['dates']?['is_active'] ?? true,
              status: jobData['dates']?['is_active'] == true
                  ? 'Open'
                  : 'Closed',
            );

            return Right(job);
          } else {
            return Left(
              MyError(
                key: AppError.unknown,
                message: jsonData['message'] ?? 'Unknown API error',
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
        (error) {
          return Left(error);
        },
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
                  message: jsonData['message'] ?? 'Unknown API error',
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
    // Since the API doesn't have employment_type filter, we'll filter client-side
    final result = await fetchJobs(page: page, limit: limit, token: token);

    return result.fold((error) => Left(error), (response) {
      final filteredJobs = response.data
          .where(
            (job) =>
                job.employmentType.toLowerCase() ==
                employmentType.toLowerCase(),
          )
          .toList();

      final filteredResponse = JobResponseModel(
        data: filteredJobs,
        total: filteredJobs.length,
        page: response.page,
        limit: response.limit,
      );

      return Right(filteredResponse);
    });
  }
}
