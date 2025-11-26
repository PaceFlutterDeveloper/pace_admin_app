import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({Key? key}) : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProfileModel? _profileData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Fetch profile data on init after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = CareersUserManager.getCurrentUser();
      if (user != null && mounted) {
        print('🔍 Fetching profile for user ID: ${user.id}');
        try {
          final candidateId = int.parse(user.id);
          print('✅ Candidate ID parsed: $candidateId');
          context.read<UserBloc>().add(GetFullProfileEvent(
                candidateId: candidateId,
              ));
        } catch (e) {
          print('❌ Error parsing candidate ID: $e');
        }
      } else {
        print('❌ No user logged in or widget not mounted');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ConstColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Education'),
            Tab(text: 'Experience'),
            Tab(text: 'Family'),
            Tab(text: 'References'),
            Tab(text: 'Certificates'),
          ],
        ),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          String? errorMessage;
          if (state is ProfileDataUpdateSuccess ||
              state is EducationUpdateSuccess ||
              state is ExperienceUpdateSuccess ||
              state is FamilyUpdateSuccess ||
              state is ReferencesUpdateSuccess ||
              state is ProfessionalProgramsUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileDataUpdateError) {
            errorMessage = state.message;
          } else if (state is EducationUpdateError) {
            errorMessage = state.message;
          } else if (state is ExperienceUpdateError) {
            errorMessage = state.message;
          } else if (state is FamilyUpdateError) {
            errorMessage = state.message;
          } else if (state is ReferencesUpdateError) {
            errorMessage = state.message;
          } else if (state is ProfessionalProgramsUpdateError) {
            errorMessage = state.message;
          }

          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            // Update profile data when state changes
            if (state is FullProfileSuccess) {
              _profileData = state.profile;
            }

            // Show loading while fetching profile
            if (state is FullProfileLoading)
              return const Center(
                child: CircularProgressIndicator(),
              );

            return TabBarView(
              controller: _tabController,
              children: [
                BasicProfileTab(
                  width: w,
                  height: h,
                  profileData: _profileData,
                ),
                EducationTab(width: w, height: h),
                ExperienceTab(width: w, height: h),
                FamilyTab(width: w, height: h),
                ReferencesTab(width: w, height: h),
                ProfessionalProgramsTab(width: w, height: h),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Basic Profile Tab
class BasicProfileTab extends StatefulWidget {
  final double width;
  final double height;
  final ProfileModel? profileData;

  const BasicProfileTab({
    Key? key,
    required this.width,
    required this.height,
    this.profileData,
  }) : super(key: key);

  @override
  State<BasicProfileTab> createState() => _BasicProfileTabState();
}

class _BasicProfileTabState extends State<BasicProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController nationalityController;
  late TextEditingController locationController;
  late TextEditingController provinceStateController;
  late TextEditingController addressController;
  late TextEditingController maritalStatusController;
  late TextEditingController visaStatusController;
  late TextEditingController nationalityCountryIdController;
  late TextEditingController currentCountryIdController;
  late TextEditingController experienceYearsController;
  late TextEditingController uaeExperienceYearsController;
  late TextEditingController otherExperienceYearsController;
  late TextEditingController currentCtcController;
  late TextEditingController expectedCtcController;
  late TextEditingController availableFromController;
  late TextEditingController reasonLeavingController;
  late TextEditingController convictionYnController;
  late TextEditingController convictionDetailsController;
  late TextEditingController govtIssueYnController;
  late TextEditingController govtIssueDetailsController;
  late TextEditingController referencePermissionYnController;
  late TextEditingController noticePeriodController;
  late TextEditingController preferredPositionController;
  late TextEditingController avatarFileController;
  late TextEditingController cvFileController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController =
        TextEditingController(text: widget.profileData?.name ?? '');
    emailController =
        TextEditingController(text: widget.profileData?.email ?? '');
    phoneController =
        TextEditingController(text: widget.profileData?.phone ?? '');
    dobController =
        TextEditingController(text: widget.profileData?.dateOfBirth ?? '');
    nationalityController =
        TextEditingController(text: widget.profileData?.nationality ?? '');
    locationController =
        TextEditingController(text: widget.profileData?.currentLocation ?? '');
    provinceStateController =
        TextEditingController(text: widget.profileData?.provinceState ?? '');
    addressController =
        TextEditingController(text: widget.profileData?.addressLocal ?? '');
    maritalStatusController =
        TextEditingController(text: widget.profileData?.maritalStatus ?? '');
    visaStatusController =
        TextEditingController(text: widget.profileData?.visaStatus ?? '');
    nationalityCountryIdController = TextEditingController(
        text: widget.profileData?.nationalityCountryId?.toString() ?? '');
    currentCountryIdController = TextEditingController(
        text: widget.profileData?.currentCountryId?.toString() ?? '');
    experienceYearsController = TextEditingController(
        text: widget.profileData?.experienceYears?.toString() ?? '');
    uaeExperienceYearsController = TextEditingController(
        text: widget.profileData?.uaeExperienceYears?.toString() ?? '');
    otherExperienceYearsController = TextEditingController(
        text: widget.profileData?.otherExperienceYears?.toString() ?? '');
    currentCtcController = TextEditingController(
        text: widget.profileData?.currentCtc?.toString() ?? '');
    expectedCtcController = TextEditingController(
        text: widget.profileData?.expectedCtc?.toString() ?? '');
    availableFromController =
        TextEditingController(text: widget.profileData?.availableFrom ?? '');
    reasonLeavingController =
        TextEditingController(text: widget.profileData?.reasonLeaving ?? '');
    convictionYnController = TextEditingController(
        text: widget.profileData?.convictionYn == true ? '1' : '0');
    convictionDetailsController = TextEditingController(
        text: widget.profileData?.convictionDetails ?? '');
    govtIssueYnController = TextEditingController(
        text: widget.profileData?.govtIssueYn == true ? '1' : '0');
    govtIssueDetailsController =
        TextEditingController(text: widget.profileData?.govtIssueDetails ?? '');
    referencePermissionYnController = TextEditingController(
        text: widget.profileData?.referencePermissionYn == true ? '1' : '0');
    noticePeriodController =
        TextEditingController(text: widget.profileData?.noticePeriod ?? '');
    preferredPositionController = TextEditingController(
        text: widget.profileData?.preferredPosition ?? '');
    avatarFileController =
        TextEditingController(text: widget.profileData?.avatarFile ?? '');
    cvFileController =
        TextEditingController(text: widget.profileData?.cvFile ?? '');
  }

  @override
  void didUpdateWidget(BasicProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers when profile data changes
    if (widget.profileData != oldWidget.profileData &&
        widget.profileData != null) {
      setState(() {
        nameController.text = widget.profileData?.name ?? '';
        emailController.text = widget.profileData?.email ?? '';
        phoneController.text = widget.profileData?.phone ?? '';
        dobController.text = widget.profileData?.dateOfBirth ?? '';
        nationalityController.text = widget.profileData?.nationality ?? '';
        locationController.text = widget.profileData?.currentLocation ?? '';
        provinceStateController.text = widget.profileData?.provinceState ?? '';
        addressController.text = widget.profileData?.addressLocal ?? '';
        maritalStatusController.text = widget.profileData?.maritalStatus ?? '';
        visaStatusController.text = widget.profileData?.visaStatus ?? '';
        nationalityCountryIdController.text =
            widget.profileData?.nationalityCountryId?.toString() ?? '';
        currentCountryIdController.text =
            widget.profileData?.currentCountryId?.toString() ?? '';
        experienceYearsController.text =
            widget.profileData?.experienceYears?.toString() ?? '';
        uaeExperienceYearsController.text =
            widget.profileData?.uaeExperienceYears?.toString() ?? '';
        otherExperienceYearsController.text =
            widget.profileData?.otherExperienceYears?.toString() ?? '';
        currentCtcController.text =
            widget.profileData?.currentCtc?.toString() ?? '';
        expectedCtcController.text =
            widget.profileData?.expectedCtc?.toString() ?? '';
        availableFromController.text = widget.profileData?.availableFrom ?? '';
        reasonLeavingController.text = widget.profileData?.reasonLeaving ?? '';
        convictionYnController.text =
            widget.profileData?.convictionYn == true ? '1' : '0';
        convictionDetailsController.text =
            widget.profileData?.convictionDetails ?? '';
        govtIssueYnController.text =
            widget.profileData?.govtIssueYn == true ? '1' : '0';
        govtIssueDetailsController.text =
            widget.profileData?.govtIssueDetails ?? '';
        referencePermissionYnController.text =
            widget.profileData?.referencePermissionYn == true ? '1' : '0';
        noticePeriodController.text = widget.profileData?.noticePeriod ?? '';
        preferredPositionController.text =
            widget.profileData?.preferredPosition ?? '';
        avatarFileController.text = widget.profileData?.avatarFile ?? '';
        cvFileController.text = widget.profileData?.cvFile ?? '';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    nationalityController.dispose();
    locationController.dispose();
    provinceStateController.dispose();
    addressController.dispose();
    maritalStatusController.dispose();
    visaStatusController.dispose();
    nationalityCountryIdController.dispose();
    currentCountryIdController.dispose();
    experienceYearsController.dispose();
    uaeExperienceYearsController.dispose();
    otherExperienceYearsController.dispose();
    currentCtcController.dispose();
    expectedCtcController.dispose();
    availableFromController.dispose();
    reasonLeavingController.dispose();
    convictionYnController.dispose();
    convictionDetailsController.dispose();
    govtIssueYnController.dispose();
    govtIssueDetailsController.dispose();
    referencePermissionYnController.dispose();
    noticePeriodController.dispose();
    preferredPositionController.dispose();
    avatarFileController.dispose();
    cvFileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = CareersUserManager.getCurrentUser();

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.width * 0.04),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadOnlyField('Name', nameController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildReadOnlyField('Email', emailController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildReadOnlyField('Phone', phoneController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildDatePickerField(
                context, 'Date of Birth', dobController, widget.width,
                isRequired: true),
            SizedBox(height: widget.height * 0.02),
            _buildReadOnlyField(
                'Nationality', nationalityController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildTextField(
                'Current Location', locationController, widget.width,
                isRequired: true),
            SizedBox(height: widget.height * 0.02),
            _buildTextField(
                'Province/State', provinceStateController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildTextField('Address', addressController, widget.width,
                isRequired: true),

            // build dropdown for marital status singe/married/divorced/widowed/separated/other

            SizedBox(height: widget.height * 0.02),
            _buildTextField(
                'Preferred Position', preferredPositionController, widget.width,
                isRequired: true),
            SizedBox(height: widget.height * 0.02),
            _buildTextField(
                'Notice Period', noticePeriodController, widget.width,
                isRequired: true),
            SizedBox(height: widget.height * 0.02),
            DropdownButtonFormField<String>(
              value: maritalStatusController.text.isNotEmpty
                  ? maritalStatusController.text
                  : null,
              decoration: InputDecoration(
                labelText: 'Marital Status *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.width * 0.02),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Single', child: Text('Single')),
                DropdownMenuItem(value: 'Married', child: Text('Married')),
                DropdownMenuItem(value: 'Divorced', child: Text('Divorced')),
                DropdownMenuItem(value: 'Widowed', child: Text('Widowed')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select marital status';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  maritalStatusController.text = value ?? '';
                });
                // Trigger validation after selection
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _formKey.currentState?.validate();
                });
              },
            ),

            SizedBox(height: widget.height * 0.02),
            _buildTextField('Visa Status', visaStatusController, widget.width,
                isRequired: true),
            SizedBox(height: widget.height * 0.02),
            _buildNumericField(
                'Experience Years', experienceYearsController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildNumericField('UAE Experience Years',
                uaeExperienceYearsController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildNumericField('Other Experience Years',
                otherExperienceYearsController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildNumericField(
                'Current CTC', currentCtcController, widget.width,
                isCurrency: true),
            SizedBox(height: widget.height * 0.02),
            _buildNumericField(
                'Expected CTC', expectedCtcController, widget.width,
                isCurrency: true),
            SizedBox(height: widget.height * 0.02),
            _buildDatePickerField(context, 'Available From',
                availableFromController, widget.width),
            SizedBox(height: widget.height * 0.02),
            _buildTextField(
                'Reason Leaving', reasonLeavingController, widget.width),
            SizedBox(height: widget.height * 0.02),
            // build switch for conviction yn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conviction YN',
                  style: TextStyle(fontSize: widget.width * 0.04),
                ),
                Switch(
                    value: convictionYnController.text == '1',
                    onChanged: (value) {
                      setState(() {
                        convictionYnController.text = value ? '1' : '0';
                        // Clear validation error when toggled off
                        if (!value) {
                          convictionDetailsController.clear();
                        }
                      });
                      // Trigger form validation after state update
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _formKey.currentState?.validate();
                      });
                    }),
              ],
            ),

            if (convictionYnController.text == '1') ...[
              SizedBox(height: widget.height * 0.02),
              _buildTextField('Conviction Details', convictionDetailsController,
                  widget.width,
                  isRequired: true),
              SizedBox(height: widget.height * 0.02),
            ],
            // build switch for govt issue yn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Govt Issue YN',
                  style: TextStyle(fontSize: widget.width * 0.04),
                ),
                Switch(
                    value: govtIssueYnController.text == '1',
                    onChanged: (value) {
                      setState(() {
                        govtIssueYnController.text = value ? '1' : '0';
                        // Clear validation error when toggled off
                        if (!value) {
                          govtIssueDetailsController.clear();
                        }
                      });
                      // Trigger form validation after state update
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _formKey.currentState?.validate();
                      });
                    }),
              ],
            ),
            if (govtIssueYnController.text == '1') ...[
              SizedBox(height: widget.height * 0.02),
              _buildTextField('Govt Issue Details', govtIssueDetailsController,
                  widget.width,
                  isRequired: true),
              SizedBox(height: widget.height * 0.02),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reference Permission YN',
                  style: TextStyle(fontSize: widget.width * 0.04),
                ),
                Switch(
                    value: referencePermissionYnController.text == '1',
                    onChanged: (value) {
                      setState(() {
                        referencePermissionYnController.text =
                            value ? '1' : '0';
                      });
                    }),
              ],
            ),
            if (referencePermissionYnController.text == '1') ...[
              SizedBox(height: widget.height * 0.02),
              _buildTextField('Reference Permission Details',
                  referencePermissionYnController, widget.width),
              SizedBox(height: widget.height * 0.02),
            ],
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is ProfileDataUpdateLoading
                        ? null
                        : () {
                            // Validate form before submission
                            if (!_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please fill in all required fields correctly'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Get existing profile data
                            final existingData = widget.profileData;

                            // Build complete profile data with all fields
                            final profileData = <String, dynamic>{
                              // Basic info fields - use controller values
                              'candidate_name': nameController.text.isNotEmpty
                                  ? nameController.text
                                  : existingData?.name ?? '',
                              'phone': phoneController.text.isNotEmpty
                                  ? phoneController.text
                                  : existingData?.phone ?? '',
                              'current_location':
                                  locationController.text.isNotEmpty
                                      ? locationController.text
                                      : existingData?.currentLocation ?? '',
                              'date_of_birth': dobController.text.isNotEmpty
                                  ? dobController.text
                                  : existingData?.dateOfBirth ?? '',
                              'nationality':
                                  nationalityController.text.isNotEmpty
                                      ? nationalityController.text
                                      : existingData?.nationality ?? '',
                              'province_state':
                                  provinceStateController.text.isNotEmpty
                                      ? provinceStateController.text
                                      : existingData?.provinceState ?? '',
                              'address_local': addressController.text.isNotEmpty
                                  ? addressController.text
                                  : existingData?.addressLocal ?? '',
                              'preferred_position':
                                  preferredPositionController.text.isNotEmpty
                                      ? preferredPositionController.text
                                      : existingData?.preferredPosition ?? '',
                              'notice_period':
                                  noticePeriodController.text.isNotEmpty
                                      ? noticePeriodController.text
                                      : existingData?.noticePeriod ?? '',
                              // Include all other fields using controller values or defaults
                              'marital_status':
                                  maritalStatusController.text.isNotEmpty
                                      ? maritalStatusController.text
                                      : '',
                              'visa_status':
                                  visaStatusController.text.isNotEmpty
                                      ? visaStatusController.text
                                      : '',
                              'nationality_country_id': int.tryParse(
                                      nationalityCountryIdController.text) ??
                                  0,
                              'current_country_id': int.tryParse(
                                      currentCountryIdController.text) ??
                                  0,
                              'experience_years': double.tryParse(
                                      experienceYearsController.text) ??
                                  0.0,
                              'uae_experience_years': double.tryParse(
                                      uaeExperienceYearsController.text) ??
                                  0.0,
                              'other_experience_years': double.tryParse(
                                      otherExperienceYearsController.text) ??
                                  0.0,
                              'current_ctc':
                                  double.tryParse(currentCtcController.text) ??
                                      0.0,
                              'expected_ctc':
                                  double.tryParse(expectedCtcController.text) ??
                                      0.0,
                              'available_from':
                                  availableFromController.text.isNotEmpty
                                      ? availableFromController.text
                                      : '',
                              'reason_leaving':
                                  reasonLeavingController.text.isNotEmpty
                                      ? reasonLeavingController.text
                                      : '',
                              'conviction_yn':
                                  convictionYnController.text == '1' ? 1 : 0,
                              'conviction_details':
                                  convictionDetailsController.text.isNotEmpty
                                      ? convictionDetailsController.text
                                      : '',
                              'govt_issue_yn':
                                  govtIssueYnController.text == '1' ? 1 : 0,
                              'govt_issue_details':
                                  govtIssueDetailsController.text.isNotEmpty
                                      ? govtIssueDetailsController.text
                                      : '',
                              'reference_permission_yn':
                                  referencePermissionYnController.text == '1'
                                      ? 1
                                      : 0,

                              'avatar_file':
                                  avatarFileController.text.isNotEmpty
                                      ? avatarFileController.text
                                      : '',
                              'cv_file': cvFileController.text.isNotEmpty
                                  ? cvFileController.text
                                  : '',
                            };

                            print(
                                'Sending profile update with all fields: $profileData');
                            print('User ID: ${user?.id}');
                            context.read<UserBloc>().add(
                                  UpdateProfileDataEvent(
                                    candidateId: int.parse(user?.id ?? '0'),
                                    profileData: profileData,
                                  ),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ConstColors.primary,
                      padding:
                          EdgeInsets.symmetric(vertical: widget.height * 0.02),
                    ),
                    child: state is ProfileDataUpdateLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Basic Info',
                            style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, double w,
      {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildNumericField(
      String label, TextEditingController controller, double w,
      {bool isCurrency = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        prefixText: isCurrency ? 'AED ' : null,
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Please enter a valid ${isCurrency ? "amount" : "number"}';
          }
          if (number < 0) {
            return 'Please enter a positive ${isCurrency ? "amount" : "number"}';
          }
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField(
      String label, TextEditingController controller, double w) {
    return TextField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label,
      TextEditingController controller, double w,
      {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        isDense: true,
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select $label';
              }
              // Validate date format
              if (_parseDate(value) == null) {
                return 'Please enter a valid date';
              }
              return null;
            }
          : (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  _parseDate(value) == null) {
                return 'Please enter a valid date';
              }
              return null;
            },
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _parseDate(controller.text) ?? DateTime.now(),
          firstDate: label == 'Date of Birth'
              ? DateTime(1950)
              : DateTime.now().subtract(const Duration(days: 365 * 10)),
          lastDate: label == 'Date of Birth'
              ? DateTime.now()
              : DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          final String formattedDate =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          setState(() {
            controller.text = formattedDate;
          });
          // Trigger validation after date selection
          _formKey.currentState?.validate();
        }
      },
    );
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

// Education Tab
class EducationTab extends StatefulWidget {
  final double width;
  final double height;

  const EducationTab({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<EducationTab> createState() => _EducationTabState();
}

class _EducationTabState extends State<EducationTab> {
  List<EducationRecord> _educationList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEducation();
  }

  void _fetchEducation() {
    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      try {
        final candidateId = int.parse(user.id);
        context.read<UserBloc>().add(GetEducationEvent(candidateId: candidateId));
      } catch (e) {
        print('Error parsing candidate ID: $e');
      }
    }
  }

  void _showAddEducationDialog({EducationRecord? education}) {
    final isEditing = education != null;
    final formKey = GlobalKey<FormState>();

    final qualificationController = TextEditingController(
      text: education?.qualification ?? '',
    );
    final institutionController = TextEditingController(
      text: education?.institution ?? '',
    );
    final fieldOfStudyController = TextEditingController(
      text: education?.fieldOfStudy ?? '',
    );
    final graduationYearController = TextEditingController(
      text: education?.graduationYear ?? '',
    );
    final gpaController = TextEditingController(
      text: education?.gpa?.toString() ?? '',
    );
    final gradeController = TextEditingController(
      text: education?.grade ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(widget.width * 0.04),
          width: widget.width * 0.9,
          constraints: BoxConstraints(maxHeight: widget.height * 0.9),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Education' : 'Add Education',
                    style: TextStyle(
                      fontSize: widget.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: widget.height * 0.03),
                  _buildEducationTextField(
                    'Qualification',
                    qualificationController,
                    widget.width,
                    isRequired: true,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildEducationTextField(
                    'Institution',
                    institutionController,
                    widget.width,
                    isRequired: true,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildEducationTextField(
                    'Field of Study',
                    fieldOfStudyController,
                    widget.width,
                    isRequired: true,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildEducationTextField(
                    'Graduation Year',
                    graduationYearController,
                    widget.width,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildEducationNumericField(
                    'GPA',
                    gpaController,
                    widget.width,
                    maxValue: 4.0,
                  ),
                  SizedBox(height: widget.height * 0.02),
                  _buildEducationTextField(
                    'Grade',
                    gradeController,
                    widget.width,
                  ),
                  SizedBox(height: widget.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: widget.width * 0.02),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newEducation = EducationRecord(
                              id: education?.id,
                              qualification:
                                  qualificationController.text.trim(),
                              institution: institutionController.text.trim(),
                              fieldOfStudy: fieldOfStudyController.text.trim(),
                              graduationYear:
                                  graduationYearController.text.trim(),
                              gpa: gpaController.text.isNotEmpty
                                  ? double.tryParse(gpaController.text)
                                  : null,
                              grade: gradeController.text.trim().isNotEmpty
                                  ? gradeController.text.trim()
                                  : null,
                            );

                            if (isEditing) {
                              setState(() {
                                final index = _educationList
                                    .indexWhere((e) => e.id == education.id);
                                if (index != -1) {
                                  _educationList[index] = newEducation;
                                }
                              });
                            } else {
                              setState(() {
                                _educationList.add(newEducation);
                              });
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstColors.primary,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEducationTextField(
    String label,
    TextEditingController controller,
    double w, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        isDense: true,
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              // Validate graduation year format
              if (label.contains('Graduation Year')) {
                if (value.length != 4) {
                  return 'Please enter a valid 4-digit year';
                }
                final year = int.tryParse(value);
                if (year == null) {
                  return 'Please enter a valid year';
                }
                final currentYear = DateTime.now().year;
                if (year < 1900 || year > currentYear + 1) {
                  return 'Please enter a valid year (1900-${currentYear + 1})';
                }
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildEducationNumericField(
    String label,
    TextEditingController controller,
    double w, {
    double? maxValue,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(w * 0.02),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Please enter a valid number';
          }
          if (number < 0) {
            return 'Please enter a positive number';
          }
          if (maxValue != null && number > maxValue) {
            return 'Please enter a value between 0 and $maxValue';
          }
        }
        return null;
      },
    );
  }

  void _saveEducation() {
    final user = CareersUserManager.getCurrentUser();
    if (user == null) return;

    context.read<UserBloc>().add(
          UpdateEducationEvent(
            candidateId: int.parse(user.id),
            educationRecords: _educationList,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is EducationLoaded) {
          setState(() {
            _educationList = state.educationRecords;
            _isLoading = false;
          });
        } else if (state is EducationError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is EducationLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showAddEducationDialog(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Education',
                style: TextStyle(color: Colors.white),
              ),
              style:
                  ElevatedButton.styleFrom(backgroundColor: ConstColors.primary),
            ),
            SizedBox(height: widget.height * 0.02),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_educationList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(widget.height * 0.03),
                  child: const Text('No education records added yet'),
                ),
              )
            else
              ..._educationList.asMap().entries.map((entry) {
                final index = entry.key;
                final education = entry.value;
                return Card(
                  margin: EdgeInsets.only(bottom: widget.height * 0.02),
                  child: ListTile(
                    title: Text(
                      education.qualification ?? 'No qualification',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (education.institution != null)
                          Text('Institution: ${education.institution}'),
                        if (education.fieldOfStudy != null)
                          Text('Field: ${education.fieldOfStudy}'),
                        if (education.graduationYear != null)
                          Text('Year: ${education.graduationYear}'),
                        if (education.gpa != null) Text('GPA: ${education.gpa}'),
                        if (education.grade != null)
                          Text('Grade: ${education.grade}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEducationDialog(
                            education: education,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _educationList.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            if (_educationList.isNotEmpty && !_isLoading) ...[
              SizedBox(height: widget.height * 0.02),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state is EducationUpdateLoading ? null : _saveEducation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: widget.height * 0.02,
                        ),
                      ),
                      child: state is EducationUpdateLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Education',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Experience Tab
class ExperienceTab extends StatefulWidget {
  final double width;
  final double height;

  const ExperienceTab({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<ExperienceTab> createState() => _ExperienceTabState();
}

class _ExperienceTabState extends State<ExperienceTab> {
  List<ExperienceRecord> _experienceList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExperience();
  }

  void _fetchExperience() {
    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      try {
        final candidateId = int.parse(user.id);
        context.read<UserBloc>().add(GetExperienceEvent(candidateId: candidateId));
      } catch (e) {
        print('Error parsing candidate ID: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is ExperienceLoaded) {
          setState(() {
            _experienceList = state.experienceRecords;
            _isLoading = false;
          });
        } else if (state is ExperienceError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ExperienceLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Show add experience dialog
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Experience',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstColors.primary,
              ),
            ),
            SizedBox(height: widget.height * 0.02),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_experienceList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(widget.height * 0.03),
                  child: const Text('No experience records added yet'),
                ),
              )
            else
              ..._experienceList.map((experience) {
                return Card(
                  margin: EdgeInsets.only(bottom: widget.height * 0.02),
                  child: ListTile(
                    title: Text(
                      experience.position ?? 'No position',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (experience.companyName != null)
                          Text('Organization: ${experience.companyName}'),
                        if (experience.startDate != null)
                          Text('From: ${experience.startDate}'),
                        if (experience.endDate != null && !(experience.isCurrent ?? false))
                          Text('To: ${experience.endDate}'),
                        if (experience.isCurrent == true)
                          const Text('Current Role', style: TextStyle(color: Colors.green)),
                        if (experience.jobDescription != null)
                          Text('Description: ${experience.jobDescription}'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// Family Tab
class FamilyTab extends StatefulWidget {
  final double width;
  final double height;

  const FamilyTab({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<FamilyTab> createState() => _FamilyTabState();
}

class _FamilyTabState extends State<FamilyTab> {
  List<FamilyMember> _familyList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFamily();
  }

  void _fetchFamily() {
    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      try {
        final candidateId = int.parse(user.id);
        context.read<UserBloc>().add(GetFamilyEvent(candidateId: candidateId));
      } catch (e) {
        print('Error parsing candidate ID: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is FamilyLoaded) {
          setState(() {
            _familyList = state.familyMembers;
            _isLoading = false;
          });
        } else if (state is FamilyError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is FamilyLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Show add family dialog
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Family Member',
                  style: TextStyle(color: Colors.white)),
              style:
                  ElevatedButton.styleFrom(backgroundColor: ConstColors.primary),
            ),
            SizedBox(height: widget.height * 0.02),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_familyList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(widget.height * 0.03),
                  child: const Text('No family members added yet'),
                ),
              )
            else
              ..._familyList.map((member) {
                return Card(
                  margin: EdgeInsets.only(bottom: widget.height * 0.02),
                  child: ListTile(
                    title: Text(
                      member.name ?? 'No name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (member.relationship != null)
                          Text('Relation: ${member.relationship}'),
                        if (member.occupation != null)
                          Text('Profession: ${member.occupation}'),
                        if (member.phone != null)
                          Text('Phone: ${member.phone}'),
                        if (member.email != null)
                          Text('Email: ${member.email}'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// References Tab
class ReferencesTab extends StatefulWidget {
  final double width;
  final double height;

  const ReferencesTab({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<ReferencesTab> createState() => _ReferencesTabState();
}

class _ReferencesTabState extends State<ReferencesTab> {
  List<Reference> _referencesList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReferences();
  }

  void _fetchReferences() {
    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      try {
        final candidateId = int.parse(user.id);
        context.read<UserBloc>().add(GetReferencesEvent(candidateId: candidateId));
      } catch (e) {
        print('Error parsing candidate ID: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is ReferencesLoaded) {
          setState(() {
            _referencesList = state.references;
            _isLoading = false;
          });
        } else if (state is ReferencesError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ReferencesLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Show add reference dialog
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Reference',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstColors.primary,
              ),
            ),
            SizedBox(height: widget.height * 0.02),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_referencesList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(widget.height * 0.03),
                  child: const Text('No references added yet'),
                ),
              )
            else
              ..._referencesList.map((reference) {
                return Card(
                  margin: EdgeInsets.only(bottom: widget.height * 0.02),
                  child: ListTile(
                    title: Text(
                      reference.name ?? 'No name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reference.position != null)
                          Text('Designation: ${reference.position}'),
                        if (reference.organization != null)
                          Text('Organization: ${reference.organization}'),
                        if (reference.phone != null)
                          Text('Contact: ${reference.phone}'),
                        if (reference.email != null)
                          Text('Email: ${reference.email}'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// Professional Programs Tab
class ProfessionalProgramsTab extends StatefulWidget {
  final double width;
  final double height;

  const ProfessionalProgramsTab(
      {Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<ProfessionalProgramsTab> createState() => _ProfessionalProgramsTabState();
}

class _ProfessionalProgramsTabState extends State<ProfessionalProgramsTab> {
  List<ProfessionalProgram> _programsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfessionalPrograms();
  }

  void _fetchProfessionalPrograms() {
    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      try {
        final candidateId = int.parse(user.id);
        context.read<UserBloc>().add(GetProfessionalProgramsEvent(candidateId: candidateId));
      } catch (e) {
        print('Error parsing candidate ID: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is ProfessionalProgramsLoaded) {
          setState(() {
            _programsList = state.programs;
            _isLoading = false;
          });
        } else if (state is ProfessionalProgramsError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProfessionalProgramsLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(widget.width * 0.04),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Show add program dialog
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Professional Program',
                  style: TextStyle(color: Colors.white)),
              style:
                  ElevatedButton.styleFrom(backgroundColor: ConstColors.primary),
            ),
            SizedBox(height: widget.height * 0.02),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_programsList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(widget.height * 0.03),
                  child: const Text('No professional programs added yet'),
                ),
              )
            else
              ..._programsList.map((program) {
                return Card(
                  margin: EdgeInsets.only(bottom: widget.height * 0.02),
                  child: ListTile(
                    title: Text(
                      program.programName ?? 'No program name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (program.institution != null)
                          Text('Institute: ${program.institution}'),
                        if (program.completionDate != null)
                          Text('Year: ${program.completionDate}'),
                        if (program.certificateNumber != null)
                          Text('Certificate: ${program.certificateNumber}'),
                        if (program.expiryDate != null)
                          Text('Expiry: ${program.expiryDate}'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
