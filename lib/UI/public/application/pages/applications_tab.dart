import 'package:admin_app/UI/public/application/bloc/application_bloc.dart';
import 'package:admin_app/UI/public/application/bloc/application_events.dart';
import 'package:admin_app/UI/public/application/bloc/application_states.dart';
import 'package:admin_app/UI/public/application/models/application_models.dart';
import 'package:admin_app/UI/public/application/widgets/application_card.dart';
import 'package:admin_app/UI/public/application/widgets/application_empty_state.dart';
import 'package:admin_app/UI/public/application/widgets/application_loading_state.dart';
import 'package:admin_app/UI/public/application/widgets/status_filter_chip.dart';
import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplicationsTab extends StatefulWidget {
  final VoidCallback? onBrowseJobs;

  const ApplicationsTab({super.key, this.onBrowseJobs});

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  int? _loadedForCandidateId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final user = locator<CareersUserService>().getCurrentCareersUser();
    final candidateId = int.tryParse(user?.id ?? '');
    if (candidateId == null) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ApplicationBloc>().add(
        LoadMoreApplicationsEvent(candId: candidateId),
      );
    }
  }

  void _loadIfNeeded(int candidateId) {
    if (_loadedForCandidateId == candidateId) return;
    _loadedForCandidateId = candidateId;
    context.read<ApplicationBloc>().add(
      LoadApplicationsEvent(candId: candidateId),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = locator<CareersUserService>().getCurrentCareersUser();
    if (user == null) {
      return _buildLoginPrompt(context);
    }

    final candidateId = int.tryParse(user.id);
    if (candidateId == null) {
      return _buildLoginPrompt(context);
    }

    _loadIfNeeded(candidateId);

    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        if (state is ApplicationLoading) {
          return const ApplicationLoadingState();
        }

        if (state is ApplicationError) {
          return _buildErrorState(candidateId, state.message);
        }

        if (state is ApplicationLoaded && state.applications.isEmpty) {
          return ApplicationEmptyState(onBrowseJobs: widget.onBrowseJobs);
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ApplicationBloc>().add(
              RefreshApplicationsEvent(candId: candidateId),
            );
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by Status',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StatusFilterChip(
                            label: 'All',
                            isSelected: state is ApplicationLoaded &&
                                state.selectedStatus == null,
                            onTap: () {
                              context.read<ApplicationBloc>().add(
                                FilterApplicationsByStatusEvent(
                                  status: null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ...ApplicationStatus.values.map(
                            (status) => Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: StatusFilterChip(
                                label: status.displayName,
                                isSelected: state is ApplicationLoaded &&
                                    state.selectedStatus == status,
                                onTap: () {
                                  context.read<ApplicationBloc>().add(
                                    FilterApplicationsByStatusEvent(
                                      status: status,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state is ApplicationLoaded
                    ? ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: state.filteredApplications.length +
                            (state is ApplicationLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.filteredApplications.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final application = state.filteredApplications[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: ApplicationCard(application: application),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_crop_circle_badge_exclam,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sign in to view applications',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Log in to see jobs you have applied for.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: 'Login',
              isFullWidth: false,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(int candidateId, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: 'Try Again',
              isFullWidth: false,
              onPressed: () {
                context.read<ApplicationBloc>().add(
                  LoadApplicationsEvent(candId: candidateId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
