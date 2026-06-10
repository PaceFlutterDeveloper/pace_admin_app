import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/repository/careers_profile_repository.dart';
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
    result.fold(
      (error) => emit(ProfileError(message: error.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onSaveBasicInfo(
    SaveBasicInfoEvent event,
    Emitter<CareersProfileState> emit,
  ) async {
    emit(const ProfileSaving(ProfileSection.basic));
    final result = await _repository.updateProfile(event.profileData);
    result.fold(
      (error) =>
          emit(ProfileSaveError(ProfileSection.basic, message: error.message)),
      (_) => emit(const ProfileSaved(ProfileSection.basic)),
    );
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
    final result = await _repository.uploadProfileFiles(
      avatarFilePath: event.avatarFilePath,
      cvFilePath: event.cvFilePath,
    );
    result.fold(
      (error) => emit(ProfileFilesUploadError(message: error.message)),
      (_) => emit(const ProfileFilesUploaded()),
    );
  }
}
