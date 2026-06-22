import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/basic_info_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/education_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/experience_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/family_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/programs_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/references_tab.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_mapper.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabbed page to complete the candidate's careers profile.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ProfileCompletionModel? _completion;

  static const _tabSections = [
    ProfileSection.basic,
    ProfileSection.education,
    ProfileSection.experience,
    ProfileSection.family,
    ProfileSection.references,
    ProfileSection.programs,
  ];

  static const _tabLabels = [
    'Basic',
    'Education',
    'Experience',
    'Family',
    'References',
    'Certificates',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    context.read<CareersProfileBloc>().add(const LoadProfileEvent());
    context.read<CareersProfileBloc>().add(const CheckProfileCompletionEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<CareersProfileBloc, CareersProfileState>(
      listenWhen: (previous, current) =>
          current is ProfileCompletionLoaded ||
          current is ProfileSaved ||
          current is ProfileFilesUploaded,
      listener: (context, state) {
        if (state is ProfileCompletionLoaded) {
          setState(() => _completion = state.completion);
        } else if (state is ProfileSaved || state is ProfileFilesUploaded) {
          context.read<CareersProfileBloc>().add(
            const CheckProfileCompletionEvent(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Complete Your Profile',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          backgroundColor: isDark
              ? AppColors.surfaceContainerDark
              : AppColors.surfaceContainerLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            indicatorColor: theme.colorScheme.primary,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: List.generate(_tabLabels.length, (index) {
              final needsAttention = ProfileCompletionMapper.isSectionIncomplete(
                _tabSections[index],
                _completion,
              );
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_tabLabels[index]),
                    if (needsAttention) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.exclamationmark_circle_fill,
                        size: 14,
                        color: AppColors.warning,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            BasicInfoTab(),
            EducationTab(),
            ExperienceTab(),
            FamilyTab(),
            ReferencesTab(),
            ProgramsTab(),
          ],
        ),
      ),
    );
  }
}
