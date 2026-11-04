import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/session/must_change_password.dart';
import 'package:admin_app/staff/session/staff_session_service.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lowest password length the form accepts before asking the server.
const int staffMinPasswordLength = 8;

/// What is wrong with the three fields, or null when they can be sent.
String? passwordProblem({
  required String current,
  required String next,
  required String confirm,
}) {
  if (current.isEmpty) return 'Enter your current password.';
  if (next.length < staffMinPasswordLength) {
    return 'Use at least $staffMinPasswordLength characters for the new password.';
  }
  if (next == current) return 'Choose a password you have not used here.';
  if (next != confirm) return 'The two new passwords do not match.';
  return null;
}

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = passwordProblem(
      current: _current.text,
      next: _next.text,
      confirm: _confirm.text,
    );
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final locked = mustChangePasswordGate.required;
    try {
      final token = await locator<StaffSessionService>().changePassword(
        current: _current.text,
        next: _next.text,
      );
      await AuthData.updateActiveCredentials(
        password: _next.text,
        token: token,
      );
      // A summary that started before this save can still say the password
      // must change. Drop it so it cannot send the person straight back.
      if (locked || mustChangePasswordGate.required) {
        locator<DashboardCubit>().dropSession();
        mustChangePasswordGate.apply(false);
      }
      if (!mounted) return;
      AppToast.success(context, 'Password updated');
      if (locked) {
        context.go(Routes.home.path);
      } else {
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = staffErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return ListenableBuilder(
      listenable: mustChangePasswordGate,
      builder: (context, _) {
        final locked = mustChangePasswordGate.required;
        return PopScope(
          canPop: !locked,
          child: StaffPage(
            child: Column(
              children: [
                StaffPageHeader(
                  title: locked ? 'Reset password' : 'Change password',
                  subtitle: locked
                      ? 'Your school requires a new password before you continue'
                      : 'Keep your account secure',
                  showBack: !locked,
                ),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      StaffField(
                        label: 'Current password',
                        controller: _current,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      StaffField(
                        label: 'New password',
                        hint: 'At least $staffMinPasswordLength characters',
                        controller: _next,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      StaffField(
                        label: 'Repeat new password',
                        controller: _confirm,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _saving ? null : _save(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _error!,
                          style: sora(
                            12.5,
                            weight: FontWeight.w500,
                            color: p.dangerText,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      AmberButton(
                        label: locked ? 'Save password' : 'Update password',
                        loading: _saving,
                        onPressed: _saving ? null : _save,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
