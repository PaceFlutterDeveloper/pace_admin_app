import 'package:admin_app/staff/directory/domain/directory_repository.dart';
import 'package:admin_app/staff/directory/domain/staff_member.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_avatar.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showStaffMemberSheet(
  BuildContext context,
  DirectoryRepository repository,
  StaffMember member,
) {
  return showStaffSheet<void>(
    context,
    title: member.name,
    builder: (_) => _MemberDetail(repository: repository, member: member),
  );
}

class _MemberDetail extends StatefulWidget {
  const _MemberDetail({required this.repository, required this.member});

  final DirectoryRepository repository;
  final StaffMember member;

  @override
  State<_MemberDetail> createState() => _MemberDetailState();
}

class _MemberDetailState extends State<_MemberDetail> {
  late StaffMember _member = widget.member;

  @override
  void initState() {
    super.initState();
    widget.repository
        .detail(widget.member.id)
        .then((full) {
          if (mounted) setState(() => _member = full);
        })
        .catchError((_) {});
  }

  String get _today {
    switch (_member.todayStatus.toLowerCase().replaceAll('_', ' ')) {
      case 'present':
        return 'Present today';
      case 'absent':
        return 'Absent today';
      case 'late':
        return 'Late today';
      case 'on leave':
      case 'leave':
        return 'On leave today';
      case 'not marked':
        return 'Not marked yet';
      default:
        return '';
    }
  }

  Future<void> _open(String scheme, String value) async {
    await launchUrl(Uri(scheme: scheme, path: value));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final m = _member;
    final line = [
      m.designation,
      m.department,
    ].where((e) => e.isNotEmpty).join(' · ');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StaffAvatar(name: m.name, photo: m.photo, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  line,
                  style: sora(13, weight: FontWeight.w500, color: p.muted),
                ),
              ),
            ],
          ),
          if (_today.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              [
                _today,
                if (m.checkIn.isNotEmpty) 'in ${m.checkIn}',
                if (m.checkOut.isNotEmpty) 'out ${m.checkOut}',
              ].join(' · '),
              style: sora(12.5, weight: FontWeight.w600, color: p.amberText),
            ),
          ],
          const SizedBox(height: 18),
          if (m.phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AmberButton(
                label: 'Call ${m.phone}',
                glyph: StaffGlyphs.user,
                onPressed: () => _open('tel', m.phone),
              ),
            ),
          if (m.email.isNotEmpty)
            AmberButton(
              label: m.email,
              soft: true,
              glyph: StaffGlyphs.inbox,
              onPressed: () => _open('mailto', m.email),
            ),
          if (m.phone.isEmpty && m.email.isEmpty)
            Text(
              'No contact details are shared for this person.',
              style: sora(12.5, color: p.muted),
            ),
        ],
      ),
    );
  }
}
