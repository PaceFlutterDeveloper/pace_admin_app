import 'package:admin_app/UI/public/application/bloc/application_bloc.dart';
import 'package:admin_app/UI/public/application/bloc/application_events.dart';
import 'package:admin_app/UI/public/application/bloc/application_states.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/components/index.dart';
import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_helper.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  Widget build(BuildContext context) {
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(CareersSpacing.screenH),
          child: AppErrorState.generic(
            title: 'Unable to load this job',
            message: 'Please check your connection and try again.',
            onRetry: () {
              context.read<JobsBloc>().add(FetchJobDetailsEvent(widget.jobId));
            },
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
        baseColor: CareersColors.surfaceMuted,
        highlightColor: CareersColors.surface,
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
        color: CareersColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
