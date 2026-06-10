import 'package:admin_app/UI/public/user/pages/complete_profile/basic_info_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/education_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/experience_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/family_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/programs_tab.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile/references_tab.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabbed page to complete the candidate's careers profile.
///
/// Each tab loads and saves its own section through `CareersProfileBloc`,
/// which must be provided above this page (see the careers routes).
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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

    return Scaffold(
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
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface, size: 22),
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
    );
  }
}
