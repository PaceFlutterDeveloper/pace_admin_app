import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final String candidateId;
  final VoidCallback? onNavigateToCompleteProfile;
  final VoidCallback? onNavigateToJobs;

  const ProfileCompletionWidget({
    Key? key,
    required this.candidateId,
    this.onNavigateToCompleteProfile,
    this.onNavigateToJobs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is ProfileCompletionSuccess) {
          final profileCompletion = state.profileCompletion;

          if (ProfileCompletionHelper.shouldNavigateToCompleteProfile(
              profileCompletion)) {
            // Navigate to complete profile page
            onNavigateToCompleteProfile?.call();
          } else {
            // Profile is complete and user can apply
            onNavigateToJobs?.call();
          }
        } else if (state is ProfileCompletionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking profile: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is ProfileCompletionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ProfileCompletionSuccess) {
            final profileCompletion = state.profileCompletion;

            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Progress indicator
                    LinearProgressIndicator(
                      value: profileCompletion.percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        profileCompletion.isComplete
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profileCompletion.percentage}% Complete',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 16),

                    // Status message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: profileCompletion.isComplete &&
                                profileCompletion.canApply
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: profileCompletion.isComplete &&
                                  profileCompletion.canApply
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            profileCompletion.isComplete &&
                                    profileCompletion.canApply
                                ? Icons.check_circle
                                : Icons.warning,
                            color: profileCompletion.isComplete &&
                                    profileCompletion.canApply
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ProfileCompletionHelper
                                  .getProfileCompletionMessage(
                                      profileCompletion),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        if (!profileCompletion.isComplete ||
                            !profileCompletion.canApply)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onNavigateToCompleteProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Complete Profile'),
                            ),
                          ),
                        if (profileCompletion.isComplete &&
                            profileCompletion.canApply) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onNavigateToJobs,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Browse Jobs'),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Missing fields (if any)
                    if (profileCompletion.missingFields.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Missing Information:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: profileCompletion.missingFields.map((field) {
                          return Chip(
                            label: Text(
                              field.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.red[50],
                            side: BorderSide(color: Colors.red[300]!),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Example usage widget that shows how to use the profile completion check
class ProfileCompletionExample extends StatefulWidget {
  const ProfileCompletionExample({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionExample> createState() =>
      _ProfileCompletionExampleState();
}

class _ProfileCompletionExampleState extends State<ProfileCompletionExample> {
  final String candidateId = '1'; // Replace with actual candidate ID

  @override
  void initState() {
    super.initState();
    // Trigger profile completion check when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<UserBloc>()
          .add(CheckProfileCompletionEvent(candidateId: candidateId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Completion Check'),
      ),
      body: ProfileCompletionWidget(
        candidateId: candidateId,
        onNavigateToCompleteProfile: () {
          // Navigate to complete profile page
          Navigator.pushNamed(context, '/complete-profile');
        },
        onNavigateToJobs: () {
          // Navigate to jobs page
          Navigator.pushNamed(context, '/jobs');
        },
      ),
    );
  }
}
