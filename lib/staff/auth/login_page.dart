import 'dart:async';
import 'dart:convert';

import 'package:admin_app/staff/auth/cubit/auth_cubit.dart';
import 'package:admin_app/staff/auth/forgot_password_form.dart';
import 'package:admin_app/staff/auth/models/startup_school.dart';
import 'package:admin_app/staff/session/device_snapshot.dart';
import 'package:admin_app/careers/shared/components/careers_auth_scaffold.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  List<StartupSchool> _schools = [];
  String? _selectedSchool;
  bool _loadingSchools = true;
  String? _schoolLoadError;
  bool _forgot = false;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
    // Resolve the phone name and public IP while the form is filled in,
    // so sign-in does not wait on that lookup.
    unawaited(DeviceInfo.capture());
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchools() async {
    const url = 'https://paceeducation.com/erp-api/startUp.php';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final raw = body['data'] as List<dynamic>;
        setState(() {
          _schools = raw
              .map((e) => StartupSchool.fromJson(e as Map<String, dynamic>))
              .toList();
          _loadingSchools = false;
        });
      } else {
        setState(() {
          _schoolLoadError = 'Failed to load schools';
          _loadingSchools = false;
        });
      }
    } catch (_) {
      setState(() {
        _schoolLoadError = 'Error loading schools';
        _loadingSchools = false;
      });
    }
  }

  void _retrySchools() {
    setState(() {
      _loadingSchools = true;
      _schoolLoadError = null;
    });
    _fetchSchools();
  }

  void _backToCareers() {
    secretAdminLoginOpen.value = false;
  }

  void _openForgot() {
    if (_selectedSchool == null) {
      AppToast.warning(context, 'Select your school first');
      return;
    }
    setState(() => _forgot = true);
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSchool == null) {
        AppToast.warning(context, 'Please select a school');
        return;
      }
      locator<AuthCubit>().login(
        userName: _userNameController.text.trim(),
        password: _passwordController.text,
        schoolCode: _selectedSchool!.toLowerCase(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          loginFailure: (msg) => AppToast.error(context, msg),
          loginSuccess: () {
            secretAdminLoginOpen.value = false;
            // This page is not under GoRouter, so navigation goes through
            // the router instance rather than the overlay context.
            AppRoute.router.go(Routes.home.path);
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        if (_forgot) {
          return CareersAuthScaffold(
            title: 'Reset password',
            subtitle:
                'We will send a code to the contact saved on your account.',
            onBack: () => setState(() => _forgot = false),
            form: ForgotPasswordForm(
              schoolCode: _selectedSchool!.toLowerCase(),
              initialUsername: _userNameController.text.trim(),
              onDone: (username) => setState(() {
                _userNameController.text = username;
                _passwordController.clear();
                _forgot = false;
              }),
            ),
          );
        }

        return CareersAuthScaffold(
          title: 'Welcome back',
          subtitle: 'Sign in to continue to your account.',
          onBack: _backToCareers,
          form: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CareersAuthDropdown<String>(
                  label: 'School',
                  hint: 'Select your school',
                  icon: CupertinoIcons.building_2_fill,
                  value: _selectedSchool,
                  isLoading: _loadingSchools,
                  loadingLabel: 'Loading schools...',
                  loadError: _schoolLoadError,
                  onRetry: _retrySchools,
                  items: [
                    for (final school in _schools)
                      CareersAuthDropdownItem(
                        value: school.schoolCode,
                        label: school.schoolCode,
                      ),
                  ],
                  onChanged: (value) => setState(() => _selectedSchool = value),
                  validator: (value) =>
                      value == null ? 'Please select a school' : null,
                ),
                const SizedBox(height: 16),
                CareersAuthField(
                  label: 'Username',
                  hint: 'Enter your username',
                  controller: _userNameController,
                  icon: CupertinoIcons.person,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your username'
                      : null,
                ),
                const SizedBox(height: 16),
                CareersAuthField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  icon: CupertinoIcons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your password'
                      : null,
                ),
                const SizedBox(height: 18),
                CareersAuthButton(
                  label: 'Sign in',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 6),
                CareersAuthLink(
                  leading: 'Forgot your password?',
                  action: 'Reset it',
                  onPressed: _openForgot,
                ),
              ],
            ),
          ),
          footer: [
            CareersAuthLink(
              leading: 'Looking for a role?',
              action: 'Explore careers',
              onPressed: _backToCareers,
            ),
          ],
        );
      },
    );
  }
}
