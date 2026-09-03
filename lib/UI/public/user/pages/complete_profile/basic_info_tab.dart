import 'dart:io';

import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/country_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/components/careers_profile_image.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/widgets/profile_form_fields.dart';
import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
import 'package:admin_app/UI/public/user/utils/profile_file_paths.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/utils/image_processing_helper.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_shimmer.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
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
  final _location = TextEditingController();
  final _provinceState = TextEditingController();
  final _address = TextEditingController();
  final _visaStatus = TextEditingController();
  final _visaExpDate = TextEditingController();
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
  String? _gender;
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
  bool _isProcessingImage = false;

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
      _location,
      _provinceState,
      _address,
      _visaStatus,
      _visaExpDate,
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
    _location.text = profile.currentLocation ?? '';
    _provinceState.text = profile.provinceState ?? '';
    _address.text = profile.addressLocal ?? '';
    _visaStatus.text = profile.visaStatus ?? '';
    _visaExpDate.text = profile.visaExpDate ?? '';
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
    _gender = (profile.gender?.isNotEmpty ?? false) ? profile.gender : null;
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
      if (_profile == null) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }
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
    } else if (state is ProfileSaveError &&
        state.section == ProfileSection.basic) {
      AppToast.error(context, state.message);
    } else if (state is ProfileFilesUploaded) {
      AppToast.success(context, 'Profile photo updated successfully');
      final candidate = ProfileFilePaths.extractCandidateMap(
        state.uploadData ?? const {},
      );
      setState(() {
        _pickedAvatarPath = null;
        if (candidate != null) {
          final uploaded = ProfileModel.fromJson(candidate);
          if (CareersMediaUrl.isDisplayableRemote(uploaded.avatarFile)) {
            _profile = (_profile ?? uploaded).copyWith(
              avatarFile: uploaded.avatarFile,
            );
          }
        }
      });
    } else if (state is ProfileFilesUploadError) {
      AppToast.error(context, state.message);
    }
  }

  Future<void> _pickAvatar() async {
    if (_isProcessingImage) return;

    setState(() => _isProcessingImage = true);
    try {
      final path = await ImageProcessingHelper.pickAndProcessImage(context);
      if (!mounted) return;
      if (path != null) {
        if (mounted) {
          setState(() {
            _pickedAvatarPath = path;
            _isProcessingImage = false;
          });
        }
      } else {
        setState(() => _isProcessingImage = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingImage = false);
      AppToast.error(context, 'Failed to process image: $e');
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, 'Please fill in all required fields correctly');
      return;
    }

    final profileData = <String, dynamic>{
      'candidate_name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'date_of_birth': _dob.text.trim(),
      if (_gender != null && _gender!.isNotEmpty) 'gender': _gender,
      'current_location': _location.text.trim(),
      'province_state': _provinceState.text.trim(),
      'address_local': _address.text.trim(),
      'preferred_position': _preferredPosition.text.trim(),
      'notice_period': _noticePeriod.text.trim(),
      if (_maritalStatus != null && _maritalStatus!.isNotEmpty)
        'marital_status': _maritalStatus,
      'visa_status': _visaStatus.text.trim(),
      'visa_exp_date': _visaExpDate.text.trim(),
      if (_nationalityCountryId != null && _nationalityCountryId! > 0)
        'nationality_country_id': _nationalityCountryId,
      if (_currentCountryId != null && _currentCountryId! > 0)
        'current_country_id': _currentCountryId,
      if (_experienceYears.text.trim().isNotEmpty)
        'experience_years': double.tryParse(_experienceYears.text),
      if (_uaeExperienceYears.text.trim().isNotEmpty)
        'uae_experience_years': double.tryParse(_uaeExperienceYears.text),
      if (_otherExperienceYears.text.trim().isNotEmpty)
        'other_experience_years': double.tryParse(_otherExperienceYears.text),
      if (_currentCtc.text.trim().isNotEmpty)
        'current_ctc': double.tryParse(_currentCtc.text),
      if (_expectedCtc.text.trim().isNotEmpty)
        'expected_ctc': double.tryParse(_expectedCtc.text),
      'available_from': _availableFrom.text.trim(),
      'reason_leaving': _reasonLeaving.text.trim(),
      'conviction_yn': _convictionYn ? 1 : 0,
      if (_convictionYn) 'conviction_details': _convictionDetails.text.trim(),
      'govt_issue_yn': _govtIssueYn ? 1 : 0,
      if (_govtIssueYn) 'govt_issue_details': _govtIssueDetails.text.trim(),
      'reference_permission_yn': _referencePermissionYn ? 1 : 0,
    };

    context.read<CareersProfileBloc>().add(
      SaveBasicInfoEvent(profileData: profileData),
    );
  }

  void _uploadProfilePhoto() {
    final path = _pickedAvatarPath;
    if (path == null || path.isEmpty) {
      AppToast.error(context, 'Choose a photo first');
      return;
    }
    context.read<CareersProfileBloc>().add(
      UploadProfileFilesEvent(avatarFilePath: path),
    );
  }

  void _clearPickedPhoto() {
    setState(() => _pickedAvatarPath = null);
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
            _sectionHeader(context, 'Profile Photo'),
            _AvatarPreview(
              pickedLocalPath: _pickedAvatarPath,
              remotePath: _profile?.avatarFile,
            ),
            AppSpacing.vGapMd,
            _FilePickerRow(
              label: 'Profile Photo',
              currentFileName: CareersMediaUrl.displayFileLabel(
                _profile?.avatarFile,
              ),
              pickedFileName: _pickedAvatarPath?.split('/').last,
              isProcessing: _isProcessingImage,
              helperText:
                  'JPG / JPEG / PNG / WebP · cropped to 3.5 : 4.5 · max 250 KB',
              onPick: _pickAvatar,
              onClear: _pickedAvatarPath != null ? _clearPickedPhoto : null,
            ),
            if (_pickedAvatarPath != null) ...[
              AppSpacing.vGapMd,
              BlocBuilder<CareersProfileBloc, CareersProfileState>(
                buildWhen: (previous, current) =>
                    current is ProfileFilesUploading ||
                    current is ProfileFilesUploaded ||
                    current is ProfileFilesUploadError,
                builder: (context, state) {
                  final uploading = state is ProfileFilesUploading;
                  return AppButton.secondary(
                    label: 'Update profile image',
                    leadingIcon: CupertinoIcons.cloud_upload,
                    isLoading: uploading,
                    onPressed: uploading ? null : _uploadProfilePhoto,
                  );
                },
              ),
            ],
            AppSpacing.vGapLg,
            _sectionHeader(context, 'Personal Details'),
            ProfileTextField(
              label: 'Name',
              controller: _name,
              isRequired: true,
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Email',
              controller: _email,
              readOnly: true,
              helperText: 'Email is linked to your account',
            ),
            AppSpacing.vGapMd,
            ProfileTextField(
              label: 'Phone',
              controller: _phone,
              isRequired: true,
              keyboardType: TextInputType.phone,
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
            ProfileDropdownField<String>(
              label: 'Gender',
              value: _gender,
              hint: 'Select gender',
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _gender = value),
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
            // ProfileTextField(
            //   label: 'Current Location',
            //   controller: _location,
            //   isRequired: true,
            // ),
            // AppSpacing.vGapMd,
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
            AppSpacing.vGapMd,
            ProfileDateField(
              label: 'Visa Expiry Date',
              controller: _visaExpDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
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
              isRequired: true,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
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

class _AvatarPreview extends StatelessWidget {
  final String? pickedLocalPath;
  final String? remotePath;

  const _AvatarPreview({this.pickedLocalPath, this.remotePath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = AppSizes.avatarLg;
    final hasRemote = CareersMediaUrl.isDisplayableRemote(remotePath);

    return Center(
      child: Column(
        children: [
          CareersProfileImage(
            localFile: pickedLocalPath != null ? File(pickedLocalPath!) : null,
            remoteSource: pickedLocalPath == null ? remotePath : null,
            size: size,
          ),
          AppSpacing.vGapXs,
          Text(
            pickedLocalPath != null
                ? 'Preview — tap Update profile image to upload'
                : hasRemote
                ? 'Current profile photo'
                : 'No profile photo yet',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePickerRow extends StatelessWidget {
  final String label;
  final String? currentFileName;
  final String? pickedFileName;
  final String? helperText;
  final bool isProcessing;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _FilePickerRow({
    required this.label,
    this.currentFileName,
    this.pickedFileName,
    this.helperText,
    this.isProcessing = false,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : AppColors.iosSystemGray6;
    final idleBorder = isDark
        ? AppColors.iosSystemGray4Dark
        : AppColors.iosSystemGray3;
    final fileText = pickedFileName ?? currentFileName ?? 'No file selected';

    return Column(
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
        AppSpacing.vGapSm,
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: idleBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.doc,
                size: AppSizes.iconSm,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  fileText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: pickedFileName != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              AppSpacing.hGapSm,
              if (onClear != null) ...[
                AppButton.ghost(
                  label: 'Remove',
                  size: AppButtonSize.small,
                  onPressed: isProcessing ? null : onClear,
                ),
                AppSpacing.hGapXs,
              ],
              AppButton.ghost(
                label: isProcessing
                    ? 'Processing...'
                    : pickedFileName != null
                    ? 'Change photo'
                    : 'Choose photo',
                size: AppButtonSize.small,
                isLoading: isProcessing,
                leadingIcon: CupertinoIcons.photo,
                onPressed: isProcessing ? null : onPick,
              ),
            ],
          ),
        ),
        if (helperText != null) ...[
          AppSpacing.vGapXs,
          Text(
            helperText!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );
  }
}
