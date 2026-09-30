import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        appBar: AppBar(
          title: const Text('Complete your profile'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CareersColors.divider),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 9),
                padding: const EdgeInsets.symmetric(
                  horizontal: CareersSpacing.screenH - 4,
                  vertical: 4,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                overlayColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                indicator: const BoxDecoration(
                  color: CareersColors.primary,
                  borderRadius: CareersRadius.pillAll,
                ),
                labelColor: CareersColors.onPrimary,
                unselectedLabelColor: CareersColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                tabs: List.generate(_tabLabels.length, (index) {
                  final needsAttention =
                      ProfileCompletionMapper.isSectionIncomplete(
                    _tabSections[index],
                    _completion,
                  );
                  return Tab(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_tabLabels[index]),
                          if (needsAttention) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              CupertinoIcons.exclamationmark_circle_fill,
                              size: 13,
                              color: CareersColors.warning,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
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
