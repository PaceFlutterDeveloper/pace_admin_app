import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/services/authentication_service.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/profile/personal_details.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_avatar.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Saved staff profiles. Picking one continues as that person. Sign out of
/// the last profile, or Sign out all, returns to the login screen.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final AuthenticationService _auth = locator<AuthenticationService>();
  final _users = locator<Box<AuthModel>>().listenable();
  bool _busy = false;
  bool _signingOutAll = false;

  Future<void> _switchTo(AuthModel user) async {
    if (_busy || user.isActive) return;
    setState(() => _busy = true);
    try {
      await locator<AuthCubit>().switchUser(
        userName: user.userName,
        schoolCode: user.schoolCode,
        userId: user.userId,
      );
      if (!mounted) return;
      context.go(Routes.home.path);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addAccount() async {
    if (_busy) return;
    final ok = await _auth.authenticate();
    if (!ok) return;
    secretAdminLoginOpen.value = true;
  }

  Future<void> _signOutAll() async {
    if (_busy) return;
    final count = locator<Box<AuthModel>>().length;
    if (count == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final p = context.staff;
        final profiles = count == 1 ? 'this profile' : 'all $count profiles';
        return AlertDialog(
          title: const Text('Sign out all'),
          content: Text(
            'Sign out $profiles on this phone and return to the login page?',
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
              child: const Text('Sign out all'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _signingOutAll = true;
    });
    try {
      await locator<AuthCubit>().logoutAll();
      if (!mounted) return;
      context.go(Routes.careers.path);
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Could not sign out. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _signingOutAll = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return StaffPage(
      child: ValueListenableBuilder<Box<AuthModel>>(
        valueListenable: _users,
        builder: (context, box, _) {
          final users = box.values.toList()..sort(_byProfile);
          final hasActive = users.any((user) => user.isActive);

          return Column(
            children: [
              StaffPageHeader(
                title: 'Switch profile',
                subtitle: hasActive
                    ? 'Saved on this phone'
                    : 'Choose who to continue as',
                showBack: hasActive,
              ),
              if (_busy)
                const LinearProgressIndicator(minHeight: 2)
              else
                const SizedBox(height: 2),
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'No profiles on this phone',
                            textAlign: TextAlign.center,
                            style: sora(
                              14,
                              weight: FontWeight.w500,
                              color: p.muted,
                            ),
                          ),
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 12),
                        children: [
                          const SectionLabel('PROFILES'),
                          StaffCard(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            radius: 24,
                            child: Column(
                              children: [
                                for (var i = 0; i < users.length; i++) ...[
                                  _ProfileRow(
                                    user: users[i],
                                    enabled: !_busy,
                                    onTap: () => _switchTo(users[i]),
                                  ),
                                  if (i != users.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 74,
                                      endIndent: 14,
                                      color: p.border,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
                child: Column(
                  children: [
                    AmberButton(
                      label: 'Add account',
                      glyph: StaffGlyphs.plus,
                      onPressed: _busy ? null : _addAccount,
                    ),
                    if (users.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _SignOutAllButton(
                        loading: _signingOutAll,
                        onPressed: _busy ? null : _signOutAll,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

int _byProfile(AuthModel a, AuthModel b) {
  if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
  return _profileName(a).toLowerCase().compareTo(_profileName(b).toLowerCase());
}

String _profileName(AuthModel user) {
  final name = user.name.trim();
  if (name.isNotEmpty) return staffDisplayText(name);
  final handle = user.userName.trim();
  return handle.isEmpty ? 'Staff member' : handle;
}

String _profileDetail(AuthModel user) {
  final role = staffDisplayText(user.designation.trim());
  final schoolName = user.schoolName.trim();
  final school = schoolName.isNotEmpty
      ? staffDisplayText(schoolName)
      : user.schoolCode.trim();
  return [if (role.isNotEmpty) role, if (school.isNotEmpty) school].join(' · ');
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.user,
    required this.enabled,
    required this.onTap,
  });

  final AuthModel user;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final name = _profileName(user);
    final detail = _profileDetail(user);
    final current = user.isActive;

    return Semantics(
      button: !current,
      label: current ? '$name, current profile' : 'Continue as $name',
      child: ColoredBox(
        color: current
            ? p.amber.withValues(alpha: p.isDark ? 0.10 : 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: !enabled || current ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _Avatar(
                    name: name,
                    photo: user.profilePicture,
                    count: user.notificationCount,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sora(
                            14.5,
                            weight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        if (detail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sora(
                              12,
                              weight: FontWeight.w400,
                              color: p.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (current)
                    Text(
                      'Current',
                      style: sora(
                        12,
                        weight: FontWeight.w700,
                        color: p.amberText,
                      ),
                    )
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
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.photo, required this.count});

  final String name;
  final String photo;
  final int count;

  @override
  Widget build(BuildContext context) {
    final avatar = StaffAvatar(name: name, photo: photo, size: 46);
    if (count <= 0) return avatar;
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(top: -4, right: -6, child: StaffCountBadge(count)),
        ],
      ),
    );
  }
}

class _SignOutAllButton extends StatelessWidget {
  const _SignOutAllButton({required this.onPressed, required this.loading});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final enabled = onPressed != null && !loading;
    final color = enabled || loading ? p.dangerText : p.muted;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : StaffIcon(
                StaffGlyphs.logout,
                size: 18,
                color: color,
                strokeWidth: 2,
              ),
        label: Text(
          'Sign out all',
          style: sora(14.5, weight: FontWeight.w700, color: color),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: enabled || loading ? p.danger : p.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
