import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:either_dart/either.dart';

class ProfileApiService {
  final ApiService _apiService;

  ProfileApiService({required ApiService apiService})
      : _apiService = apiService;

  // Get Profile
  Future<Either<MyError, ProfileModel>> getProfile({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Token: ${token}');
      log('ProfileApiService: Fetching profile for candidate: $candidateId');

      const url = ApiConstants.profileUrl;
      final queryParams = {
        'cand_id': candidateId,
      };

      log('ProfileApiService: URL: $url');
      log('ProfileApiService: Query params: $queryParams');
      log('ProfileApiService: Token: ${token != null ? 'provided' : 'null'}');

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get profile failed - ${error.message}');
          log('ProfileApiService: Error details: ${error.toString()}');
          return Left(error);
        },
        (responseData) {
          try {
            log('ProfileApiService: Raw response: $responseData');
            final response = json.decode(responseData);
            log('ProfileApiService: Parsed response: $response');

            if (response['status'] == true) {
              log('ProfileApiService: Profile retrieved successfully');
              final profile =
                  ProfileModel.fromJson(response['data']['candidate']);
              return Right(profile);
            } else {
              log('ProfileApiService: Get profile failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to get profile',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse profile data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update Profile
  Future<Either<MyError, Map<String, dynamic>>> updateProfile({
    required int candidateId,
    required Map<String, dynamic> profileData,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating profile for candidate: $candidateId');
      log('ProfileApiService: Profile data: $profileData');

      final url = ApiConstants.updateProfileUrl;

      // Build request body with all required fields
      final body = <String, dynamic>{
        'cand_id': candidateId,
        // Add any other fields from the API specification that might be required
        // For now, just send the fields being updated
        ...profileData,
      };

      // Remove null values to avoid sending them
      body.removeWhere((key, value) => value == null || value == '');

      log('ProfileApiService: Request body: $body');
      log('ProfileApiService: Request URL: $url');

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update profile failed - ${error.message}');
          log('ProfileApiService: Error key - ${error.key}');
          // Return the error with the message already set from _handleError
          return Left(error);
        },
        (responseData) {
          try {
            log('ProfileApiService: Raw response: $responseData');
            final response = json.decode(responseData);
            log('ProfileApiService: Parsed response: $response');

            if (response['status'] == true) {
              log('ProfileApiService: Profile updated successfully');
              return Right(response['data']);
            } else {
              // Get the error message from either 'message' or 'error' field
              final errorMessage = response['message'] ??
                  response['error'] ??
                  'Failed to update profile';
              log('ProfileApiService: Update profile failed - $errorMessage');
              return Left(MyError(
                key: AppError.apiError,
                message: errorMessage,
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update Education
  Future<Either<MyError, Map<String, dynamic>>> updateEducation({
    required int candidateId,
    required List<EducationRecord> educationRecords,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating education for candidate: $candidateId');

      final url = ApiConstants.updateEducationUrl;
      final body = {
        'cand_id': candidateId,
        'education_records': educationRecords.map((e) => e.toJson()).toList(),
      };

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update education failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Education updated successfully');
              return Right(response['data']);
            } else {
              log('ProfileApiService: Update education failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to update education',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update Experience
  Future<Either<MyError, Map<String, dynamic>>> updateExperience({
    required int candidateId,
    required List<ExperienceRecord> experienceRecords,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating experience for candidate: $candidateId');

      final url = ApiConstants.updateExperienceUrl;
      final body = {
        'cand_id': candidateId,
        'experience_records': experienceRecords.map((e) => e.toJson()).toList(),
      };

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update experience failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Experience updated successfully');
              return Right(response['data']);
            } else {
              log('ProfileApiService: Update experience failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to update experience',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update Family
  Future<Either<MyError, Map<String, dynamic>>> updateFamily({
    required int candidateId,
    required List<FamilyMember> familyMembers,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating family for candidate: $candidateId');

      final url = ApiConstants.updateFamilyUrl;
      final body = {
        'cand_id': candidateId,
        'family_members': familyMembers.map((e) => e.toJson()).toList(),
      };

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update family failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Family updated successfully');
              return Right(response['data']);
            } else {
              log('ProfileApiService: Update family failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to update family',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update References
  Future<Either<MyError, Map<String, dynamic>>> updateReferences({
    required int candidateId,
    required List<Reference> references,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating references for candidate: $candidateId');

      final url = ApiConstants.updateReferencesUrl;
      final body = {
        'cand_id': candidateId,
        'references': references.map((e) => e.toJson()).toList(),
      };

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update references failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: References updated successfully');
              return Right(response['data']);
            } else {
              log('ProfileApiService: Update references failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to update references',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return const Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: bursts e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update Professional Programs
  Future<Either<MyError, Map<String, dynamic>>> updateProfessionalPrograms({
    required int candidateId,
    required List<ProfessionalProgram> programs,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating professional programs for candidate: $candidateId');

      final url = ApiConstants.updateProfessionalProgramsUrl;
      final body = {
        'cand_id': candidateId,
        'professional_programs': programs.map((e) => e.toJson()).toList(),
      };

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update professional programs failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Professional programs updated successfully');
              return Right(response['data']);
            } else {
              log('ProfileApiService: Update professional programs failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ??
                    'Failed to update professional programs',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Update Complete Profile
  Future<Either<MyError, Map<String, dynamic>>> updateCompleteProfile({
    required CompleteProfileModel completeProfile,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating complete profile for candidate: ${completeProfile.candidateId}');

      final url = ApiConstants.updateCompleteProfileUrl;
      final body = completeProfile.toJson();

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Update complete profile failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Complete profile updated successfully');
              return Right(response['data']);
            } else {
              log('ProfileApiService: Update complete profile failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message:
                    response['message'] ?? 'Failed to update complete profile',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse response: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Get Education Records
  Future<Either<MyError, List<EducationRecord>>> getEducation({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching education for candidate: $candidateId');

      const url = ApiConstants.getEducationUrl;
      final queryParams = {
        'cand_id': candidateId,
      };

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get education failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Education retrieved successfully');
              final records =
                  (response['data']['education_records'] as List<dynamic>?)
                          ?.map((e) => EducationRecord.fromJson(e))
                          .toList() ??
                      [];
              return Right(records);
            } else {
              log('ProfileApiService: Get education failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to get education',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse education data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Get Experience Records
  Future<Either<MyError, List<ExperienceRecord>>> getExperience({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching experience for candidate: $candidateId');

      const url = ApiConstants.getExperienceUrl;
      final queryParams = {
        'cand_id': candidateId,
      };

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get experience failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Experience retrieved successfully');
              final records =
                  (response['data']['experience_records'] as List<dynamic>?)
                          ?.map((e) => ExperienceRecord.fromJson(e))
                          .toList() ??
                      [];
              return Right(records);
            } else {
              log('ProfileApiService: Get experience failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to get experience',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse experience data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Get Family Members
  Future<Either<MyError, List<FamilyMember>>> getFamily({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching family for candidate: $candidateId');

      const url = ApiConstants.getFamilyUrl;
      final queryParams = {
        'cand_id': candidateId,
      };

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get family failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Family retrieved successfully');
              final records =
                  (response['data']['family_members'] as List<dynamic>?)
                          ?.map((e) => FamilyMember.fromJson(e))
                          .toList() ??
                      [];
              return Right(records);
            } else {
              log('ProfileApiService: Get family failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to get family',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse family data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Get References
  Future<Either<MyError, List<Reference>>> getReferences({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching references for candidate: $candidateId');

      const url = ApiConstants.getReferencesUrl;
      final queryParams = {
        'cand_id': candidateId,
      };

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get references failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: References retrieved successfully');
              final records = (response['data']['references'] as List<dynamic>?)
                      ?.map((e) => Reference.fromJson(e))
                      .toList() ??
                  [];
              return Right(records);
            } else {
              log('ProfileApiService: Get references failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to get references',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse references data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }

  // Get Professional Programs
  Future<Either<MyError, List<ProfessionalProgram>>> getProfessionalPrograms({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching professional programs for candidate: $candidateId');

      const url = ApiConstants.getProfessionalProgramsUrl;
      final queryParams = {
        'cand_id': candidateId,
      };

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get professional programs failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Professional programs retrieved successfully');
              final records =
                  (response['data']['professional_programs'] as List<dynamic>?)
                          ?.map((e) => ProfessionalProgram.fromJson(e))
                          .toList() ??
                      [];
              return Right(records);
            } else {
              log('ProfileApiService: Get professional programs failed - ${response['message']}');
              return Left(MyError(
                key: AppError.apiError,
                message: response['message'] ??
                    'Failed to get professional programs',
              ));
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(MyError(
              key: AppError.unknown,
              message: 'Failed to parse professional programs data: $e',
            ));
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(MyError(
        key: AppError.unknown,
        message: 'Unexpected error: ${e.toString()}',
      ));
    }
  }
}
