import 'package:admin_app/careers/user/bloc/user_bloc.dart';
import 'package:admin_app/careers/user/bloc/user_events.dart';
import 'package:admin_app/careers/user/bloc/user_states.dart';
import 'package:admin_app/careers/shared/components/careers_auth_scaffold.dart';
import 'package:admin_app/careers/shared/theme/careers_theme.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        if (state is SignupSuccess) {
          AppToast.success(
            context,
            'Registration successful! Check your inbox and verify your '
            'email (link valid for 24 hours) before logging in.',
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) Navigator.of(context).pop();
          });
        } else if (state is SignupError) {
          AppToast.error(context, state.message);
        }
      },
      child: CareersAuthScaffold(
        title: 'Create your account',
        subtitle: 'Apply for roles across our schools in minutes.',
        form: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CareersAuthField(
                  label: 'Full name',
                  hint: 'As on your documents',
                  controller: _nameController,
                  icon: CupertinoIcons.person,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                _gap,
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
                _gap,
                CareersAuthField(
                  label: 'Phone number',
                  hint: '501234567',
                  controller: _phoneController,
                  prefixText: '+971',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 9) {
                      return 'Phone number must be 9 digits';
                    }
                    return null;
                  },
                ),
                _gap,
                CareersAuthField(
                  label: 'Password',
                  hint: 'At least 6 characters',
                  controller: _passwordController,
                  icon: CupertinoIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                _gap,
                CareersAuthField(
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  icon: CupertinoIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignup(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CareersAuthCheckbox(
                  value: _acceptTerms,
                  onChanged: (value) => setState(() => _acceptTerms = value),
                  label: TextSpan(
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: CareersAuthCheckbox.linkStyle,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: CareersAuthCheckbox.linkStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return CareersAuthButton(
                      label: 'Create account',
                      isLoading: state is SignupLoading,
                      onPressed: state is SignupLoading ? null : _handleSignup,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        footer: [
          CareersAuthLink(
            leading: 'Already have an account?',
            action: 'Sign in',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static const _gap = SizedBox(height: 14);

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        AppToast.warning(
          context,
          'Please accept the Terms of Service and Privacy Policy',
        );
        return;
      }

      context.read<UserBloc>().add(
        SignupEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: '+971${_phoneController.text.trim()}',
        ),
      );
    }
  }
}
