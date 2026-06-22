import 'dart:async';

import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/components/careers_job_card.dart';
import 'package:admin_app/UI/public/jobs/components/enhanced_search_bar.dart';
import 'package:admin_app/UI/public/jobs/models/school_model.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_section_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CareersHomeTab extends StatefulWidget {
  const CareersHomeTab({super.key});

  @override
  State<CareersHomeTab> createState() => _CareersHomeTabState();
}

class _CareersHomeTabState extends State<CareersHomeTab>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  String _location = '';
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  bool _isLoadingSchools = false;
  Timer? _searchDebounceTimer;
  Timer? _locationDebounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(FetchJobsEvent());
    context.read<JobsBloc>().add(FetchSchoolsEvent());
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _locationDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Column(
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
                    context.read<JobsBloc>().add(
                      FilterByLocationEvent(location),
                    );
                  }
                },
              );
            },
            onSchoolChanged: (school) {
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
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
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
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
                      return CareersJobCard(job: state.jobs[index]);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
