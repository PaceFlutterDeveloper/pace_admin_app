import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CareersUserManager.getCurrentUser();

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoRow(
            context,
            CupertinoIcons.person,
            'Full Name',
            user?.name ?? '',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            CupertinoIcons.mail,
            'Email',
            user?.email ?? '',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            CupertinoIcons.phone,
            'Phone Number',
            user?.phone ?? 'Not provided',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            CupertinoIcons.location,
            'Preferred Location',
            user?.preferredLocation ?? 'Not specified',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            CupertinoIcons.briefcase,
            'Experience Level',
            user?.experienceLevel ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
