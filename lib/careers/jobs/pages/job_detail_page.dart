import 'package:admin_app/careers/application/bloc/application_bloc.dart';
import 'package:admin_app/careers/application/bloc/application_events.dart';
import 'package:admin_app/careers/application/bloc/application_states.dart';
import 'package:admin_app/careers/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/careers/jobs/bloc/jobs_events.dart';
import 'package:admin_app/careers/jobs/bloc/jobs_states.dart';
import 'package:admin_app/careers/jobs/components/index.dart';
import 'package:admin_app/careers/jobs/components/careers_scaffold.dart';
import 'package:admin_app/careers/jobs/models/job_model.dart';
import 'package:admin_app/careers/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/careers/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/careers/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/careers/user/services/careers_user_service.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/careers/user/utils/profile_completion_helper.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

bool _isConnectionProblem(String message) {
  final lower = message.toLowerCase();
  return lower.contains('internet') ||
      lower.contains('connection') ||
      lower.contains('timed out') ||
      lower.contains('network');
}

class JobDetailPage extends StatefulWidget {
  final int jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _hasApplied = false;
  bool _isCheckingApplication = true;
  bool _isApplying = false;
  bool _awaitingCompletionCheck = false;

  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(FetchJobDetailsEvent(widget.jobId));
    _loadApplicationStatus();
  }

  void _loadApplicationStatus() {
    final user = locator<CareersUserService>().getCurrentCareersUser();
    final candId = int.tryParse(user?.id ?? '');
    if (candId == null) {
      setState(() => _isCheckingApplication = false);
      return;
    }

    context.read<ApplicationBloc>().add(
      CheckApplicationEvent(jobId: widget.jobId, candId: candId),
    );
  }

  int? get _candId {
    final user = locator<CareersUserService>().getCurrentCareersUser();
    return int.tryParse(user?.id ?? '');
  }

  void _startApplyFlow() {
    final candId = _candId;
    if (candId == null) return;

    setState(() => _awaitingCompletionCheck = true);
    context.read<CareersProfileBloc>().add(const CheckProfileCompletionEvent());
  }

  Future<void> _showApplyDialog(JobModel job) async {
    final candId = _candId;
    if (candId == null) return;

    final coverLetter = await ApplyDialog.show(context, job: job);

    if (!mounted || coverLetter == null) return;

    setState(() => _isApplying = true);
    context.read<ApplicationBloc>().add(
      ApplyJobEvent(
        jobId: widget.jobId,
        candId: candId,
        coverLetter: coverLetter.isEmpty ? null : coverLetter,
      ),
    );
  }

  void _leaveJobDetail(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(Routes.careers.name);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.goNamed(Routes.careers.name);
      },
      child: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ApplicationBloc, ApplicationState>(
          listener: (context, state) {
            if (state is JobApplyChecked) {
              setState(() {
                _hasApplied = state.response.hasApplied;
                _isCheckingApplication = false;
              });
            } else if (state is JobApplyCheckError) {
              setState(() => _isCheckingApplication = false);
            } else if (state is JobApplySubmitting) {
              setState(() => _isApplying = true);
            } else if (state is JobApplySuccess) {
              setState(() {
                _hasApplied = true;
                _isApplying = false;
              });
              showToast('Application submitted successfully.');
            } else if (state is JobApplyError) {
              setState(() => _isApplying = false);
              if (state.missingFields.isNotEmpty) {
                showToast(
                  'Profile incomplete: ${state.missingFields.join(', ')}',
                );
                context.pushNamed(Routes.careersCompleteProfile.name);
              } else {
                showToast(state.message);
              }
            }
          },
        ),
        BlocListener<CareersProfileBloc, CareersProfileState>(
          listener: (context, state) {
            if (!_awaitingCompletionCheck) return;

            if (state is ProfileCompletionLoaded) {
              setState(() => _awaitingCompletionCheck = false);
              final completion = state.completion;

              if (!ProfileCompletionHelper.canApplyForJobs(completion)) {
                showToast(
                  'Complete your profile (${completion.percentage}% / ${completion.requiredPercentage}% required) before applying.',
                );
                context.pushNamed(Routes.careersCompleteProfile.name);
                return;
              }

              final jobsState = context.read<JobsBloc>().state;
              if (jobsState is JobDetailsLoaded) {
                _showApplyDialog(jobsState.job);
              }
            } else if (state is ProfileCompletionError) {
              setState(() => _awaitingCompletionCheck = false);
              showToast(state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          final job = state is JobDetailsLoaded ? state.job : null;

          return CareersScaffold(
            title: 'Job Details',
            leading: BackButton(onPressed: () => _leaveJobDetail(context)),
            bottomNavigationBar: job == null
                ? null
                : ApplyBottomBar(
                    job: job,
                    hasApplied: _hasApplied,
                    isLoading: _isCheckingApplication || _isApplying,
                    onApply: _startApplyFlow,
                  ),
            body: _buildBody(state, job),
          );
        },
      ),
    );
  }

  Widget _buildBody(JobsState state, JobModel? job) {
    if (state is JobDetailsError) {
      final retry = () {
        context.read<JobsBloc>().add(FetchJobDetailsEvent(widget.jobId));
      };
      final offline = _isConnectionProblem(state.message);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CareersSpacing.screenH),
          child: offline
              ? AppErrorState.network(
                  title: 'Unable to load this job',
                  message: 'Please check your connection and try again.',
                  onRetry: retry,
                )
              : AppErrorState.notFound(
                  title: 'This job is unavailable',
                  message:
                      'It may have expired or been removed. Go back to browse other jobs.',
                  retryLabel: 'Try again',
                  onRetry: retry,
                ),
        ),
      );
    }

    if (job != null) return _buildJobDetailContent(job);

    return const _JobDetailSkeleton();
  }

  Widget _buildJobDetailContent(JobModel job) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        CareersSpacing.screenH,
        CareersSpacing.cardPadding,
        CareersSpacing.screenH,
        CareersSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JobHeaderCard(job: job),
          CareersSpacing.gap16,
          JobInfoCard(job: job),
          if (job.description.isNotEmpty) ...[
            CareersSpacing.gap16,
            JobDescriptionCard(job: job),
          ],
          if (job.requirements?.isNotEmpty ?? false) ...[
            CareersSpacing.gap16,
            JobRequirementsCard(job: job),
          ],
          CareersSpacing.gap16,
          CompanyCard(job: job),
        ],
      ),
    );
  }
}

class _JobDetailSkeleton extends StatelessWidget {
  const _JobDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CareersSpacing.screenH,
        CareersSpacing.cardPadding,
        CareersSpacing.screenH,
        CareersSpacing.section,
      ),
      child: Shimmer.fromColors(
        baseColor: context.careers.surfaceMuted,
        highlightColor: context.careers.surface,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SkeletonBlock(height: 210, radius: CareersRadius.hero),
            CareersSpacing.gap16,
            _SkeletonBlock(height: 190, radius: CareersRadius.card),
            CareersSpacing.gap16,
            _SkeletonBlock(height: 150, radius: CareersRadius.card),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double radius;

  const _SkeletonBlock({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.careers.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
