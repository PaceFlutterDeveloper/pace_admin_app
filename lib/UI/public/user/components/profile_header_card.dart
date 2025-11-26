import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final VoidCallback? onCompleteProfile;

  const ProfileHeaderCard({
    Key? key,
    this.onCompleteProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          _buildUserInfo(),
          const SizedBox(height: 16),
          _buildProfileStatus(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: ConstColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: 50,
        color: ConstColors.primary,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          CareersUserManager.getDisplayName(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          CareersUserManager.getEmail(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStatus() {
    final isComplete = CareersUserManager.isProfileComplete();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.warning,
            color: isComplete ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isComplete ? 'Profile Complete' : 'Profile Incomplete',
            style: TextStyle(
              color: isComplete ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
