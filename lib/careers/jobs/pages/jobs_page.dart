import 'package:admin_app/careers/application/pages/applications_tab.dart';
import 'package:admin_app/careers/jobs/components/careers_bottom_nav.dart';
import 'package:admin_app/careers/jobs/components/careers_scaffold.dart';
import 'package:admin_app/careers/jobs/pages/careers_home_tab.dart';
import 'package:admin_app/careers/jobs/utils/secret_title_tap.dart';
import 'package:admin_app/careers/user/bloc/user_bloc.dart';
import 'package:admin_app/careers/user/bloc/user_states.dart';
import 'package:admin_app/careers/user/components/appearance_selector.dart';
import 'package:admin_app/careers/user/managers/careers_user_manager.dart';
import 'package:admin_app/careers/user/pages/login_page.dart';
import 'package:admin_app/careers/user/pages/profile_page.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/careers/user/services/careers_user_service.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/utils/dismiss_keyboard.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// First screen for careers. Signed-in users land on the jobs home.
/// Everyone else sees login until they sign in or continue as a guest.
class CareersEntry extends StatefulWidget {
  final int initialTabIndex;

  const CareersEntry({super.key, this.initialTabIndex = 0});

  @override
  State<CareersEntry> createState() => _CareersEntryState();
}

class _CareersEntryState extends State<CareersEntry> {
  late bool _atHome;
  int? _tabAfterGate;

  @override
  void initState() {
    super.initState();
    _atHome =
        CareersUserManager.isLoggedIn() || CareersUserManager.browsingAsGuest;
  }

  void _enterHome() {
    dismissKeyboard();
    CareersUserManager.browsingAsGuest = !CareersUserManager.isLoggedIn();
    _tabAfterGate = 0;
    setState(() => _atHome = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_atHome) {
      return LoginPage(onContinue: _enterHome);
    }
    return JobsPage(initialTabIndex: _tabAfterGate ?? widget.initialTabIndex);
  }
}

class JobsPage extends StatefulWidget {
  final int initialTabIndex;

  const JobsPage({super.key, this.initialTabIndex = 0});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late int _currentNavIndex;
  bool _isLoggedIn = false;
  final _secretTitleTap = SecretTitleTap();

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialTabIndex.clamp(0, 2);
    _checkAuthStatus();
    CareersUserManager.homeTabRequest.addListener(_showHomeTab);
  }

  @override
  void dispose() {
    CareersUserManager.homeTabRequest.removeListener(_showHomeTab);
    super.dispose();
  }

  void _showHomeTab() {
    if (!mounted || _currentNavIndex == 0) return;
    dismissKeyboard();
    setState(() => _currentNavIndex = 0);
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
    // The home search field stays mounted in the indexed stack, so its
    // keyboard would otherwise remain over the next tab.
    dismissKeyboard();
    setState(() => _currentNavIndex = index);
  }

  void _onAuthState(UserState state) {
    if (state is LoginSuccess) {
      CareersUserManager.browsingAsGuest = false;
    } else if (state is LogoutSuccess) {
      CareersUserManager.browsingAsGuest = true;
    }
    setState(() {
      _isLoggedIn = locator<CareersUserService>().isCareersUserLoggedIn();
      if (state is LoginSuccess) _currentNavIndex = 0;
    });
  }

  void _goToHomeTab() {
    setState(() => _currentNavIndex = 0);
  }

  void _onPaceCareersTitleTap() {
    if (!_secretTitleTap.register(DateTime.now())) return;
    secretAdminLoginOpen.value = true;
  }

  List<Widget>? _buildAppBarActions(BuildContext context) {
    if (_currentNavIndex == 2) {
      return const [AppearanceAppBarButton()];
    }

    if (_currentNavIndex != 0 || _isLoggedIn) return null;

    return [
      Center(
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
            foregroundColor: context.careers.accentText,
            backgroundColor: context.careers.primarySoft,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            shape: const RoundedRectangleBorder(
              borderRadius: CareersRadius.pillAll,
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          child: const Text('Sign in'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) =>
          current is LoginSuccess || current is LogoutSuccess,
      listener: (context, state) => _onAuthState(state),
      child: CareersScaffold(
        title: 'Pace Careers',
        brandedTitle: true,
        onTitleTap: _onPaceCareersTitleTap,
        actions: _buildAppBarActions(context),
        bottomNavigationBar: CareersBottomNav(
          currentIndex: _currentNavIndex,
          onTap: _onNavTap,
        ),
        body: IndexedStack(
          index: _currentNavIndex,
          children: [
            CareersHomeTab(isActive: _currentNavIndex == 0),
            ApplicationsTab(
              onBrowseJobs: _goToHomeTab,
              isActive: _currentNavIndex == 1,
            ),
            CareersProfilePage(
              embedded: true,
              isActive: _currentNavIndex == 2,
              onAuthChanged: _checkAuthStatus,
            ),
          ],
        ),
      ),
    );
  }
}
