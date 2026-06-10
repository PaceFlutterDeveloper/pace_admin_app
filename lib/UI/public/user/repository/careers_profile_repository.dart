import 'package:admin_app/UI/public/user/models/country_model.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/user/services/profile_api_service.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:either_dart/either.dart';

/// Repository for the candidate (careers) profile.
///
/// Mirrors the repository pattern used by the rest of the app
/// (e.g. `HomeRepository`): resolves the session/candidate context
/// internally and returns `Either<MyError, T>` — never throws.
class CareersProfileRepository {
  final ProfileApiService _profileApiService;
  final CareersUserService _careersUserService;

  CareersProfileRepository({
    required ProfileApiService profileApiService,
    required CareersUserService careersUserService,
  }) : _profileApiService = profileApiService,
       _careersUserService = careersUserService;

  static const MyError _notLoggedInError = MyError(
    key: AppError.unauthorized,
    message: 'You need to be logged in to manage your profile.',
  );

  String? get _token =>
      _careersUserService.getCurrentCareersUser()?.sessionToken;

  int? get _candidateId {
    final id = _careersUserService.getCurrentCareersUser()?.id;
    return id != null ? int.tryParse(id) : null;
  }

  Future<Either<MyError, T>> _withCandidate<T>(
    Future<Either<MyError, T>> Function(int candidateId, String? token) call,
  ) {
    final candidateId = _candidateId;
    if (candidateId == null) {
      return Future.value(const Left(_notLoggedInError));
    }
    return call(candidateId, _token);
  }

  Future<Either<MyError, ProfileModel>> getProfile() {
    return _withCandidate(
      (candidateId, token) =>
          _profileApiService.getProfile(candidateId: candidateId, token: token),
    );
  }

  Future<Either<MyError, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> profileData,
  ) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.updateProfile(
        candidateId: candidateId,
        profileData: profileData,
        token: token,
      ),
    );
  }

  Future<Either<MyError, List<EducationRecord>>> getEducation() {
    return _withCandidate(
      (candidateId, token) => _profileApiService.getEducation(
        candidateId: candidateId,
        token: token,
      ),
    );
  }

  Future<Either<MyError, Map<String, dynamic>>> updateEducation(
    List<EducationRecord> records,
  ) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.updateEducation(
        candidateId: candidateId,
        educationRecords: records,
        token: token,
      ),
    );
  }

  Future<Either<MyError, List<ExperienceRecord>>> getExperience() {
    return _withCandidate(
      (candidateId, token) => _profileApiService.getExperience(
        candidateId: candidateId,
        token: token,
      ),
    );
  }

  Future<Either<MyError, Map<String, dynamic>>> updateExperience(
    List<ExperienceRecord> records,
  ) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.updateExperience(
        candidateId: candidateId,
        experienceRecords: records,
        token: token,
      ),
    );
  }

  Future<Either<MyError, List<FamilyMember>>> getFamily() {
    return _withCandidate(
      (candidateId, token) =>
          _profileApiService.getFamily(candidateId: candidateId, token: token),
    );
  }

  Future<Either<MyError, Map<String, dynamic>>> updateFamily(
    List<FamilyMember> members,
  ) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.updateFamily(
        candidateId: candidateId,
        familyMembers: members,
        token: token,
      ),
    );
  }

  Future<Either<MyError, List<Reference>>> getReferences() {
    return _withCandidate(
      (candidateId, token) => _profileApiService.getReferences(
        candidateId: candidateId,
        token: token,
      ),
    );
  }

  Future<Either<MyError, Map<String, dynamic>>> updateReferences(
    List<Reference> references,
  ) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.updateReferences(
        candidateId: candidateId,
        references: references,
        token: token,
      ),
    );
  }

  Future<Either<MyError, List<ProfessionalProgram>>> getProfessionalPrograms() {
    return _withCandidate(
      (candidateId, token) => _profileApiService.getProfessionalPrograms(
        candidateId: candidateId,
        token: token,
      ),
    );
  }

  Future<Either<MyError, Map<String, dynamic>>> updateProfessionalPrograms(
    List<ProfessionalProgram> programs,
  ) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.updateProfessionalPrograms(
        candidateId: candidateId,
        programs: programs,
        token: token,
      ),
    );
  }

  Future<Either<MyError, ProfileCompletionModel>> getProfileCompletion() {
    return _withCandidate(
      (candidateId, token) => _profileApiService.getProfileCompletion(
        candidateId: candidateId,
        token: token,
      ),
    );
  }

  Future<Either<MyError, List<CountryModel>>> getCountries() {
    return _profileApiService.getCountries();
  }

  Future<Either<MyError, Map<String, dynamic>>> uploadProfileFiles({
    String? avatarFilePath,
    String? cvFilePath,
  }) {
    return _withCandidate(
      (candidateId, token) => _profileApiService.uploadProfileFiles(
        candidateId: candidateId,
        avatarFilePath: avatarFilePath,
        cvFilePath: cvFilePath,
        token: token,
      ),
    );
  }
}
