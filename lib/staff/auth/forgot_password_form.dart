import 'package:admin_app/careers/shared/components/careers_auth_scaffold.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/account/components/update_password_page.dart';
import 'package:admin_app/staff/session/staff_session_service.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Two steps on the sign-in screen: ask for a reset code, then set the new
/// password with that code. The server answers the first step the same way
/// whether or not the account exists.
class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.schoolCode,
    required this.initialUsername,
    required this.onDone,
  });

  final String schoolCode;
  final String initialUsername;

  /// Called with the username once the new password is saved.
  final ValueChanged<String> onDone;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  late final TextEditingController _username = TextEditingController(
    text: widget.initialUsername,
  );
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _username.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final username = _username.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Enter your username.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await locator<StaffSessionService>().forgotPassword(
        username: username,
        schoolCode: widget.schoolCode,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _codeSent = true;
        _notice = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = staffErrorMessage(e);
      });
    }
  }

  Future<void> _reset() async {
    final code = _code.text.trim();
    final password = _password.text;
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code you received.');
      return;
    }
    if (password.length < staffMinPasswordLength) {
      setState(
        () => _error =
            'Use at least $staffMinPasswordLength characters for the new password.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await locator<StaffSessionService>().resetPassword(
        username: _username.text.trim(),
        schoolCode: widget.schoolCode,
        code: code,
        newPassword: password,
      );
      if (!mounted) return;
      AppToast.success(context, 'Password reset. Sign in with the new one.');
      widget.onDone(_username.text.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = staffErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CareersAuthField(
          label: 'Username',
          hint: 'Enter your username',
          controller: _username,
          icon: CupertinoIcons.person,
          textInputAction: TextInputAction.next,
        ),
        if (_codeSent) ...[
          const SizedBox(height: 16),
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _notice!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          CareersAuthField(
            label: 'Reset code',
            hint: 'Code from your message',
            controller: _code,
            icon: CupertinoIcons.number,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CareersAuthField(
            label: 'New password',
            hint: 'At least $staffMinPasswordLength characters',
            controller: _password,
            icon: CupertinoIcons.lock,
            isPassword: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _busy ? null : _reset(),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
          ),
        ],
        const SizedBox(height: 18),
        CareersAuthButton(
          label: _codeSent ? 'Save new password' : 'Send reset code',
          isLoading: _busy,
          onPressed: _busy ? null : (_codeSent ? _reset : _sendCode),
        ),
      ],
    );
  }
}
