import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class ProfileCompletionButton extends StatelessWidget {
  final VoidCallback? onNavigateToCompleteProfile;

  const ProfileCompletionButton({
    Key? key,
    this.onNavigateToCompleteProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isComplete = CareersUserManager.isProfileComplete();

    if (isComplete) {
      return _buildCompleteStatusCard();
    }

    return _buildIncompleteButton(context);
  }

  Widget _buildCompleteStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Complete!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Your profile is complete and you can apply for jobs.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteButton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Incomplete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Complete your profile to apply for jobs.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onNavigateToCompleteProfile?.call(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Complete Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
