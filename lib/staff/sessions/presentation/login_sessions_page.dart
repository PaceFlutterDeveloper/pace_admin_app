import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/session/device_snapshot.dart';
import 'package:admin_app/staff/sessions/domain/login_session.dart';
import 'package:admin_app/staff/sessions/domain/login_sessions_repository.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Profile > Where have you logged in. Phones that have signed in, like
/// Instagram's login activity.
class LoginSessionsPage extends StatefulWidget {
  const LoginSessionsPage({super.key});

  @override
  State<LoginSessionsPage> createState() => _LoginSessionsPageState();
}

class _LoginSessionsPageState extends State<LoginSessionsPage> {
  late final LoginSessionsRepository _repository =
      locator<LoginSessionsRepository>();
  late final LoadCubit<LoginActivity> _cubit = LoadCubit(_load)..load();

  /// Session id being signed out, or `*` for every other device.
  String? _busy;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<LoginActivity> _load() async {
    final sessions = await _repository.load();
    return groupLoginSessions(sessions, deviceId: _thisDeviceId());
  }

  String _thisDeviceId() {
    try {
      return staffDeviceId();
    } catch (_) {
      return '';
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (context) {
        final p = context.staff;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
              child: Text(action),
            ),
          ],
        );
      },
    );
    return answer == true;
  }

  Future<void> _revoke(LoginSession session) async {
    if (_busy != null || session.id.isEmpty) return;
    final name = sessionTitle(session);
    final confirmed = await _confirm(
      title: 'Log out',
      message: 'Log out $name? That phone will need to sign in again.',
      action: 'Log out',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = session.id);
    try {
      await _repository.revoke(session.id);
      await _cubit.load(quiet: true);
      if (!mounted) return;
      AppToast.success(context, 'Signed out $name');
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, staffErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _revokeOthers() async {
    if (_busy != null) return;
    final confirmed = await _confirm(
      title: 'Log out other devices',
      message:
          'Other phones will need to sign in again. This phone stays signed in.',
      action: 'Log out',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = '*');
    try {
      await _repository.revokeOthers();
      await _cubit.load(quiet: true);
      if (!mounted) return;
      AppToast.success(context, 'Signed out of other devices');
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, staffErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: StaffPage(
        child: Column(
          children: [
            const StaffPageHeader(
              title: 'Where have you logged in',
              subtitle: 'Devices signed in to your account',
            ),
            Expanded(
              child: StaffLoadView<LoginActivity>(
                errorGlyph: StaffGlyphs.phone,
                errorTitle: 'Could not load devices',
                builder: (context, activity) {
                  if (activity.isEmpty) {
                    return const StaffEmptyList(
                      glyph: StaffGlyphs.phone,
                      title: 'No devices yet',
                      message:
                          'Phones that sign in to your account will show up here.',
                    );
                  }
                  final now = DateTime.now();
                  final othersCanLeave = activity.others.any(
                    (session) => session.id.isNotEmpty,
                  );
                  return ListView(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [
                      if (activity.here.isNotEmpty) ...[
                        const SectionLabel(
                          'THIS PHONE',
                          padding: EdgeInsets.fromLTRB(6, 8, 6, 8),
                        ),
                        for (final session in activity.here)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SessionCard(
                              session: session,
                              here: true,
                              now: now,
                            ),
                          ),
                      ],
                      if (activity.others.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                          child: Text(
                            "You're only signed in on this phone.",
                            style: sora(12.5, color: context.staff.muted),
                          ),
                        )
                      else ...[
                        const SectionLabel(
                          'OTHER DEVICES',
                          padding: EdgeInsets.fromLTRB(6, 8, 6, 8),
                        ),
                        for (final session in activity.others)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SessionCard(
                              session: session,
                              here: false,
                              now: now,
                              busy: _busy == session.id,
                              enabled: _busy == null,
                              onLogout: () => _revoke(session),
                            ),
                          ),
                        if (othersCanLeave) ...[
                          const SizedBox(height: 6),
                          _LogoutOthersButton(
                            busy: _busy == '*',
                            enabled: _busy == null,
                            singular: activity.others.length == 1,
                            onPressed: _revokeOthers,
                          ),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.here,
    required this.now,
    this.busy = false,
    this.enabled = true,
    this.onLogout,
  });

  final LoginSession session;
  final bool here;
  final DateTime now;
  final bool busy;
  final bool enabled;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final detail = sessionDetail(session, now: now, here: here);
    final canLogout = !here && onLogout != null && session.id.isNotEmpty;
    return StaffCard(
      radius: 20,
      padding: EdgeInsets.fromLTRB(14, 12, 14, canLogout ? 4 : 12),
      child: Column(
        children: [
          Row(
            children: [
              GlassIconTile(
                glyph: StaffGlyphs.phone,
                accent: here ? StaffAccent.amber : StaffAccent.blue,
                size: 40,
                radius: 14,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionTitle(session),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(14, weight: FontWeight.w700, color: p.text),
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 2,
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
            ],
          ),
          if (canLogout)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 52),
                child: TextButton(
                  onPressed: enabled ? onLogout : null,
                  style: TextButton.styleFrom(
                    foregroundColor: p.dangerText,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: busy
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: p.dangerText,
                          ),
                        )
                      : Text(
                          'Log out',
                          style: sora(
                            13,
                            weight: FontWeight.w700,
                            color: enabled ? p.dangerText : p.muted,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoutOthersButton extends StatelessWidget {
  const _LogoutOthersButton({
    required this.onPressed,
    required this.busy,
    required this.enabled,
    required this.singular,
  });

  final VoidCallback onPressed;
  final bool busy;
  final bool enabled;
  final bool singular;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: p.danger, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: busy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: p.dangerText,
                ),
              )
            : Text(
                singular
                    ? 'Log out of the other device'
                    : 'Log out of other devices',
                style: sora(13.5, weight: FontWeight.w700, color: p.dangerText),
              ),
      ),
    );
  }
}
