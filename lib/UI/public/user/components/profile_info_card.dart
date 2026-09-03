import 'package:admin_app/UI/public/user/components/shared/profile_card.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Personal information card driven by the API profile.
class ProfileInfoCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRowData>[
      _InfoRowData(CupertinoIcons.person, 'Full Name', profile.name),
      _InfoRowData(CupertinoIcons.mail, 'Email', profile.email),
      _InfoRowData(CupertinoIcons.phone, 'Phone Number', profile.phone),
      _InfoRowData(
        CupertinoIcons.location,
        'Current Location',
        profile.currentLocation,
      ),
      _InfoRowData(
        CupertinoIcons.briefcase,
        'Preferred Position',
        profile.preferredPosition,
      ),
      _InfoRowData(
        CupertinoIcons.time,
        'Experience',
        profile.experienceYears != null
            ? '${profile.experienceYears} years'
            : null,
      ),
    ];

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
              letterSpacing: -0.3,
            ),
          ),
          AppSpacing.vGapLg,
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) AppSpacing.vGapMd,
            _buildInfoRow(context, rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, _InfoRowData row) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          row.icon,
          size: AppSizes.iconXs + 2,
          color: theme.colorScheme.primary,
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              AppSpacing.vGapXs,
              Text(
                (row.value?.isNotEmpty ?? false) ? row.value! : 'Not provided',
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

class _InfoRowData {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRowData(this.icon, this.label, this.value);
}
