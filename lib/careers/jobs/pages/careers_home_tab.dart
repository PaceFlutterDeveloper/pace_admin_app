import 'dart:async';

import 'package:admin_app/careers/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/careers/jobs/bloc/jobs_events.dart';
import 'package:admin_app/careers/jobs/bloc/jobs_states.dart';
import 'package:admin_app/careers/jobs/components/careers_job_card.dart';
import 'package:admin_app/careers/jobs/components/enhanced_search_bar.dart';
import 'package:admin_app/careers/jobs/components/job_card_skeleton.dart';
import 'package:admin_app/careers/jobs/models/school_model.dart';
import 'package:admin_app/careers/shared/components/careers_empty_state.dart';
import 'package:admin_app/careers/shared/components/careers_hero_surface.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/careers/user/models/careers_user_model.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CareersHomeTab extends StatefulWidget {
  final bool isActive;

  const CareersHomeTab({super.key, this.isActive = true});

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
  void didUpdateWidget(CareersHomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _refresh();
    }
  }

  void _refresh() {
    context.read<JobsBloc>().add(
      RefreshJobsEvent(
        searchQuery: _searchQuery,
        filterBy: 'All',
        schoolId: _selectedSchool?.id,
        location: _location,
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _location.isNotEmpty ||
      _selectedSchool != null;

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _location = '';
      _selectedSchool = null;
    });
    context.read<JobsBloc>().add(ClearFiltersEvent());
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _locationDebounceTimer?.cancel();
    super.dispose();
  }

  void _handleSchoolsState(BuildContext context, JobsState state) {
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<JobsBloc, JobsState>(
      listener: _handleSchoolsState,
      child: RefreshIndicator(
        color: context.careers.accentText,
        onRefresh: () async => _refresh(),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) => _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CareersSpacing.screenH,
        CareersSpacing.cardPadding,
        CareersSpacing.screenH,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GreetingHero(),
          CareersSpacing.gap16,
          EnhancedSearchBar(
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
          CareersSpacing.gap24,
          BlocBuilder<JobsBloc, JobsState>(
            builder: (context, state) {
              final count = state is JobsLoaded ? state.jobs.length : null;
              return _SectionHeader(
                title: 'Open Positions',
                subtitle: 'Explore roles across Pace Education Group',
                count: count,
              );
            },
          ),
          CareersSpacing.gap16,
        ],
      ),
    );
  }

  Widget _buildContent(JobsState state) {
    if (state is JobsLoading) {
      return const SliverToBoxAdapter(
        child: JobCardSkeletonList(
          padding: EdgeInsets.fromLTRB(
            CareersSpacing.screenH,
            0,
            CareersSpacing.screenH,
            CareersSpacing.section,
          ),
        ),
      );
    }

    if (state is JobsError) {
      return SliverToBoxAdapter(
        child: CareersErrorState(
          title: 'Could not load jobs',
          onRetry: () => context.read<JobsBloc>().add(FetchJobsEvent()),
        ),
      );
    }

    if (state is JobsLoaded) {
      if (state.jobs.isEmpty) {
        return SliverToBoxAdapter(
          child: CareersEmptyState(
            icon: CupertinoIcons.briefcase,
            title: 'No jobs found',
            message: _hasActiveFilters
                ? 'Try adjusting your search or filters.'
                : 'No positions are open right now. Check back soon.',
            actionLabel: _hasActiveFilters ? 'Clear filters' : null,
            onAction: _hasActiveFilters ? _clearFilters : null,
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          CareersSpacing.screenH,
          0,
          CareersSpacing.screenH,
          CareersSpacing.section,
        ),
        sliver: SliverList.builder(
          itemCount: state.jobs.length,
          itemBuilder: (context, index) =>
              CareersJobCard(job: state.jobs[index]),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

/// Greeting band. Listens to the careers session box so logout clears the
/// name even when this widget's parent does not rebuild it.
class _GreetingHero extends StatelessWidget {
  const _GreetingHero();

  static String _timeGreeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String? _firstName(CareersUserModel? user) {
    final name = user?.name.trim() ?? '';
    if (name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<CareersUserModel>>(
      valueListenable: locator<Box<CareersUserModel>>().listenable(),
      builder: (context, box, _) {
        return _GreetingBody(
          greeting: _timeGreeting(DateTime.now()),
          firstName: _firstName(box.get('current_user')),
        );
      },
    );
  }
}

class _GreetingBody extends StatelessWidget {
  final String greeting;
  final String? firstName;

  const _GreetingBody({required this.greeting, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return CareersHeroSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstName == null ? greeting : '$greeting, $firstName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Find your next opportunity in education.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? count;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: textTheme.bodySmall),
            ],
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: context.careers.primarySoft,
              borderRadius: CareersRadius.chipAll,
            ),
            child: Text(
              count == 1 ? '1 job' : '$count jobs',
              style: textTheme.labelSmall?.copyWith(
                color: context.careers.accentText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
