import 'dart:async';
import 'dart:developer';

import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/components/careers_bottom_nav.dart';
import 'package:admin_app/UI/public/jobs/components/careers_job_card.dart';
import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/UI/public/jobs/components/enhanced_search_bar.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/pages/messages_page.dart';
import 'package:admin_app/UI/public/user/pages/my_jobs_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/user/utils/auth_guard.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_section_header.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String _searchQuery = '';
  String _location = '';
  int _currentNavIndex = 0;
  final Set<int> _bookmarkedJobs = {};
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  bool _isLoadingSchools = false;
  Timer? _searchDebounceTimer;
  Timer? _locationDebounceTimer;
  bool _isLoggedIn = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    context.read<JobsBloc>().add(FetchJobsEvent());
    context.read<JobsBloc>().add(FetchSchoolsEvent());
  }

  void _checkAuthStatus() {
    final userService = locator<CareersUserService>();
    setState(() {
      _isLoggedIn = userService.isCareersUserLoggedIn();
      if (_isLoggedIn) {
        _userName = userService.getCurrentCareersUser()?.name;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _locationDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthStatus();
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              locator<CareersUserService>().clearCurrentCareersUser();
              _checkAuthStatus();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    final theme = Theme.of(context);

    return [
      if (_isLoggedIn)
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') _handleLogout();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.square_arrow_right,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Logout', style: GoogleFonts.inter()),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    _userName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _userName ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
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

  /// Pushes the page for a bottom-nav tab and restores the Jobs tab
  /// selection once the pushed page is popped.
  Future<void> _pushTab(int index, Future<void> Function() push) async {
    setState(() => _currentNavIndex = index);
    await push();
    if (mounted) setState(() => _currentNavIndex = 0);
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    switch (index) {
      case 0:
        setState(() => _currentNavIndex = 0);
        break;
      case 1:
        AuthGuard.requireAuth(
          context,
          onAuthenticated: () {
            _pushTab(
              index,
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MyJobsPage(),
                ),
              ),
            );
          },
        );
        break;
      case 2:
        AuthGuard.requireAuth(
          context,
          onAuthenticated: () {
            _pushTab(
              index,
              () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const MessagesPage(),
                ),
              ),
            );
          },
        );
        break;
      case 3:
        AuthGuard.requireAuth(
          context,
          onAuthenticated: () {
            _pushTab(
              index,
              () => context.pushNamed(Routes.careersProfile.name),
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CareersScaffold(
      title: 'Pace Careers',
      actions: _buildAppBarActions(context),
      bottomNavigationBar: CareersBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocListener<JobsBloc, JobsState>(
            listener: (context, state) {
              if (state is SchoolsLoaded) {
                setState(() {
                  _schools = state.schools;
                  _isLoadingSchools = false;
                });
              } else if (state is SchoolsLoading) {
                if (_schools.isEmpty) {
                  setState(() => _isLoadingSchools = true);
                }
              } else if (state is SchoolsError) {
                setState(() => _isLoadingSchools = false);
              } else if (state is JobsLoaded) {
                setState(() {
                  // Keep existing schools if a concurrent jobs fetch arrives
                  // before schools are merged into JobsLoaded.
                  if (state.schools.isNotEmpty) {
                    _schools = state.schools;
                  }
                  _isLoadingSchools = false;
                  if (state.selectedSchoolId != null && _schools.isNotEmpty) {
                    try {
                      _selectedSchool = _schools.firstWhere(
                        (school) => school.id == state.selectedSchoolId,
                      );
                    } catch (_) {
                      _selectedSchool = null;
                    }
                  } else {
                    _selectedSchool = null;
                  }
                });
                if (state.schools.isEmpty && _schools.isEmpty) {
                  context.read<JobsBloc>().add(FetchSchoolsEvent());
                }
              }
            },
            child: EnhancedSearchBar(
              searchQuery: _searchQuery,
              location: _location,
              selectedSchool: _selectedSchool,
              schools: _schools,
              isLoadingSchools: _isLoadingSchools,
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
                _searchDebounceTimer?.cancel();
                _searchDebounceTimer = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (mounted) {
                      log('Debounced search filter: $query');
                      context.read<JobsBloc>().add(FilterBySearchEvent(query));
                    }
                  },
                );
              },
              onLocationChanged: (location) {
                setState(() => _location = location);
                _locationDebounceTimer?.cancel();
                _locationDebounceTimer = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (mounted) {
                      log('Debounced location filter: $location');
                      context.read<JobsBloc>().add(
                        FilterByLocationEvent(location),
                      );
                    }
                  },
                );
              },
              onSchoolChanged: (school) {
                log('School changed to: ${school?.name} (ID: ${school?.id})');
                setState(() => _selectedSchool = school);
                context.read<JobsBloc>().add(SelectSchoolEvent(school?.id));
              },
              onRetrySchools: () {
                context.read<JobsBloc>().add(FetchSchoolsEvent());
              },
            ),
          ),
          const AppSectionHeader(
            title: 'Open Positions',
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              'Explore career opportunities across Pace Education Group',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                if (state is JobsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: AppErrorState.generic(
                        title: 'Error loading jobs',
                        message: state.message,
                        onRetry: () {
                          context.read<JobsBloc>().add(FetchJobsEvent());
                        },
                      ),
                    ),
                  );
                }

                if (state is JobsLoaded) {
                  if (state.jobs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.briefcase,
                              size: 56,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No jobs found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _searchQuery.isNotEmpty || _location.isNotEmpty
                                  ? 'Try adjusting your search or location'
                                  : 'No job listings available at the moment',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _location.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              AppButton.primary(
                                label: 'Clear Filters',
                                isFullWidth: false,
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _location = '';
                                  });
                                  context.read<JobsBloc>().add(
                                    ClearFiltersEvent(),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: theme.colorScheme.primary,
                    onRefresh: () async {
                      context.read<JobsBloc>().add(
                        RefreshJobsEvent(
                          searchQuery: _searchQuery,
                          filterBy: 'All',
                          schoolId: _selectedSchool?.id,
                          location: _location,
                        ),
                      );
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      itemCount: state.jobs.length,
                      itemBuilder: (context, index) {
                        final job = state.jobs[index];
                        return CareersJobCard(
                          job: job,
                          isBookmarked: _bookmarkedJobs.contains(job.jobId),
                          onBookmark: () {
                            setState(() {
                              if (_bookmarkedJobs.contains(job.jobId)) {
                                _bookmarkedJobs.remove(job.jobId);
                              } else {
                                _bookmarkedJobs.add(job.jobId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
