import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/components/index.dart';
import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_helper.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(FetchJobDetailsEvent(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    return CareersScaffold(
      title: 'Job Details',
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobDetailsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (state is JobDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppErrorState.generic(
                  title: 'Error loading job details',
                  message: state.message,
                  onRetry: () {
                    context.read<JobsBloc>().add(
                      FetchJobDetailsEvent(widget.jobId),
                    );
                  },
                ),
              ),
            );
          }

          if (state is JobDetailsLoaded) {
            return _buildJobDetailContent(state.job);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildJobDetailContent(JobModel job) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JobHeaderCard(job: job),
          const SizedBox(height: AppSpacing.md),
          JobInfoCard(job: job),
          const SizedBox(height: AppSpacing.md),
          if (job.description.isNotEmpty) ...[
            JobDescriptionCard(job: job),
            const SizedBox(height: AppSpacing.md),
          ],
          if (job.requirements?.isNotEmpty ?? false) ...[
            JobRequirementsCard(job: job),
            const SizedBox(height: AppSpacing.md),
          ],
          CompanyCard(job: job),
          const SizedBox(height: AppSpacing.md),
          BlocListener<CareersProfileBloc, CareersProfileState>(
            listener: (context, state) {
              if (state is ProfileCompletionLoaded) {
                final completion = state.completion;
                if (ProfileCompletionHelper.isProfileComplete(completion) &&
                    ProfileCompletionHelper.canApplyForJobs(completion)) {
                  showToast(
                    'Your profile is complete and you can apply for jobs.',
                  );
                } else {
                  showToast(
                    'Your profile is incomplete and you cannot apply for jobs.',
                  );
                }
              } else if (state is ProfileCompletionError) {
                showToast(state.message);
              }
            },
            child: ApplyButton(
              job: job,
              onApply: () {
                context.read<CareersProfileBloc>().add(
                  const CheckProfileCompletionEvent(),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
