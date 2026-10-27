import 'package:admin_app/staff/profile/components/document_section.dart';
import 'package:admin_app/staff/profile/model/profile_data_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> _showStaffSheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  final theme = Theme.of(context);
  final p = StaffPalette.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: p.surface,
    barrierColor: p.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => Theme(
      data: theme,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.94,
        builder: (context, scroll) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: p.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: sora(
                      20,
                      weight: FontWeight.w700,
                      color: p.text,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  children: [child],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final shown = value.trim().isEmpty ? '-' : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: sora(12.5, weight: FontWeight.w500, color: p.muted),
            ),
          ),
          Expanded(
            child: Text(
              shown,
              textAlign: TextAlign.right,
              style: sora(13, weight: FontWeight.w600, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title, padding: const EdgeInsets.fromLTRB(4, 12, 4, 8)),
        StaffCard(
          color: p.surfaceRaised,
          radius: 20,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i != rows.length - 1) Divider(height: 1, color: p.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Personal and emergency details from the staff profile.
Future<void> showPersonalInfoSheet(
  BuildContext context,
  ProfileDataModel data,
) {
  final emp = data.emp;
  final dob = emp?.dob == null
      ? ''
      : DateFormat('d MMM yyyy').format(emp!.dob!);
  return _showStaffSheet(
    context,
    title: 'Personal information',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Group(
          title: 'PRIMARY DETAILS',
          rows: [
            _Row('Name', data.user.name),
            _Row('Employee ID', emp?.empId ?? ''),
            _Row('Designation', emp?.designation ?? data.user.designation),
            _Row('Nationality', emp?.nationality ?? ''),
            _Row('Date of birth', dob),
            _Row(
              'Email',
              emp?.email.isNotEmpty == true ? emp!.email : data.user.email,
            ),
            _Row(
              'Phone',
              emp?.phone1.isNotEmpty == true ? emp!.phone1 : data.user.phone,
            ),
          ],
        ),
        if (emp != null)
          _Group(
            title: 'EMERGENCY CONTACT',
            rows: [
              _Row('Contact name', emp.relName),
              _Row('Phone', emp.relTelMob),
            ],
          ),
      ],
    ),
  );
}

/// Documents with expiry status.
Future<void> showDocumentsSheet(BuildContext context, ProfileDataModel data) {
  return _showStaffSheet(
    context,
    title: 'Documents',
    child: DocumentSection(
      documents: data.doc,
      documentStatus: data.documentStatus,
    ),
  );
}
