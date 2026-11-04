import 'package:admin_app/staff/directory/domain/directory_repository.dart';
import 'package:admin_app/staff/directory/domain/staff_member.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_avatar.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  Future<void> _open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final m = _member;
    final line = [
      m.designation,
      m.department,
    ].where((e) => e.isNotEmpty).join(' · ');
    final relative = m.relative;
    final openSocial = [
      for (final item in m.social)
        if (_socialUri(item) != null) item,
    ];
    final plainSocial = [
      for (final item in m.social)
        if (_socialUri(item) == null) item,
    ];
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
          if (m.empId.isNotEmpty || m.statusLabel.isNotEmpty) ...[
            const _SectionTitle('Details'),
            _DetailCard(
              rows: [
                if (m.empId.isNotEmpty)
                  (label: 'Employee ID', value: m.empId, tone: null),
                if (m.statusLabel.isNotEmpty)
                  (
                    label: 'Status',
                    value: m.statusLabel,
                    tone: m.active ? StaffAccent.green : StaffAccent.pink,
                  ),
              ],
            ),
          ],
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
          if (m.phones.isNotEmpty || m.emails.isNotEmpty) ...[
            const _SectionTitle('Contact'),
            for (final phone in m.phones)
              _ContactRow(
                label: phone.label,
                value: phone.value,
                glyph: StaffGlyphs.phone,
                onTap: () => _open(_phoneUri(phone.value)),
              ),
            for (final email in m.emails)
              _ContactRow(
                label: email.label,
                value: email.value,
                glyph: StaffGlyphs.inbox,
                onTap: () => _open(Uri.parse('mailto:${email.value}')),
              ),
          ],
          if (openSocial.isNotEmpty || plainSocial.isNotEmpty) ...[
            const _SectionTitle('Social'),
            if (openSocial.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in openSocial)
                    _SocialAction(
                      label: _socialLabel(item.medium),
                      icon: item.medium == 'whatsapp'
                          ? FontAwesomeIcons.whatsapp
                          : null,
                      onTap: () => _open(_socialUri(item)!),
                    ),
                ],
              ),
            if (plainSocial.isNotEmpty) ...[
              if (openSocial.isNotEmpty) const SizedBox(height: 8),
              for (final item in plainSocial)
                _ContactRow(
                  label: _socialLabel(item.medium),
                  value: item.value,
                  glyph: StaffGlyphs.globe,
                ),
            ],
          ],
          if (relative != null) ...[
            const _SectionTitle('Relative'),
            if (relative.line.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  relative.line,
                  style: sora(14, weight: FontWeight.w700, color: p.text),
                ),
              ),
            for (final phone in relative.phones)
              _ContactRow(
                label: phone.label,
                value: phone.value,
                glyph: StaffGlyphs.phone,
                onTap: () => _open(_phoneUri(phone.value)),
              ),
          ],
          if (!m.hasContact)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                'No contact details are shared for this person.',
                style: sora(12.5, color: p.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows});

  final List<({String label, String value, StaffAccent? tone})> rows;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: p.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        rows[i].label,
                        style: sora(13, weight: FontWeight.w500, color: p.muted),
                      ),
                    ),
                    Text(
                      rows[i].value,
                      style: sora(
                        13.5,
                        weight: FontWeight.w700,
                        color: rows[i].tone == null
                            ? p.text
                            : p.tint(rows[i].tone!).foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: sora(
          11,
          weight: FontWeight.w700,
          color: context.staff.muted,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.glyph,
    this.onTap,
  });

  final String label;
  final String value;
  final String glyph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: p.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap!();
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                StaffIcon(glyph, size: 18, color: p.amberText),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sora(
                          11,
                          weight: FontWeight.w600,
                          color: p.muted,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        value,
                        style: sora(14, weight: FontWeight.w600, color: p.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialAction extends StatelessWidget {
  const _SocialAction({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final FaIconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Material(
      color: p.amberSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(icon, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: sora(13, weight: FontWeight.w700, color: p.amberText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Uri _phoneUri(String value) {
  final compact = value.replaceAll(RegExp(r'[\s\-()]'), '');
  return Uri.parse('tel:$compact');
}

Uri? _socialUri(StaffSocial social) {
  final value = social.value.trim();
  if (value.isEmpty) return null;
  if (_isLink(value)) return Uri.tryParse(value);
  switch (social.medium) {
    case 'whatsapp':
      final link = _whatsAppLink(value);
      return link == null ? null : Uri.tryParse(link);
    case 'instagram':
      return _profileUri(value, 'https://instagram.com/');
    case 'facebook':
      return _profileUri(value, 'https://facebook.com/');
    case 'linkedin':
      return _linkedInUri(value);
    default:
      return null;
  }
}

String _socialLabel(String medium) {
  switch (medium) {
    case 'whatsapp':
      return 'WhatsApp';
    case 'instagram':
      return 'Instagram';
    case 'facebook':
      return 'Facebook';
    case 'linkedin':
      return 'LinkedIn';
    default:
      if (medium.isEmpty) return 'Link';
      final words = medium.replaceAll('_', ' ').replaceAll('-', ' ');
      return words
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
  }
}

bool _isLink(String value) {
  final lower = value.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

String _handle(String value) {
  var handle = value.trim();
  if (handle.startsWith('@')) handle = handle.substring(1);
  while (handle.startsWith('/')) {
    handle = handle.substring(1);
  }
  return handle;
}

Uri? _profileUri(String value, String prefix) {
  final handle = _handle(value);
  if (handle.isEmpty) return null;
  return Uri.tryParse('$prefix$handle');
}

Uri? _linkedInUri(String value) {
  final handle = _handle(value);
  if (handle.isEmpty) return null;
  if (handle.contains('/')) {
    return Uri.tryParse('https://www.linkedin.com/$handle');
  }
  return Uri.tryParse('https://www.linkedin.com/in/$handle');
}

String? _whatsAppLink(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('0') && digits.length == 10) {
    digits = '971${digits.substring(1)}';
  }
  if (digits.isEmpty) return null;
  return 'https://wa.me/$digits';
}
