import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/country_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_shimmer.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicInfoTab extends StatefulWidget {
  const BasicInfoTab({super.key});

  @override
  State<BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  final _nationality = TextEditingController();
  final _location = TextEditingController();
  final _provinceState = TextEditingController();
  final _address = TextEditingController();
  final _visaStatus = TextEditingController();
  final _experienceYears = TextEditingController();
  final _uaeExperienceYears = TextEditingController();
  final _otherExperienceYears = TextEditingController();
  final _currentCtc = TextEditingController();
  final _expectedCtc = TextEditingController();
  final _availableFrom = TextEditingController();
  final _reasonLeaving = TextEditingController();
  final _convictionDetails = TextEditingController();
  final _govtIssueDetails = TextEditingController();
  final _noticePeriod = TextEditingController();
  final _preferredPosition = TextEditingController();

  String? _maritalStatus;
  bool _convictionYn = false;
  bool _govtIssueYn = false;
  bool _referencePermissionYn = false;
  int? _nationalityCountryId;
  int? _currentCountryId;

  List<CountryModel> _countries = [];
  ProfileModel? _profile;
  bool _loading = true;
  String? _error;

  String? _pickedAvatarPath;
  String? _pickedCvPath;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CareersProfileBloc>();
    final state = bloc.state;
    if (state is ProfileLoaded) {
      _applyProfile(state.profile);
    } else if (state is! ProfileLoading) {
      bloc.add(const LoadProfileEvent());
    }
    bloc.add(const LoadCountriesEvent());
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _dob,
      _nationality,
      _location,
      _provinceState,
      _address,
      _visaStatus,
      _experienceYears,
      _uaeExperienceYears,
      _otherExperienceYears,
      _currentCtc,
      _expectedCtc,
      _availableFrom,
      _reasonLeaving,
      _convictionDetails,
      _govtIssueDetails,
      _noticePeriod,
      _preferredPosition,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applyProfile(ProfileModel profile) {
    _profile = profile;
    _loading = false;
    _error = null;

    _name.text = profile.name ?? '';
    _email.text = profile.email ?? '';
    _phone.text = profile.phone ?? '';
    _dob.text = profile.dateOfBirth ?? '';
    _nationality.text = profile.nationality ?? '';
    _location.text = profile.currentLocation ?? '';
    _provinceState.text = profile.provinceState ?? '';
    _address.text = profile.addressLocal ?? '';
    _visaStatus.text = profile.visaStatus ?? '';
    _experienceYears.text = profile.experienceYears?.toString() ?? '';
    _uaeExperienceYears.text = profile.uaeExperienceYears?.toString() ?? '';
    _otherExperienceYears.text = profile.otherExperienceYears?.toString() ?? '';
    _currentCtc.text = profile.currentCtc?.toString() ?? '';
    _expectedCtc.text = profile.expectedCtc?.toString() ?? '';
    _availableFrom.text = profile.availableFrom ?? '';
    _reasonLeaving.text = profile.reasonLeaving ?? '';
    _convictionDetails.text = profile.convictionDetails ?? '';
    _govtIssueDetails.text = profile.govtIssueDetails ?? '';
    _noticePeriod.text = profile.noticePeriod ?? '';
    _preferredPosition.text = profile.preferredPosition ?? '';

    _maritalStatus = (profile.maritalStatus?.isNotEmpty ?? false)
        ? profile.maritalStatus
        : null;
    _convictionYn = profile.convictionYn ?? false;
    _govtIssueYn = profile.govtIssueYn ?? false;
    _referencePermissionYn = profile.referencePermissionYn ?? false;
    _nationalityCountryId = profile.nationalityCountryId != 0
        ? profile.nationalityCountryId
        : null;
    _currentCountryId = profile.currentCountryId != 0
        ? profile.currentCountryId
        : null;
  }

  void _onStateChange(BuildContext context, CareersProfileState state) {
    if (state is ProfileLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else if (state is ProfileLoaded) {
      setState(() => _applyProfile(state.profile));
    } else if (state is ProfileError) {
      setState(() {
        _loading = false;
        _error = state.message;
      });
    } else if (state is CountriesLoaded) {
      setState(() {
        _countries = state.countries;
        // Drop selections that don't exist in the loaded list.
        if (!_countries.any((c) => c.id == _nationalityCountryId)) {
          _nationalityCountryId = null;
        }
        if (!_countries.any((c) => c.id == _currentCountryId)) {
          _currentCountryId = null;
        }
      });
    } else if (state is ProfileSaved && state.section == ProfileSection.basic) {
      AppToast.success(context, 'Profile updated successfully');
      context.read<CareersProfileBloc>().add(const LoadProfileEvent());
    } else if (state is ProfileSaveError &&
        state.section == ProfileSection.basic) {
      AppToast.error(context, state.message);
    } else if (state is ProfileFilesUploaded) {
      AppToast.success(context, 'Files uploaded successfully');
      setState(() {
        _pickedAvatarPath = null;
        _pickedCvPath = null;
      });
      context.read<CareersProfileBloc>().add(const LoadProfileEvent());
    } else if (state is ProfileFilesUploadError) {
      AppToast.error(context, state.message);
    }
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _pickedAvatarPath = path);
    }
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _pickedCvPath = path);
    }
  }

  void _uploadFiles() {
    context.read<CareersProfileBloc>().add(
      UploadProfileFilesEvent(
        avatarFilePath: _pickedAvatarPath,
        cvFilePath: _pickedCvPath,
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, 'Please fill in all required fields correctly');
      return;
    }

    final profileData = <String, dynamic>{
      'candidate_name': _name.text,
      'phone': _phone.text,
      'date_of_birth': _dob.text,
      'nationality': _nationality.text,
      'current_location': _location.text,
      'province_state': _provinceState.text,
      'address_local': _address.text,
      'preferred_position': _preferredPosition.text,
      'notice_period': _noticePeriod.text,
      'marital_status': _maritalStatus ?? '',
      'visa_status': _visaStatus.text,
      'nationality_country_id': _nationalityCountryId ?? 0,
      'current_country_id': _currentCountryId ?? 0,
      'experience_years': double.tryParse(_experienceYears.text) ?? 0.0,
      'uae_experience_years': double.tryParse(_uaeExperienceYears.text) ?? 0.0,
      'other_experience_years':
          double.tryParse(_otherExperienceYears.text) ?? 0.0,
      'current_ctc': double.tryParse(_currentCtc.text) ?? 0.0,
      'expected_ctc': double.tryParse(_expectedCtc.text) ?? 0.0,
      'available_from': _availableFrom.text,
      'reason_leaving': _reasonLeaving.text,
      'conviction_yn': _convictionYn ? 1 : 0,
      'conviction_details': _convictionYn ? _convictionDetails.text : '',
      'govt_issue_yn': _govtIssueYn ? 1 : 0,
      'govt_issue_details': _govtIssueYn ? _govtIssueDetails.text : '',
      'reference_permission_yn': _referencePermissionYn ? 1 : 0,
    };

    context.read<CareersProfileBloc>().add(
      SaveBasicInfoEvent(profileData: profileData),
    );
  }

  List<DropdownMenuItem<int>> get _countryItems => _countries
      .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
      .toList();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<CareersProfileBloc, CareersProfileState>(
      listener: _onStateChange,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.md),
        child: ShimmerList(itemCount: 8, showAvatar: false),
      );
    }

    if (_error != null) {
      return Center(
        child: AppErrorState.generic(
          message: _error,
          onRetry: () =>
              context.read<CareersProfileBloc>().add(const LoadProfileEvent()),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionHeader(context, 'Personal Details'),
            ProfileTextField(label: 'Name', controller: _name, enabled: false),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Email',
              controller: _email,
              enabled: false,
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Phone',
              controller: _phone,
              enabled: false,
            ),
            AppSpacing.vGapMd,
            ProfileDateField(
              label: 'Date of Birth',
              controller: _dob,
              isRequired: true,
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Nationality',
              controller: _nationality,
              enabled: false,
            ),
            AppSpacing.vGapMd,
            ProfileDropdownField<int>(
              label: 'Nationality Country',
              value: _nationalityCountryId,
              items: _countryItems,
              hint: _countries.isEmpty
                  ? 'Loading countries...'
                  : 'Select country',
              onChanged: (value) =>
                  setState(() => _nationalityCountryId = value),
            ),
            AppSpacing.vGapMd,
            ProfileDropdownField<String>(
              label: 'Marital Status',
              value: _maritalStatus,
              isRequired: true,
              hint: 'Select status',
              items: const [
                DropdownMenuItem(value: 'Single', child: Text('Single')),
                DropdownMenuItem(value: 'Married', child: Text('Married')),
                DropdownMenuItem(value: 'Divorced', child: Text('Divorced')),
                DropdownMenuItem(value: 'Widowed', child: Text('Widowed')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _maritalStatus = value),
            ),
            AppSpacing.vGapLg,
            _sectionHeader(context, 'Location'),
            ProfileTextField(
              label: 'Current Location',
              controller: _location,
              isRequired: true,
            ),
            AppSpacing.vGapMd,
            ProfileDropdownField<int>(
              label: 'Current Country',
              value: _currentCountryId,
              items: _countryItems,
              hint: _countries.isEmpty
                  ? 'Loading countries...'
                  : 'Select country',
              onChanged: (value) => setState(() => _currentCountryId = value),
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Province/State',
              controller: _provinceState,
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Address',
              controller: _address,
              isRequired: true,
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Visa Status',
              controller: _visaStatus,
              isRequired: true,
            ),
            AppSpacing.vGapLg,
            _sectionHeader(context, 'Career'),
            ProfileTextField(
              label: 'Preferred Position',
              controller: _preferredPosition,
              isRequired: true,
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Notice Period',
              controller: _noticePeriod,
              isRequired: true,
            ),
            AppSpacing.vGapMd,
            ProfileNumericField(
              label: 'Experience Years',
              controller: _experienceYears,
            ),
            AppSpacing.vGapMd,
            ProfileNumericField(
              label: 'UAE Experience Years',
              controller: _uaeExperienceYears,
            ),
            AppSpacing.vGapMd,
            ProfileNumericField(
              label: 'Other Experience Years',
              controller: _otherExperienceYears,
            ),
            AppSpacing.vGapMd,
            ProfileNumericField(
              label: 'Current CTC',
              controller: _currentCtc,
              isCurrency: true,
            ),
            AppSpacing.vGapMd,
            ProfileNumericField(
              label: 'Expected CTC',
              controller: _expectedCtc,
              isCurrency: true,
            ),
            AppSpacing.vGapMd,
            ProfileDateField(
              label: 'Available From',
              controller: _availableFrom,
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Reason for Leaving',
              controller: _reasonLeaving,
            ),
            AppSpacing.vGapLg,
            _sectionHeader(context, 'Declarations'),
            ProfileSwitchField(
              label: 'Have you ever been convicted?',
              value: _convictionYn,
              onChanged: (value) => setState(() {
                _convictionYn = value;
                if (!value) _convictionDetails.clear();
              }),
            ),
            if (_convictionYn) ...[
              AppSpacing.vGapMd,
              ProfileTextField(
                label: 'Conviction Details',
                controller: _convictionDetails,
                isRequired: true,
              ),
            ],
            AppSpacing.vGapMd,
            ProfileSwitchField(
              label: 'Any government issue?',
              value: _govtIssueYn,
              onChanged: (value) => setState(() {
                _govtIssueYn = value;
                if (!value) _govtIssueDetails.clear();
              }),
            ),
            if (_govtIssueYn) ...[
              AppSpacing.vGapMd,
              ProfileTextField(
                label: 'Govt Issue Details',
                controller: _govtIssueDetails,
                isRequired: true,
              ),
            ],
            AppSpacing.vGapMd,
            ProfileSwitchField(
              label: 'Permission to contact references?',
              value: _referencePermissionYn,
              onChanged: (value) =>
                  setState(() => _referencePermissionYn = value),
            ),
            AppSpacing.vGapLg,
            _sectionHeader(context, 'Documents'),
            _FilePickerRow(
              label: 'Profile Photo',
              currentFileName: _profile?.avatarFile,
              pickedFileName: _pickedAvatarPath?.split('/').last,
              onPick: _pickAvatar,
            ),
            AppSpacing.vGapMd,
            _FilePickerRow(
              label: 'CV / Resume',
              currentFileName: _profile?.cvFile,
              pickedFileName: _pickedCvPath?.split('/').last,
              onPick: _pickCv,
            ),
            if (_pickedAvatarPath != null || _pickedCvPath != null) ...[
              AppSpacing.vGapMd,
              BlocBuilder<CareersProfileBloc, CareersProfileState>(
                buildWhen: (previous, current) =>
                    current is ProfileFilesUploading ||
                    current is ProfileFilesUploaded ||
                    current is ProfileFilesUploadError,
                builder: (context, state) {
                  final uploading = state is ProfileFilesUploading;
                  return AppButton.secondary(
                    label: 'Upload Selected Files',
                    leadingIcon: CupertinoIcons.cloud_upload,
                    isLoading: uploading,
                    onPressed: uploading ? null : _uploadFiles,
                  );
                },
              ),
            ],
            AppSpacing.vGapLg,
            BlocBuilder<CareersProfileBloc, CareersProfileState>(
              buildWhen: (previous, current) =>
                  (current is ProfileSaving &&
                      current.section == ProfileSection.basic) ||
                  (current is ProfileSaved &&
                      current.section == ProfileSection.basic) ||
                  (current is ProfileSaveError &&
                      current.section == ProfileSection.basic),
              builder: (context, state) {
                final saving =
                    state is ProfileSaving &&
                    state.section == ProfileSection.basic;
                return AppButton.primary(
                  label: 'Save Basic Info',
                  isLoading: saving,
                  onPressed: saving ? null : _save,
                );
              },
            ),
            AppSpacing.vGapXl,
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  final String label;
  final String? currentFileName;
  final String? pickedFileName;
  final VoidCallback onPick;

  const _FilePickerRow({
    required this.label,
    this.currentFileName,
    this.pickedFileName,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileText =
        pickedFileName ??
        ((currentFileName?.isNotEmpty ?? false)
            ? currentFileName!
            : 'No file selected');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              AppSpacing.vGapXs,
              Text(
                fileText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: pickedFileName != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.hGapMd,
        AppButton.ghost(
          label: 'Choose File',
          size: AppButtonSize.small,
          leadingIcon: CupertinoIcons.folder,
          onPressed: onPick,
        ),
      ],
    );
  }
}
