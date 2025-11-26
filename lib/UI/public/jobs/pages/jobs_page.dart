import 'dart:async';
import 'dart:developer';

import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/components/careers_bottom_nav.dart';
import 'package:admin_app/UI/public/jobs/components/enhanced_search_bar.dart';
import 'package:admin_app/UI/public/jobs/components/indeed_job_card.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/pages/messages_page.dart';
import 'package:admin_app/UI/public/user/pages/my_jobs_page.dart';
import 'package:admin_app/UI/public/user/pages/profile_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/user/utils/auth_guard.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String _searchQuery = '';
  String _location = 'Abu Dhabi';
  int _currentNavIndex = 0;
  Set<int> _bookmarkedJobs = {};
  Set<int> _hiddenJobs = {};
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  bool _isLoadingSchools = false;
  bool _isSearching = false;
  Timer? _searchDebounceTimer;
  bool _isLoggedIn = false;
  String? _userName;

  @override
  void initState() {
    super.initState();

    // Check authentication status
    _checkAuthStatus();

    // Fetch initial jobs and schools
    context.read<JobsBloc>().add(FetchJobsEvent());
    // Add a small delay to ensure jobs are loaded first
    Future.delayed(Duration(milliseconds: 100), () {
      context.read<JobsBloc>().add(FetchSchoolsEvent());
    });
  }

  void _checkAuthStatus() {
    final userService = CareersUserService();
    setState(() {
      _isLoggedIn = userService.isCareersUserLoggedIn();
      if (_isLoggedIn) {
        final user = userService.getCurrentCareersUser();
        _userName = user?.name;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh auth status when returning from login/signup
    _checkAuthStatus();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear user data and refresh auth status
              CareersUserService().clearCurrentCareersUser();
              _checkAuthStatus();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'indeed',
          style: TextStyle(
            fontSize: w * 0.06,
            fontWeight: FontWeight.w700,
            color: ConstColors.blueColor,
          ),
        ),
        backgroundColor: ConstColors.whiteColor,
        elevation: 0,
        actions: [
          if (_isLoggedIn) ...[
            // Show user name and logout option
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ConstColors.primary,
                      child: Text(
                        _userName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _userName ?? 'User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ConstColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Show login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined),
          ),
        ],
        iconTheme: IconThemeData(
          color: ConstColors.textDark,
          size: w * 0.06,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Search Bar with School Dropdown
            BlocListener<JobsBloc, JobsState>(
              listener: (context, state) {
                if (state is SchoolsLoaded) {
                  setState(() {
                    _schools = state.schools;
                    _isLoadingSchools = false;
                  });
                } else if (state is SchoolsLoading) {
                  setState(() {
                    _isLoadingSchools = true;
                  });
                } else if (state is JobsLoaded) {
                  setState(() {
                    _schools = state.schools;
                    _isLoadingSchools = false;
                    if (state.selectedSchoolId != null && _schools.isNotEmpty) {
                      try {
                        _selectedSchool = _schools.firstWhere(
                          (school) => school.id == state.selectedSchoolId,
                        );
                      } catch (e) {
                        _selectedSchool = null;
                      }
                    } else {
                      _selectedSchool = null;
                    }
                  });
                }
              },
              child: EnhancedSearchBar(
                searchQuery: _searchQuery,
                location: _location,
                selectedSchool: _selectedSchool,
                schools: _schools,
                isLoadingSchools: _isLoadingSchools,
                isSearching: _isSearching,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                    _isSearching = query.isNotEmpty;
                  });

                  // Cancel previous timer
                  _searchDebounceTimer?.cancel();

                  if (query.isNotEmpty) {
                    // Set new timer for debounced search
                    _searchDebounceTimer =
                        Timer(Duration(milliseconds: 500), () {
                      log('Debounced search for: $query');
                      context.read<JobsBloc>().add(SearchJobsEvent(query));
                      setState(() {
                        _isSearching = false;
                      });
                    });
                  } else {
                    // If query is empty, search immediately
                    setState(() {
                      _isSearching = false;
                    });
                    context.read<JobsBloc>().add(SearchJobsEvent(''));
                  }
                },
                onLocationChanged: (location) {
                  setState(() {
                    _location = location;
                  });
                },
                onSchoolChanged: (school) {
                  log('School changed to: ${school?.name} (ID: ${school?.id})');
                  setState(() {
                    _selectedSchool = school;
                  });
                  context.read<JobsBloc>().add(SelectSchoolEvent(school?.id));
                },
                onRetrySchools: () {
                  context.read<JobsBloc>().add(FetchSchoolsEvent());
                },
              ),
            ),

            // "Jobs for you" Section Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jobs for you',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w700,
                      color: ConstColors.textDark,
                    ),
                  ),
                  SizedBox(height: h * 0.002),
                  Text(
                    'Jobs based on your activity on Indeed',
                    style: TextStyle(
                      fontSize: w * 0.032,
                      fontWeight: FontWeight.w400,
                      color: ConstColors.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Jobs List
            Expanded(
              child: BlocBuilder<JobsBloc, JobsState>(
                builder: (context, state) {
                  if (state is JobsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is JobsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: w * 0.15,
                            color: Colors.red,
                          ),
                          SizedBox(height: h * 0.02),
                          Text(
                            'Error loading jobs',
                            style: TextStyle(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600,
                              color: ConstColors.textDark,
                            ),
                          ),
                          SizedBox(height: h * 0.01),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: w * 0.035,
                              color: ConstColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: h * 0.03),
                          ElevatedButton(
                            onPressed: () {
                              context.read<JobsBloc>().add(FetchJobsEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ConstColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.08,
                                vertical: h * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(w * 0.025),
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w600,
                                color: ConstColors.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is JobsLoaded) {
                    if (state.jobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: w * 0.15,
                              color: ConstColors.textLight,
                            ),
                            SizedBox(height: h * 0.02),
                            Text(
                              'No jobs found',
                              style: TextStyle(
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.w600,
                                color: ConstColors.textDark,
                              ),
                            ),
                            SizedBox(height: h * 0.01),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Try adjusting your search criteria'
                                  : 'No job listings available at the moment',
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: ConstColors.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              SizedBox(height: h * 0.03),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  context
                                      .read<JobsBloc>()
                                      .add(ClearFiltersEvent());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ConstColors.primary,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.08,
                                    vertical: h * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(w * 0.025),
                                  ),
                                ),
                                child: Text(
                                  'Clear Search',
                                  style: TextStyle(
                                    fontSize: w * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color: ConstColors.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<JobsBloc>().add(RefreshJobsEvent(
                              searchQuery: _searchQuery,
                              filterBy: 'All',
                            ));
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: h * 0.05),
                        itemCount: state.jobs.length,
                        itemBuilder: (context, index) {
                          final job = state.jobs[index];
                          return IndeedJobCard(
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
                            onHide: () {
                              setState(() {
                                _hiddenJobs.add(job.jobId);
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
      ),
      bottomNavigationBar: CareersBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          // Handle navigation based on index
          switch (index) {
            case 0:
              // Home - already on jobs page
              break;
            case 1:
              // My jobs - require authentication
              AuthGuard.requireAuth(context, onAuthenticated: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyJobsPage(),
                  ),
                );
              });
              break;
            case 2:
              // Messages - require authentication
              AuthGuard.requireAuth(context, onAuthenticated: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MessagesPage(),
                  ),
                );
              });
              break;
            case 3:
              // Profile - require authentication
              AuthGuard.requireAuth(context, onAuthenticated: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              });
              break;
          }
        },
      ),
    );
  }
}
