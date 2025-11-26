import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = CareersUserManager.getCurrentUser();

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          const SizedBox(height: 24),
          _buildInfoFields(user),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Text(
      'Personal Information',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoFields(user) {
    return Column(
      children: [
        _buildInfoRow(Icons.person_outlined, 'Full Name', user?.name ?? ''),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? ''),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.phone_outlined, 'Phone Number',
            user?.phone ?? 'Not provided'),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.location_on_outlined, 'Preferred Location',
            user?.preferredLocation ?? 'Not specified'),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.work_outlined, 'Experience Level',
            user?.experienceLevel ?? 'Not specified'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: ConstColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
