import 'package:admin_app/careers/jobs/components/shared/info_row.dart';
import 'package:admin_app/careers/jobs/components/shared/section_card.dart';
import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/careers/user/models/profile_data_models.dart';
import 'package:flutter/cupertino.dart';

/// Personal information card driven by the API profile.
class ProfileInfoCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRowData>[
      _InfoRowData(CupertinoIcons.person, 'Full name', profile.name),
      _InfoRowData(CupertinoIcons.mail, 'Email', profile.email),
      _InfoRowData(CupertinoIcons.phone, 'Phone number', profile.phone),
      _InfoRowData(
        CupertinoIcons.location,
        'Current location',
        profile.currentLocation,
      ),
      _InfoRowData(
        CupertinoIcons.briefcase,
        'Preferred position',
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

    return SectionCard(
      title: 'Personal information',
      icon: CupertinoIcons.person_crop_circle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) CareersSpacing.gap16,
            InfoRow(
              label: rows[i].label,
              value: rows[i].displayValue,
              icon: rows[i].icon,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRowData(this.icon, this.label, this.value);

  String get displayValue =>
      (value?.isNotEmpty ?? false) ? value! : 'Not provided';
}
