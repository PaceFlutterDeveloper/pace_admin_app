import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/utils/profile_completion_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Example showing how to use the profile completion API call
/// This demonstrates the basic usage pattern for checking profile completion status
class ProfileCompletionUsageExample extends StatefulWidget {
  const ProfileCompletionUsageExample({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionUsageExample> createState() =>
      _ProfileCompletionUsageExampleState();
}

class _ProfileCompletionUsageExampleState
    extends State<ProfileCompletionUsageExample> {
  final String candidateId = '1'; // Replace with actual candidate ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Completion API Usage'),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is ProfileCompletionSuccess) {
            final profileCompletion = state.profileCompletion;

            // Check if profile is complete and user can apply
            if (ProfileCompletionHelper.isProfileComplete(profileCompletion) &&
                ProfileCompletionHelper.canApplyForJobs(profileCompletion)) {
              // Profile is complete - navigate to jobs or main app
              _showSuccessDialog('Profile Complete!',
                  'Your profile is complete and you can apply for jobs.');
            } else {
              // Profile is incomplete - navigate to complete profile
              _showIncompleteDialog(profileCompletion);
            }
          } else if (state is ProfileCompletionError) {
            _showErrorDialog('Error', state.message);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Profile Completion API Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'This example shows how to check if a candidate\'s profile is complete.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Trigger the profile completion check
                  context.read<UserBloc>().add(
                        CheckProfileCompletionEvent(candidateId: candidateId),
                      );
                },
                child: const Text('Check Profile Completion'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is ProfileCompletionLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ProfileCompletionSuccess) {
                    return _buildProfileStatusCard(state.profileCompletion);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatusCard(profileCompletion) {
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

            // Progress bar
            LinearProgressIndicator(
              value: ProfileCompletionHelper.getCompletionPercentage(
                      profileCompletion) /
                  100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                ProfileCompletionHelper.isProfileComplete(profileCompletion)
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${ProfileCompletionHelper.getCompletionPercentage(profileCompletion)}% Complete',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // Status information
            Row(
              children: [
                Icon(
                  ProfileCompletionHelper.isProfileComplete(profileCompletion)
                      ? Icons.check_circle
                      : Icons.warning,
                  color: ProfileCompletionHelper.isProfileComplete(
                          profileCompletion)
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ProfileCompletionHelper.getProfileCompletionMessage(
                        profileCompletion),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Can apply status
            Row(
              children: [
                Icon(
                  ProfileCompletionHelper.canApplyForJobs(profileCompletion)
                      ? Icons.work
                      : Icons.work_off,
                  color:
                      ProfileCompletionHelper.canApplyForJobs(profileCompletion)
                          ? Colors.green
                          : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  ProfileCompletionHelper.canApplyForJobs(profileCompletion)
                      ? 'Can apply for jobs'
                      : 'Cannot apply for jobs',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            // Missing fields
            if (ProfileCompletionHelper.getMissingFields(profileCompletion)
                .isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Missing Fields:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    ProfileCompletionHelper.getMissingFields(profileCompletion)
                        .map((field) => Chip(
                              label: Text(
                                field.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.red[50],
                            ))
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to jobs page or main app
              // Navigator.pushNamed(context, '/jobs');
            },
            child: const Text('Continue to Jobs'),
          ),
        ],
      ),
    );
  }

  void _showIncompleteDialog(profileCompletion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Incomplete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ProfileCompletionHelper.getProfileCompletionMessage(
                profileCompletion)),
            if (ProfileCompletionHelper.getMissingFields(profileCompletion)
                .isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Missing fields:'),
              const SizedBox(height: 8),
              ...ProfileCompletionHelper.getMissingFields(profileCompletion)
                  .map((field) =>
                      Text('• ${field.replaceAll('_', ' ').toUpperCase()}'))
                  .toList(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to complete profile page
              // Navigator.pushNamed(context, '/complete-profile');
            },
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Simple usage example for programmatic access
class ProfileCompletionService {
  final UserBloc userBloc;

  ProfileCompletionService({required this.userBloc});

  /// Check profile completion and return navigation decision
  Future<bool> shouldNavigateToCompleteProfile(String candidateId) async {
    // This is a simplified example - in real usage, you'd handle the async nature properly
    userBloc.add(CheckProfileCompletionEvent(candidateId: candidateId));

    // In a real implementation, you'd wait for the state change
    // and return the appropriate boolean value
    return false; // Placeholder
  }

  /// Get profile completion status
  Future<Map<String, dynamic>?> getProfileCompletionStatus(
      String candidateId) async {
    userBloc.add(CheckProfileCompletionEvent(candidateId: candidateId));

    // In a real implementation, you'd listen to the state changes
    // and return the appropriate data
    return null; // Placeholder
  }
}
