import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/pages/signup_page.dart';
import 'package:admin_app/UI/public/shared/components/careers_auth_scaffold.dart';
import 'package:admin_app/UI/public/shared/theme/careers_theme.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Pushed with MaterialPageRoute, so this page sits outside the careers
  // ShellRoute subtree and has to apply the careers theme itself.
  @override
  Widget build(BuildContext context) {
    return CareersTheme.wrap(Builder(builder: _buildContent));
  }

  Widget _buildContent(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          AppToast.success(context, 'Welcome back, ${state.user.name}!');
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is LoginEmailNotVerified) {
          _showEmailNotVerifiedDialog(state.email);
        } else if (state is LoginError) {
          AppToast.error(context, state.message);
        } else if (state is ResendVerificationSuccess) {
          AppToast.success(context, state.message);
        } else if (state is ResendVerificationError) {
          AppToast.error(context, state.message);
        }
      },
      child: CareersAuthScaffold(
        title: 'Welcome back',
        subtitle: 'Sign in to continue your job search.',
        form: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CareersAuthField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailController,
                  icon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CareersAuthField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  icon: CupertinoIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _handleLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: CareersAuthTextAction(
                    label: 'Forgot password?',
                    emphasized: true,
                    onPressed: _showForgotPasswordDialog,
                  ),
                ),
                const SizedBox(height: 18),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return CareersAuthButton(
                      label: 'Sign in',
                      isLoading: state is LoginLoading,
                      onPressed: state is LoginLoading ? null : _handleLogin,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        footer: [
          CareersAuthLink(
            leading: "Don't have an account?",
            action: 'Sign up',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SignupPage(),
                ),
              );
            },
          ),
          Center(
            child: CareersAuthTextAction(
              label: 'Continue as guest',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => const _ForgotPasswordDialog(),
    );
  }

  void _showEmailNotVerifiedDialog(String email) {
    final bloc = context.read<UserBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify your email'),
        content: Text(
          'Your email address has not been verified yet. Please open the '
          'verification link sent to $email, then sign in again.\n\n'
          'Didn\'t receive the email? We can send a new verification link '
          '(valid for 24 hours).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(ResendVerificationEvent(email: email));
            },
            child: const Text('Resend email'),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) =>
          current is ForgotPasswordSuccess || current is ForgotPasswordError,
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          AppToast.success(context, state.message);
          Navigator.of(context).pop();
        } else if (state is ForgotPasswordError) {
          AppToast.error(context, state.message);
        }
      },
      child: AlertDialog(
        scrollable: true,
        actionsOverflowButtonSpacing: 8,
        title: const Text('Forgot password'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your email address and we'll send you a link to reset "
                'your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              CareersSpacing.gap16,
              AppTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                prefixIcon: CupertinoIcons.mail,
                outlined: true,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) =>
                current is ForgotPasswordLoading ||
                previous is ForgotPasswordLoading,
            builder: (context, state) {
              return TextButton(
                onPressed: state is ForgotPasswordLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UserBloc>().add(
                            ForgotPasswordEvent(
                              email: _emailController.text.trim(),
                            ),
                          );
                        }
                      },
                child: state is ForgotPasswordLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send reset link'),
              );
            },
          ),
        ],
      ),
    );
  }
}
