import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_events.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_states.dart';
import 'package:admin_app/UI/public/jobs/components/index.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_helper.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;

  const JobDetailPage({
    Key? key,
    required this.jobId,
  }) : super(key: key);

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch job details when page loads
    context.read<JobsBloc>().add(FetchJobDetailsEvent(widget.jobId));
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
          'Job Details',
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.w700,
            color: ConstColors.textDark,
          ),
        ),
        backgroundColor: ConstColors.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: ConstColors.textDark,
          size: w * 0.06,
        ),
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is JobDetailsError) {
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
                    'Error loading job details',
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
                      context
                          .read<JobsBloc>()
                          .add(FetchJobDetailsEvent(widget.jobId));
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

          if (state is JobDetailsLoaded) {
            return _buildJobDetailContent(state.job, w, h);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildJobDetailContent(JobModel job, double w, double h) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JobHeaderCard(job: job),
          SizedBox(height: h * 0.02),
          JobInfoCard(job: job),
          SizedBox(height: h * 0.02),
          if (job.description.isNotEmpty) ...[
            JobDescriptionCard(job: job),
            SizedBox(height: h * 0.02),
          ],
          if (job.requirements?.isNotEmpty ?? false) ...[
            JobRequirementsCard(job: job),
            SizedBox(height: h * 0.02),
          ],
          CompanyCard(job: job),
          SizedBox(height: h * 0.02),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is ProfileCompletionSuccess) {
                final profileCompletion = state.profileCompletion;

                // Check if profile is complete and user can apply
                if (ProfileCompletionHelper.isProfileComplete(
                        profileCompletion) &&
                    ProfileCompletionHelper.canApplyForJobs(
                        profileCompletion)) {
                  // Profile is complete - navigate to jobs or main app
                  showToast(
                      'Your profile is complete and you can apply for jobs.');
                } else {
                  showToast(
                      'Your profile is incomplete and you cannot apply for jobs.');
                  // Profile is incomplete - navigate to complete profile
                  // _showIncompleteDialog(profileCompletion);
                }
              } else if (state is ProfileCompletionError) {
                showToast(state.message);
              }
            },
            child: ApplyButton(
                job: job,
                onApply: () => {
                      context.read<UserBloc>().add(CheckProfileCompletionEvent(
                          candidateId: CareersUserService()
                                  .getCurrentCareersUser()
                                  ?.id ??
                              '')),
                    }),
          ),
          SizedBox(height: h * 0.1),
        ],
      ),
    );
  }

  void _handleApply(JobModel job) {
    ApplyDialog.show(context, job, onApply: () {
      // Handle application submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application submitted for ${job.title}'),
          backgroundColor: ConstColors.primary,
        ),
      );
    });
  }
}
