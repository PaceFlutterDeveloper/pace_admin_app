import 'package:admin_app/UI/public/application/bloc/application_bloc.dart';
import 'package:admin_app/UI/public/application/bloc/application_events.dart';
import 'package:admin_app/UI/public/application/bloc/application_states.dart';
import 'package:admin_app/UI/public/application/models/application_models.dart';
import 'package:admin_app/UI/public/application/widgets/application_card.dart';
import 'package:admin_app/UI/public/application/widgets/application_empty_state.dart';
import 'package:admin_app/UI/public/application/widgets/application_loading_state.dart';
import 'package:admin_app/UI/public/application/widgets/status_filter_chip.dart';
import 'package:admin_app/UI/public/shared/components/careers_empty_state.dart';
import 'package:admin_app/UI/public/shared/components/careers_sign_in_prompt.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationsTab extends StatefulWidget {
  final VoidCallback? onBrowseJobs;
  final bool isActive;

  const ApplicationsTab({super.key, this.onBrowseJobs, this.isActive = true});

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
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onShown();
      });
    }
  }

  @override
  void didUpdateWidget(ApplicationsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _onShown();
    }
  }

  void _onShown() {
    final user = locator<CareersUserService>().getCurrentCareersUser();
    final candidateId = int.tryParse(user?.id ?? '');
    if (candidateId == null) {
      _loadedForCandidateId = null;
      if (mounted) setState(() {});
      return;
    }

    final bloc = context.read<ApplicationBloc>();
    final silent =
        _loadedForCandidateId == candidateId && bloc.state is ApplicationLoaded;
    _loadedForCandidateId = candidateId;
    bloc.add(
      LoadApplicationsEvent(candId: candidateId, silent: silent),
    );
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is LoginSuccess || state is LogoutSuccess) {
          _loadedForCandidateId = null;
          if (widget.isActive) {
            _onShown();
          } else if (mounted) {
            setState(() {});
          }
        }
      },
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final user = locator<CareersUserService>().getCurrentCareersUser();
    if (user == null) {
      _loadedForCandidateId = null;
      return _buildLoginPrompt(context);
    }

    final candidateId = int.tryParse(user.id);
    if (candidateId == null) {
      _loadedForCandidateId = null;
      return _buildLoginPrompt(context);
    }

    return BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        if (state is ApplicationLoading || state is ApplicationInitial) {
          return const ApplicationLoadingState();
        }

        if (state is ApplicationError) {
          return _buildErrorState(candidateId, state.message);
        }

        if (state is ApplicationLoaded && state.applications.isEmpty) {
          return ApplicationEmptyState(onBrowseJobs: widget.onBrowseJobs);
        }

        return RefreshIndicator(
          color: CareersColors.primary,
          onRefresh: () async {
            context.read<ApplicationBloc>().add(
              RefreshApplicationsEvent(candId: candidateId),
            );
          },
          child: Column(
            children: [
              _StatusFilterBar(
                selectedStatus:
                    state is ApplicationLoaded ? state.selectedStatus : null,
                onSelected: (status) {
                  context.read<ApplicationBloc>().add(
                    FilterApplicationsByStatusEvent(status: status),
                  );
                },
              ),
              Expanded(
                child: state is ApplicationLoaded
                    ? _buildList(state)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(ApplicationLoaded state) {
    final applications = state.filteredApplications;

    if (applications.isEmpty) {
      return const CareersEmptyState(
        icon: CupertinoIcons.line_horizontal_3_decrease,
        title: 'Nothing in this status',
        message: 'Try a different status filter to see your applications.',
      );
    }

    final isLoadingMore = state is ApplicationLoadingMore;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        CareersSpacing.screenH,
        CareersSpacing.cardPadding,
        CareersSpacing.screenH,
        CareersSpacing.section,
      ),
      itemCount: applications.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= applications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: CareersSpacing.cardPadding),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: CareersSpacing.cardPadding),
          child: ApplicationCard(application: applications[index]),
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return CareersSignInPrompt(
      title: 'Sign in to view applications',
      message: 'Track the status of every role you have applied for.',
      onReturn: () {
        if (mounted) _onShown();
      },
    );
  }

  Widget _buildErrorState(int candidateId, String message) {
    return CareersErrorState(
      title: 'Could not load applications',
      onRetry: () {
        context.read<ApplicationBloc>().add(
          LoadApplicationsEvent(candId: candidateId),
        );
      },
    );
  }
}

/// Horizontal status filter row. Pinned above the list so the active filter is
/// always visible.
class _StatusFilterBar extends StatelessWidget {
  final ApplicationStatus? selectedStatus;
  final ValueChanged<ApplicationStatus?> onSelected;

  const _StatusFilterBar({
    required this.selectedStatus,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: CareersColors.surface,
        border: Border(bottom: BorderSide(color: CareersColors.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: CareersSpacing.screenH,
          vertical: 12,
        ),
        child: Row(
          children: [
            StatusFilterChip(
              label: 'All',
              isSelected: selectedStatus == null,
              onTap: () => onSelected(null),
            ),
            for (final status in ApplicationStatus.values)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: StatusFilterChip(
                  label: status.displayName,
                  isSelected: selectedStatus == status,
                  onTap: () => onSelected(status),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
