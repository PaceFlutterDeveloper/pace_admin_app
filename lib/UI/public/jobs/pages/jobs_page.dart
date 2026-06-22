import 'package:admin_app/UI/public/application/pages/applications_tab.dart';
import 'package:admin_app/UI/public/jobs/components/careers_bottom_nav.dart';
import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/UI/public/jobs/pages/careers_home_tab.dart';
import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/pages/profile_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobsPage extends StatefulWidget {
  final int initialTabIndex;

  const JobsPage({super.key, this.initialTabIndex = 0});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late int _currentNavIndex;
  bool _isLoggedIn = false;

  static const _titles = ['Pace Careers', 'Applications', 'Profile'];

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialTabIndex.clamp(0, 2);
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    setState(() {
      _isLoggedIn = locator<CareersUserService>().isCareersUserLoggedIn();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthStatus();
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
  }

  void _goToHomeTab() {
    setState(() => _currentNavIndex = 0);
  }

  List<Widget>? _buildAppBarActions(BuildContext context) {
    if (_currentNavIndex != 0 || _isLoggedIn) return null;

    final theme = Theme.of(context);
    return [
      Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: TextButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginPage(),
                  ),
                )
                .then((_) => _checkAuthStatus());
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          child: Text(
            'Login',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CareersScaffold(
      title: _titles[_currentNavIndex],
      actions: _buildAppBarActions(context),
      bottomNavigationBar: CareersBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          const CareersHomeTab(),
          ApplicationsTab(onBrowseJobs: _goToHomeTab),
          CareersProfilePage(
            embedded: true,
            onAuthChanged: _checkAuthStatus,
          ),
        ],
      ),
    );
  }
}
