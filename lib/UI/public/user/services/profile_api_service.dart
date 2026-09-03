import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/UI/public/user/models/country_model.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/utils/careers_api_dates.dart';
import 'package:admin_app/UI/public/user/utils/profile_file_multipart.dart';
import 'package:admin_app/UI/public/user/utils/profile_file_paths.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_post_logger.dart';
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
      log('ProfileApiService: Fetching profile for candidate: $candidateId');

      final url = ApiConstants.profileUrl;
      final queryParams = {'cand_id': candidateId};

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
            // log('ProfileApiService: Raw response: $responseData');
            final response = json.decode(responseData);
            log('ProfileApiService: Parsed response: $response');

            if (response['status'] == true) {
              final dataRaw = response['data'];
              if (dataRaw is! Map) {
                return const Left(
                  MyError(
                    key: AppError.apiError,
                    message: 'Failed to get profile',
                  ),
                );
              }

              final data = Map<String, dynamic>.from(dataRaw);
              final normalized = ProfileFilePaths.normalizeUploadData(data);
              final candidate =
                  ProfileFilePaths.extractCandidateMap(normalized) ??
                  const <String, dynamic>{};
              final profile = ProfileModel.fromJson(candidate);
              _logGetProfilePhoto(candidate, data, profile.avatarFile);
              return Right(profile);
            } else {
              log(
                'ProfileApiService: Get profile failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to get profile',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse profile data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  void _logGetProfilePhoto(
    Map<String, dynamic> candidate,
    Map<String, dynamic> data,
    String? parsedAvatar,
  ) {
    const keys = [
      'avatar_file',
      'profile_image',
      'avatar',
      'photo',
      'profile_photo',
    ];
    String describe(dynamic value) {
      if (value == null) return 'null';
      if (value is Map) return 'map(keys=${value.keys.join(',')})';
      final text = value.toString();
      if (text.isEmpty) return 'empty';
      final sample = text.length <= 120 ? text : '${text.substring(0, 120)}…';
      return '${text.length} chars: $sample';
    }

    final buffer = StringBuffer('ProfileApiService: get-profile photo fields\n');
    for (final key in keys) {
      buffer.writeln('  data.$key = ${describe(data[key])}');
      buffer.writeln('  candidate.$key = ${describe(candidate[key])}');
    }
    buffer.writeln(
      parsedAvatar == null || parsedAvatar.isEmpty
          ? '  parsed avatarFile = NOT PRESENT'
          : '  parsed avatarFile = ${describe(parsedAvatar)}',
    );
    log(buffer.toString());
  }

  // Update Profile (JSON only — photos go to POST /update-profile-photo)
  Future<Either<MyError, Map<String, dynamic>>> updateProfile({
    required int candidateId,
    required Map<String, dynamic> profileData,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Updating profile for candidate: $candidateId');

      final url = ApiConstants.updateProfileUrl;

      final body = <String, dynamic>{
        'cand_id': candidateId,
        ...profileData,
      };
      _prepareUpdateProfileBody(body);

      log('ProfileApiService: Request URL: $url');
      log(
        'ProfileApiService: Request payload: ${ApiPostLogger.summarizePayload(body)}',
      );

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
            // log('ProfileApiService: Raw response: $responseData');
            final response = json.decode(responseData);
            log('ProfileApiService: Parsed response: $response');

            if (response['status'] == true) {
              log('ProfileApiService: Profile updated successfully');
              final dataRaw = response['data'];
              final data = dataRaw is Map
                  ? Map<String, dynamic>.from(dataRaw)
                  : <String, dynamic>{};
              return Right(data);
            } else {
              // Get the error message from either 'message' or 'error' field
              final errorMessage =
                  response['message'] ??
                  response['error'] ??
                  'Failed to update profile';
              log('ProfileApiService: Update profile failed - $errorMessage');
              return Left(
                MyError(key: AppError.apiError, message: errorMessage),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
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
      final rows = _validatedSectionRows(
        educationRecords,
        isValid: (e) => e.isValidForApi,
        toJson: (e) => e.toJson(),
        invalidMessage:
            'Each education record needs a course/qualification and board/university.',
      );
      if (rows.isLeft) return Left(rows.left);

      final body = {
        'cand_id': candidateId,
        'education_records': rows.right,
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
              log(
                'ProfileApiService: Update education failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to update education',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
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
      final rows = _validatedSectionRows(
        experienceRecords,
        isValid: (e) => e.isValidForApi,
        toJson: (e) => e.toJson(),
        invalidMessage:
            'Each experience record needs an organization.',
      );
      if (rows.isLeft) return Left(rows.left);

      final body = {
        'cand_id': candidateId,
        'experience_records': rows.right,
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
              log(
                'ProfileApiService: Update experience failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to update experience',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
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
      final rows = _validatedSectionRows(
        familyMembers,
        isValid: (e) => e.isValidForApi,
        toJson: (e) => e.toJson(),
        invalidMessage:
            'Each family member needs a name and relation.',
      );
      if (rows.isLeft) return Left(rows.left);

      final body = {
        'cand_id': candidateId,
        'family_members': rows.right,
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
              log(
                'ProfileApiService: Update family failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to update family',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
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
      final rows = _validatedSectionRows(
        references,
        isValid: (e) => e.isValidForApi,
        toJson: (e) => e.toJson(),
        invalidMessage: 'Each reference needs a name.',
      );
      if (rows.isLeft) return Left(rows.left);

      final body = {
        'cand_id': candidateId,
        'references': rows.right,
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
              log(
                'ProfileApiService: Update references failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to update references',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Update Professional Programs
  Future<Either<MyError, Map<String, dynamic>>> updateProfessionalPrograms({
    required int candidateId,
    required List<ProfessionalProgram> programs,
    String? token,
  }) async {
    try {
      log(
        'ProfileApiService: Updating professional programs for candidate: $candidateId',
      );

      final url = ApiConstants.updateProfessionalProgramsUrl;
      final rows = _validatedSectionRows(
        programs,
        isValid: (e) => e.isValidForApi,
        toJson: (e) => e.toJson(),
        invalidMessage: 'Each professional program needs a course name.',
      );
      if (rows.isLeft) return Left(rows.left);

      final body = {
        'cand_id': candidateId,
        'professional_programs': rows.right,
      };

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log(
            'ProfileApiService: Update professional programs failed - ${error.message}',
          );
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log(
                'ProfileApiService: Professional programs updated successfully',
              );
              return Right(response['data']);
            } else {
              log(
                'ProfileApiService: Update professional programs failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message:
                      response['message'] ??
                      'Failed to update professional programs',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Update Complete Profile
  Future<Either<MyError, Map<String, dynamic>>> updateCompleteProfile({
    required CompleteProfileModel completeProfile,
    String? token,
  }) async {
    try {
      log(
        'ProfileApiService: Updating complete profile for candidate: ${completeProfile.candidateId}',
      );

      final url = ApiConstants.updateCompleteProfileUrl;
      final body = completeProfile.toJson();

      final result = await _apiService.postAPI(
        url: url,
        body: body,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log(
            'ProfileApiService: Update complete profile failed - ${error.message}',
          );
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log('ProfileApiService: Complete profile updated successfully');
              return Right(response['data']);
            } else {
              log(
                'ProfileApiService: Update complete profile failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message:
                      response['message'] ??
                      'Failed to update complete profile',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Education Records
  Future<Either<MyError, List<EducationRecord>>> getEducation({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching education for candidate: $candidateId');

      final url = ApiConstants.getEducationUrl;
      final queryParams = {'cand_id': candidateId};

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
              return Right(
                _mapSectionRecords(
                  response['data'],
                  'education_records',
                  EducationRecord.fromJson,
                ),
              );
            } else {
              log(
                'ProfileApiService: Get education failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to get education',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse education data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Experience Records
  Future<Either<MyError, List<ExperienceRecord>>> getExperience({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching experience for candidate: $candidateId');

      final url = ApiConstants.getExperienceUrl;
      final queryParams = {'cand_id': candidateId};

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
              return Right(
                _mapSectionRecords(
                  response['data'],
                  'experience_records',
                  ExperienceRecord.fromJson,
                ),
              );
            } else {
              log(
                'ProfileApiService: Get experience failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to get experience',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse experience data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Family Members
  Future<Either<MyError, List<FamilyMember>>> getFamily({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching family for candidate: $candidateId');

      final url = ApiConstants.getFamilyUrl;
      final queryParams = {'cand_id': candidateId};

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
              return Right(
                _mapSectionRecords(
                  response['data'],
                  'family_members',
                  FamilyMember.fromJson,
                ),
              );
            } else {
              log(
                'ProfileApiService: Get family failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to get family',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse family data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get References
  Future<Either<MyError, List<Reference>>> getReferences({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching references for candidate: $candidateId');

      final url = ApiConstants.getReferencesUrl;
      final queryParams = {'cand_id': candidateId};

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
              return Right(
                _mapSectionRecords(
                  response['data'],
                  'references',
                  Reference.fromJson,
                ),
              );
            } else {
              log(
                'ProfileApiService: Get references failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message: response['message'] ?? 'Failed to get references',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse references data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Professional Programs
  Future<Either<MyError, List<ProfessionalProgram>>> getProfessionalPrograms({
    required int candidateId,
    String? token,
  }) async {
    try {
      log(
        'ProfileApiService: Fetching professional programs for candidate: $candidateId',
      );

      final url = ApiConstants.getProfessionalProgramsUrl;
      final queryParams = {'cand_id': candidateId};

      final result = await _apiService.getRequest(
        url,
        token,
        queryParameters: queryParams,
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log(
            'ProfileApiService: Get professional programs failed - ${error.message}',
          );
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              log(
                'ProfileApiService: Professional programs retrieved successfully',
              );
              return Right(
                _mapSectionRecords(
                  response['data'],
                  'professional_programs',
                  ProfessionalProgram.fromJson,
                ),
              );
            } else {
              log(
                'ProfileApiService: Get professional programs failed - ${response['message']}',
              );
              return Left(
                MyError(
                  key: AppError.apiError,
                  message:
                      response['message'] ??
                      'Failed to get professional programs',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse professional programs data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get full profile including all sections
  Future<Either<MyError, FullProfileResponse>> getFullProfile({
    required int candidateId,
    String? token,
  }) async {
    try {
      log('ProfileApiService: Fetching full profile for candidate: $candidateId');

      final result = await _apiService.getRequest(
        ApiConstants.profileUrl,
        token,
        queryParameters: {'cand_id': candidateId},
        useSessionToken: true,
      );

      return result.fold(
        (error) => Left(error),
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              return Right(
                FullProfileResponse.fromJson(
                  response['data'] as Map<String, dynamic>? ?? {},
                ),
              );
            }
            return Left(
              MyError(
                key: AppError.apiError,
                message: response['message'] ?? 'Failed to get profile',
              ),
            );
          } catch (e) {
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse full profile data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Profile Completion (full response)
  Future<Either<MyError, ProfileCompletionResponse>>
  getProfileCompletionResponse({
    required int candidateId,
    String? token,
  }) async {
    try {
      final result = await _apiService.getRequest(
        ApiConstants.profileCompletionUrl,
        token,
        queryParameters: {'cand_id': candidateId},
        useSessionToken: true,
      );

      return result.fold(
        (error) => Left(error),
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              return Right(
                ProfileCompletionResponse.fromJson(
                  response['data'] as Map<String, dynamic>? ?? {},
                ),
              );
            }
            return Left(
              MyError(
                key: AppError.apiError,
                message:
                    response['message'] ?? 'Profile completion check failed',
              ),
            );
          } catch (e) {
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse profile completion data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Profile Completion (legacy alias — returns merged model)
  Future<Either<MyError, ProfileCompletionModel>> getProfileCompletion({
    required int candidateId,
    String? token,
  }) async {
    try {
      log(
        'ProfileApiService: Checking profile completion for candidate: $candidateId',
      );

      final result = await _apiService.getRequest(
        ApiConstants.profileCompletionUrl,
        token,
        queryParameters: {'cand_id': candidateId},
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log(
            'ProfileApiService: Profile completion check failed - ${error.message}',
          );
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              final data = response['data'] as Map<String, dynamic>? ?? {};
              final completion = ProfileCompletionModel.fromApiData(data);
              return Right(completion);
            } else {
              return Left(
                MyError(
                  key: AppError.apiError,
                  message:
                      response['message'] ?? 'Profile completion check failed',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse profile completion data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Get Countries
  Future<Either<MyError, List<CountryModel>>> getCountries() async {
    try {
      log('ProfileApiService: Fetching countries');

      final result = await _apiService.getRequest(
        ApiConstants.countriesUrl,
        null,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Get countries failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);

            // Tolerate both `{status, data: {countries: []}}` and plain lists.
            List<dynamic>? rawList;
            if (response is List) {
              rawList = response;
            } else if (response is Map<String, dynamic>) {
              final data = response['data'];
              if (data is List) {
                rawList = data;
              } else if (data is Map<String, dynamic>) {
                rawList = data['countries'] as List<dynamic>?;
              }
              rawList ??= response['countries'] as List<dynamic>?;
            }

            if (rawList == null) {
              return Left(
                MyError(
                  key: AppError.apiError,
                  message:
                      (response is Map<String, dynamic>
                          ? response['message']
                          : null) ??
                      'Failed to load countries',
                ),
              );
            }

            final countries = rawList
                .whereType<Map<String, dynamic>>()
                .map(CountryModel.fromJson)
                .where((c) => c.name.isNotEmpty)
                .toList();
            return Right(countries);
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse countries data: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  // Upload the avatar as multipart on POST /update-profile-photo.
  Future<Either<MyError, Map<String, dynamic>>> uploadProfileFiles({
    required int candidateId,
    String? avatarFilePath,
    String? token,
  }) async {
    try {
      log(
        'ProfileApiService: Uploading profile photo for candidate: $candidateId',
      );

      if (!ProfileFileMultipart.hasFiles(avatarFilePath: avatarFilePath)) {
        return const Left(
          MyError(
            key: AppError.apiError,
            message: 'No files selected for upload',
          ),
        );
      }

      final formData = await ProfileFileMultipart.buildFormData(
        fields: {'cand_id': candidateId},
        avatarFilePath: avatarFilePath,
      );

      log(
        'ProfileApiService: Upload payload: ${ApiPostLogger.summarizePayload(formData)}',
      );

      final result = await _apiService.postAPI(
        url: ApiConstants.updateProfilePhotoUrl,
        body: formData,
        authorization: token ?? '',
        useSessionToken: true,
      );

      return result.fold(
        (error) {
          log('ProfileApiService: Upload files failed - ${error.message}');
          return Left(error);
        },
        (responseData) {
          try {
            final response = json.decode(responseData);
            if (response['status'] == true) {
              final dataRaw = response['data'];
              final data = dataRaw is Map
                  ? Map<String, dynamic>.from(dataRaw)
                  : <String, dynamic>{};
              return Right(ProfileFilePaths.normalizeUploadData(data));
            } else {
              return Left(
                MyError(
                  key: AppError.apiError,
                  message:
                      response['message'] ??
                      response['error'] ??
                      'Failed to upload files',
                ),
              );
            }
          } catch (e) {
            log('ProfileApiService: Parse error - $e');
            return Left(
              MyError(
                key: AppError.unknown,
                message: 'Failed to parse response: $e',
              ),
            );
          }
        },
      );
    } catch (e) {
      log('ProfileApiService: Unexpected error - $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
    }
  }

  List<T> _mapSectionRecords<T>(
    dynamic data,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is List) return mapCareersSectionRows(data, fromJson);
    if (data is! Map) return [];
    return mapCareersSectionRows(data[key], fromJson);
  }

  /// Replace-all POSTs must send the full list. Never drop invalid rows
  /// silently — that would delete them on the server.
  Either<MyError, List<Map<String, dynamic>>> _validatedSectionRows<T>(
    List<T> records, {
    required bool Function(T record) isValid,
    required Map<String, dynamic> Function(T record) toJson,
    required String invalidMessage,
  }) {
    if (records.any((record) => !isValid(record))) {
      return Left(
        MyError(key: AppError.apiError, message: invalidMessage),
      );
    }
    return Right(records.map(toJson).toList());
  }

  /// Candidate fields accepted by `POST /update-profile` (API v2).
  static const _allowedCandidateKeys = {
    'cand_id',
    'candidate_name',
    'name',
    'nationality_country_id',
    'nationality_id',
    'date_of_birth',
    'gender',
    'marital_status',
    'visa_status',
    'visa_exp_date',
    'phone',
    'current_location',
    'province_state',
    'address_local',
    'current_country_id',
    'experience_years',
    'uae_experience_years',
    'other_experience_years',
    'current_ctc',
    'expected_ctc',
    'available_from',
    'reason_leaving',
    'conviction_yn',
    'conviction_details',
    'govt_issue_yn',
    'govt_issue_details',
    'reference_permission_yn',
    'notice_period',
    'preferred_position',
  };

  static const _datePayloadKeys = {
    'available_from',
    'date_of_birth',
    'visa_exp_date',
  };

  static const _countryIdKeys = {
    'nationality_country_id',
    'nationality_id',
    'current_country_id',
  };

  void _prepareUpdateProfileBody(Map<String, dynamic> body) {
    if (body.containsKey('name') && !body.containsKey('candidate_name')) {
      body['candidate_name'] = body['name'];
    }
    if (body.containsKey('nationality_id') &&
        !body.containsKey('nationality_country_id')) {
      body['nationality_country_id'] = body['nationality_id'];
    }
    body.remove('name');
    body.remove('nationality_id');

    for (final key in _datePayloadKeys) {
      if (!body.containsKey(key)) continue;
      final formatted = CareersApiDates.formatForApi(body[key]?.toString());
      if (formatted != null) {
        body[key] = formatted;
      }
    }

    body.removeWhere((key, value) {
      if (!_allowedCandidateKeys.contains(key)) return true;
      if (value == null || value == '') return true;
      if (_countryIdKeys.contains(key)) {
        final id = value is int ? value : int.tryParse(value.toString());
        if (id == null || id <= 0) return true;
      }
      return false;
    });
  }
}
