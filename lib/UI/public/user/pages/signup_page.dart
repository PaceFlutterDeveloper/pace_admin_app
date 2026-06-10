import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_formatPhoneNumber);
  }

  void _formatPhoneNumber() {
    final text = _phoneController.text;
    if (text.length > 9) {
      _phoneController.text = text.substring(0, 9);
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_formatPhoneNumber);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            AppToast.success(
              context,
              'Registration successful! Please log in with your credentials.',
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) Navigator.of(context).pop();
            });
          } else if (state is SignupError) {
            AppToast.error(context, state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Create your account to get started',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    prefixIcon: CupertinoIcons.person,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    prefixIcon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Phone Number',
                    hint: '501234567',
                    controller: _phoneController,
                    prefixIcon: CupertinoIcons.phone,
                    keyboardType: TextInputType.phone,
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md),
                      child: Text(
                        '+971 ',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
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
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Password',
                    hint: 'Create a password',
                    controller: _passwordController,
                    prefixIcon: CupertinoIcons.lock,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
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
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    prefixIcon: CupertinoIcons.lock,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        size: 20,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
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
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: GoogleFonts.inter(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: GoogleFonts.inter(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppButton.primary(
                        label: 'Create Account',
                        isLoading: state is SignupLoading,
                        onPressed: state is SignupLoading
                            ? null
                            : _handleSignup,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.inter(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
