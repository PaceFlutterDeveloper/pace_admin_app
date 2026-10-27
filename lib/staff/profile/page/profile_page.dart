import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/attendance_calendar/cubit/attendance_cubit.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/home/pages/staff_coming_soon_page.dart';
import 'package:admin_app/staff/home/utils/active_staff_user.dart';
import 'package:admin_app/staff/home/utils/home_attendance_summary.dart';
import 'package:admin_app/staff/profile/components/appearance_toggle.dart';
import 'package:admin_app/staff/profile/components/profile_sheets.dart';
import 'package:admin_app/staff/profile/cubit/profile_cubit.dart';
import 'package:admin_app/staff/profile/model/profile_data_model.dart';
import 'package:admin_app/staff/profile/personal_details.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Profile tab: identity hero, account and preference groups, sign out.
class ProfilePage extends StatefulWidget {
  final String appTitle;
  const ProfilePage({super.key, required this.appTitle});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    if (!cubit.isFresh) cubit.getEmpProfile(quiet: true);
    final dashboard = locator<DashboardCubit>();
    if (!dashboard.isFresh) dashboard.load();
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    final others = locator<Box<AuthModel>>().values.any(
      (user) => !user.isActive,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final p = context.staff;
        return AlertDialog(
          title: const Text('Sign out'),
          content: Text(
            others
                ? 'Sign out of this profile? Other profiles on this phone stay available, and you can continue as one of them.'
                : 'Are you sure you want to sign out?',
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: p.muted),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: p.dangerText),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() => _signingOut = true);
    try {
      final othersRemain = await locator<AuthCubit>().logout();
      if (!mounted) return;
      context.go(othersRemain ? Routes.usersPage.path : Routes.careers.path);
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final canPop = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final data = state.maybeWhen(success: (d) => d, orElse: () => null);
          final failed = state.maybeWhen(error: (m) => m, orElse: () => null);

          return RefreshIndicator(
            color: p.amberText,
            backgroundColor: p.surface,
            onRefresh: () =>
                context.read<ProfileCubit>().getEmpProfile(quiet: true),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: SizedBox(
                    height: 46,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (canPop)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: StaffIconButton(
                              glyph: StaffGlyphs.chevronLeft,
                              semanticLabel: 'Back',
                              onTap: () => context.pop(),
                            ),
                          ),
                        Text(
                          'Profile',
                          style: sora(
                            17,
                            weight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _ProfileHero(data: data),
                SectionLabel(
                  'ACCOUNT',
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                ),
                _Group(
                  children: [
                    _SettingsRow(
                      glyph: StaffGlyphs.user,
                      accent: StaffAccent.blue,
                      label: 'Personal information',
                      loading: data == null && failed == null,
                      onTap: data == null
                          ? () => _needsProfile(failed)
                          : () => showPersonalInfoSheet(context, data),
                    ),
                    _SettingsRow(
                      glyph: StaffGlyphs.doc,
                      accent: StaffAccent.pink,
                      label: 'Documents',
                      alert: (data?.documentStatus ?? 0) != 0,
                      loading: data == null && failed == null,
                      onTap: data == null
                          ? () => _needsProfile(failed)
                          : () => showDocumentsSheet(context, data),
                    ),
                    _SettingsRow(
                      glyph: StaffGlyphs.lock,
                      accent: StaffAccent.violet,
                      label: 'Change password',
                      onTap: () => context.push(Routes.updatePassword.path),
                    ),
                    _SettingsRow(
                      glyph: StaffGlyphs.bell,
                      accent: StaffAccent.amber,
                      label: 'Notification settings',
                      onTap: () =>
                          context.pushNamed(Routes.notificationSettings.name),
                    ),
                    _SettingsRow(
                      glyph: StaffGlyphs.swap,
                      accent: StaffAccent.green,
                      label: 'Switch profile',
                      onTap: () => context.push(Routes.usersPage.path),
                    ),
                  ],
                ),
                SectionLabel(
                  'PREFERENCES',
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                ),
                _Group(
                  children: [
                    _SettingsRow(
                      glyph: StaffGlyphs.globe,
                      accent: StaffAccent.green,
                      label: 'Language',
                      value: 'English',
                      onTap: () =>
                          openComingSoon(context, ComingSoonArgs.language),
                    ),
                    const _SettingsRow(
                      glyph: StaffGlyphs.moon,
                      accent: StaffAccent.pink,
                      label: 'Appearance',
                      trailing: AppearanceToggle(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _SignOutButton(
                    onPressed: _signOut,
                    loading: _signingOut,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _needsProfile(String? failed) {
    if (failed != null) {
      context.read<ProfileCubit>().getEmpProfile();
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.data});

  final ProfileDataModel? data;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<AuthModel>>(
      valueListenable: staffSessionListenable(),
      builder: (context, box, _) {
        final user = activeStaffUser();
        final rawName = (data?.user.name.trim().isNotEmpty ?? false)
            ? data!.user.name.trim()
            : ((data?.emp?.emplName.trim().isNotEmpty ?? false)
                  ? data!.emp!.emplName.trim()
                  : user.name.trim());
        final name = staffDisplayText(rawName);
        final designation = staffDisplayText(
          (data?.emp?.designation.trim().isNotEmpty ?? false)
              ? data!.emp!.designation.trim()
              : user.designation.trim(),
        );
        final department = staffDisplayText(data?.emp?.department.trim() ?? '');
        final school = user.schoolName.trim().isNotEmpty
            ? user.schoolName.trim()
            : staffDisplayText(data?.schoolName ?? '');
        final subtitle = [
          if (designation.isNotEmpty) designation,
          if (department.isNotEmpty) department,
          if (school.isNotEmpty) school,
        ].join(' · ');
        final photo = profilePhotoUrl(
          rootPhoto: data?.photo ?? '',
          userPhoto: data?.user.photo,
          sessionPhoto: user.profilePicture,
        );

        final p = context.staff;
        final titleColor = p.heroTitle;
        final subColor = p.heroSubtle;

        return HeroSurface(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            children: [
              _Avatar(name: name, photoUrl: photo),
              const SizedBox(height: 14),
              Text(
                name.isEmpty ? 'Staff member' : name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: sora(
                  22,
                  weight: FontWeight.w700,
                  color: titleColor,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: sora(12.5, weight: FontWeight.w400, color: subColor),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<DashboardCubit, StaffDashboard?>(
                      bloc: locator<DashboardCubit>(),
                      builder: (context, dashboard) {
                        final server = dashboard?.attendance;
                        if (server != null) {
                          return HeroStat(
                            value: '${server.percentage.round()}%',
                            label: 'Attendance',
                          );
                        }
                        return BlocBuilder<AttendanceCubit, AttendanceState>(
                          builder: (context, s) {
                            final pct = s.maybeWhen(
                              loadingSuccess: (list) =>
                                  '${buildAttendanceDashboardSummaries(list, DateTime.now()).month.percentage.round()}%',
                              orElse: () => '-',
                            );
                            return HeroStat(value: pct, label: 'Attendance');
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BlocBuilder<DashboardCubit, StaffDashboard?>(
                      bloc: locator<DashboardCubit>(),
                      builder: (context, dashboard) => HeroStat(
                        value: dashboard?.openTickets == null
                            ? '-'
                            : '${dashboard!.openTickets}',
                        label: 'Open tickets',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: HeroStat(
                      value: data == null ? '-' : '${data!.doc.length}',
                      label: 'Documents',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.photoUrl});

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? 'S' : name.characters.first.toUpperCase();
    final fallback = Center(
      child: Text(
        initial,
        style: sora(
          34,
          weight: FontWeight.w800,
          color: StaffPalette.onAmberInk,
        ),
      ),
    );

    final p = context.staff;
    final gap = p.isDark ? const Color(0xFF171B23) : p.surface;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: StaffPalette.fabGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: StaffPalette.dark.amber.withValues(
              alpha: p.isDark ? 0.35 : 0.45,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: gap,
          borderRadius: BorderRadius.circular(29),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(gradient: StaffPalette.fabGradient),
            child: photoUrl.isEmpty
                ? fallback
                : Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => fallback,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, indent: 14, endIndent: 14, color: p.border),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.glyph,
    required this.accent,
    required this.label,
    this.onTap,
    this.value,
    this.trailing,
    this.alert = false,
    this.loading = false,
  });

  final String glyph;
  final StaffAccent accent;
  final String label;
  final VoidCallback? onTap;
  final String? value;
  final Widget? trailing;
  final bool alert;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              GlassIconTile(
                glyph: glyph,
                accent: accent,
                size: 34,
                radius: 12,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(13.5, weight: FontWeight.w600, color: p.text),
                ),
              ),
              if (alert)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: p.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value!,
                    style: sora(12, weight: FontWeight.w500, color: p.muted),
                  ),
                ),
              if (loading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: p.muted,
                  ),
                )
              else if (trailing != null)
                trailing!
              else
                StaffIcon(
                  StaffGlyphs.chevronRight,
                  size: 18,
                  color: p.muted,
                  strokeWidth: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed, this.loading = false});

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: p.dangerText,
                ),
              )
            : StaffIcon(
                StaffGlyphs.logout,
                size: 18,
                color: p.dangerText,
                strokeWidth: 2,
              ),
        label: Text(
          'Sign out',
          style: sora(13.5, weight: FontWeight.w700, color: p.dangerText),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: p.danger, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
