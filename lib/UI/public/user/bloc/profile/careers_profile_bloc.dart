import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/repository/careers_profile_repository.dart';
import 'package:admin_app/UI/public/user/utils/careers_api_dates.dart';
import 'package:admin_app/UI/public/user/utils/careers_avatar_cache.dart';
import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
import 'package:admin_app/UI/public/user/utils/profile_file_encoder.dart';
import 'package:admin_app/UI/public/user/utils/profile_file_paths.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc for the candidate (careers) profile.
///
/// Contains no business logic: every event is delegated to
/// [CareersProfileRepository] and the `Either<MyError, T>` result is folded
/// into Loading / Loaded / Error states.
class CareersProfileBloc
    extends Bloc<CareersProfileEvent, CareersProfileState> {
  final CareersProfileRepository _repository;

  CareersProfileBloc({required CareersProfileRepository repository})
    : _repository = repository,
      super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SaveBasicInfoEvent>(_onSaveBasicInfo);
    on<LoadProfileSectionEvent>(_onLoadSection);
    on<SaveEducationEvent>(_onSaveEducation);
    on<SaveExperienceEvent>(_onSaveExperience);
    on<SaveFamilyEvent>(_onSaveFamily);
    on<SaveReferencesEvent>(_onSaveReferences);
    on<SaveProfessionalProgramsEvent>(_onSaveProfessionalPrograms);
    on<CheckProfileCompletionEvent>(_onCheckProfileCompletion);
    on<LoadCountriesEvent>(_onLoadCountries);
    on<UploadProfileFilesEvent>(_onUploadProfileFiles);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _repository.getProfile();
    if (result.isLeft) {
      emit(ProfileError(message: result.left.message));
      return;
    }

    final merged = ProfileFilePaths.mergeWithCachedFiles(result.right);
    await _cacheEmbeddedAvatarIfNeeded(merged.avatarFile);
    emit(ProfileLoaded(profile: merged));
  }

  Future<void> _onSaveBasicInfo(
    SaveBasicInfoEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.basic));

    final profileData = Map<String, dynamic>.from(event.profileData);
    try {
      profileData.addAll(
        await ProfileFileEncoder.encodeFiles(
          avatarFilePath: event.avatarFilePath,
          cvFilePath: event.cvFilePath,
        ),
      );
    } catch (e) {
      emit(
        ProfileSaveError(
          ProfileSection.basic,
          message: 'Failed to read selected files: $e',
        ),
      );
      return;
    }

    final result = await _repository.updateProfile(profileData);
    if (result.isLeft) {
      emit(
        ProfileSaveError(
          ProfileSection.basic,
          message: result.left.message,
        ),
      );
      return;
    }

    final data = result.right;
    if (event.avatarFilePath != null && event.avatarFilePath!.isNotEmpty) {
      await CareersAvatarCache.saveFromFile(event.avatarFilePath!);
    }

    var normalized = data.isNotEmpty
        ? ProfileFilePaths.normalizeUploadData(
            Map<String, dynamic>.from(data),
          )
        : <String, dynamic>{};

    normalized = _applyOptimisticSavePayload(
      normalized,
      profileData,
    );

    if (normalized.isNotEmpty) {
      await _syncUploadedFilesToCache(normalized);
      _emitUploadedProfileFiles(normalized, emit);
    }

    await _cacheAvailableFromIfNeeded(profileData, normalized);
    emit(const ProfileSaved(ProfileSection.basic));
    add(const LoadProfileEvent());
    add(const CheckProfileCompletionEvent());
  }

  Future<void> _onLoadSection(
    LoadProfileSectionEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(ProfileSectionLoading(event.section));
    switch (event.section) {
      case ProfileSection.basic:
        add(const LoadProfileEvent());
        break;
      case ProfileSection.education:
        final result = await _repository.getEducation();
        result.fold(
          (error) =>
              emit(ProfileSectionError(event.section, message: error.message)),
          (records) => emit(EducationLoaded(records: records)),
        );
        break;
      case ProfileSection.experience:
        final result = await _repository.getExperience();
        result.fold(
          (error) =>
              emit(ProfileSectionError(event.section, message: error.message)),
          (records) => emit(ExperienceLoaded(records: records)),
        );
        break;
      case ProfileSection.family:
        final result = await _repository.getFamily();
        result.fold(
          (error) =>
              emit(ProfileSectionError(event.section, message: error.message)),
          (members) => emit(FamilyLoaded(members: members)),
        );
        break;
      case ProfileSection.references:
        final result = await _repository.getReferences();
        result.fold(
          (error) =>
              emit(ProfileSectionError(event.section, message: error.message)),
          (references) => emit(ReferencesLoaded(references: references)),
        );
        break;
      case ProfileSection.programs:
        final result = await _repository.getProfessionalPrograms();
        result.fold(
          (error) =>
              emit(ProfileSectionError(event.section, message: error.message)),
          (programs) => emit(ProfessionalProgramsLoaded(programs: programs)),
        );
        break;
    }
  }

  Future<void> _onSaveEducation(
    SaveEducationEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.education));
    final result = await _repository.updateEducation(event.records);
    result.fold(
      (error) => emit(
        ProfileSaveError(ProfileSection.education, message: error.message),
      ),
      (_) => emit(const ProfileSaved(ProfileSection.education)),
    );
  }

  Future<void> _onSaveExperience(
    SaveExperienceEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.experience));
    final result = await _repository.updateExperience(event.records);
    result.fold(
      (error) => emit(
        ProfileSaveError(ProfileSection.experience, message: error.message),
      ),
      (_) => emit(const ProfileSaved(ProfileSection.experience)),
    );
  }

  Future<void> _onSaveFamily(
    SaveFamilyEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.family));
    final result = await _repository.updateFamily(event.members);
    result.fold(
      (error) =>
          emit(ProfileSaveError(ProfileSection.family, message: error.message)),
      (_) => emit(const ProfileSaved(ProfileSection.family)),
    );
  }

  Future<void> _onSaveReferences(
    SaveReferencesEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.references));
    final result = await _repository.updateReferences(event.references);
    result.fold(
      (error) => emit(
        ProfileSaveError(ProfileSection.references, message: error.message),
      ),
      (_) => emit(const ProfileSaved(ProfileSection.references)),
    );
  }

  Future<void> _onSaveProfessionalPrograms(
    SaveProfessionalProgramsEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.programs));
    final result = await _repository.updateProfessionalPrograms(event.programs);
    result.fold(
      (error) => emit(
        ProfileSaveError(ProfileSection.programs, message: error.message),
      ),
      (_) => emit(const ProfileSaved(ProfileSection.programs)),
    );
  }

  Future<void> _onCheckProfileCompletion(
    CheckProfileCompletionEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileCompletionLoading());
    final result = await _repository.getProfileCompletion();
    result.fold(
      (error) => emit(ProfileCompletionError(message: error.message)),
      (completion) => emit(ProfileCompletionLoaded(completion: completion)),
    );
  }

  Future<void> _onLoadCountries(
    LoadCountriesEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const CountriesLoading());
    final result = await _repository.getCountries();
    result.fold(
      (error) => emit(CountriesError(message: error.message)),
      (countries) => emit(CountriesLoaded(countries: countries)),
    );
  }

  Future<void> _onUploadProfileFiles(
    UploadProfileFilesEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileFilesUploading());

    Map<String, dynamic> encodedFiles = const {};
    try {
      encodedFiles = await ProfileFileEncoder.encodeFiles(
        avatarFilePath: event.avatarFilePath,
        cvFilePath: event.cvFilePath,
      );
    } catch (e) {
      emit(
        ProfileFilesUploadError(
          message: 'Failed to read selected files: $e',
        ),
      );
      return;
    }

    final result = await _repository.uploadProfileFiles(
      avatarFilePath: event.avatarFilePath,
      cvFilePath: event.cvFilePath,
    );
    if (result.isLeft) {
      emit(ProfileFilesUploadError(message: result.left.message));
      return;
    }

    final data = result.right;
    if (event.avatarFilePath != null && event.avatarFilePath!.isNotEmpty) {
      await CareersAvatarCache.saveFromFile(event.avatarFilePath!);
    }

    var normalized = ProfileFilePaths.normalizeUploadData(
      Map<String, dynamic>.from(data),
    );
    normalized = _applyOptimisticSavePayload(normalized, encodedFiles);
    await _syncUploadedFilesToCache(normalized);
    emit(ProfileFilesUploaded(uploadData: normalized));
    _emitUploadedProfileFiles(normalized, emit);
    add(const LoadProfileEvent());
    add(const CheckProfileCompletionEvent());
  }

  void _emitUploadedProfileFiles(
    Map<String, dynamic> data,
    Emitter<CareersProfileState> emit,
  ) {
    final candidate = ProfileFilePaths.extractCandidateMap(data);
    if (candidate == null) return;

    final uploaded = ProfileModel.fromJson(candidate);
    final current = state;
    if (current is ProfileLoaded) {
      emit(
        ProfileLoaded(
          profile: current.profile.copyWith(
            avatarFile: uploaded.avatarFile ?? current.profile.avatarFile,
            cvFile: uploaded.cvFile ?? current.profile.cvFile,
          ),
        ),
      );
      return;
    }

    emit(ProfileLoaded(profile: uploaded));
  }

  Future<void> _syncUploadedFilesToCache(Map<String, dynamic> data) async {
    final candidate = ProfileFilePaths.extractCandidateMap(data);
    if (candidate == null) return;

    final avatar = ProfileFilePaths.extractAvatarPath(candidate);
    final cv = ProfileFilePaths.extractCvPath(candidate);

    if (avatar != null && CareersMediaUrl.isEmbeddedFileData(avatar)) {
      await CareersAvatarCache.saveFromBase64(avatar);
    } else if (avatar != null) {
      await CareersUserManager.updateProfile(profileImage: avatar);
    }

    final remoteCv = cv != null && !CareersMediaUrl.isEmbeddedFileData(cv)
        ? cv
        : null;
    if (remoteCv != null) {
      await CareersUserManager.updateProfile(resumeUrl: remoteCv);
    }
  }

  Future<void> _cacheEmbeddedAvatarIfNeeded(String? avatar) async {
    if (avatar == null || !CareersMediaUrl.isEmbeddedFileData(avatar)) return;
    await CareersAvatarCache.saveFromBase64(avatar);
  }

  Map<String, dynamic> _applyOptimisticSavePayload(
    Map<String, dynamic> data,
    Map<String, dynamic> sent,
  ) {
    final patched = Map<String, dynamic>.from(data);
    final candidate = Map<String, dynamic>.from(
      ProfileFilePaths.extractCandidateMap(patched) ?? const {},
    );

    final sentAvailableFrom = sent['available_from']?.toString();
    if (_hasText(sentAvailableFrom) &&
        CareersApiDates.isInvalidApiDate(candidate['available_from'])) {
      candidate['available_from'] =
          CareersApiDates.formatForApi(sentAvailableFrom) ?? sentAvailableFrom;
    }

    if (candidate.isNotEmpty) {
      patched['candidate'] = candidate;
    }

    return patched;
  }

  Future<void> _cacheAvailableFromIfNeeded(
    Map<String, dynamic> sent,
    Map<String, dynamic> responseData,
  ) async {
    final sentAvailableFrom = sent['available_from']?.toString();
    if (!_hasText(sentAvailableFrom)) return;

    final candidate = ProfileFilePaths.extractCandidateMap(responseData);
    final returned = candidate?['available_from'];
    if (CareersApiDates.isInvalidApiDate(returned)) {
      await CareersUserManager.updatePreferences({
        'available_from': sentAvailableFrom,
      });
    }
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
