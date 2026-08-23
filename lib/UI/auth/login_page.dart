import 'dart:convert';

import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/auth/models/startup_school.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchSchools();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            state.maybeWhen(
              loginFailure: (msg) => AppToast.error(context, msg),
              loginSuccess: () {
                context.read<HomeCubit>().getMenu();
                context.goNamed(Routes.root.name);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            final screenWidth = MediaQuery.sizeOf(context).width;
            final isNarrow = screenWidth < 360;
            final horizontalPadding = isNarrow ? AppSpacing.md : AppSpacing.lg;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 480,
                    minHeight:
                        MediaQuery.sizeOf(context).height -
                        MediaQuery.paddingOf(context).top -
                        MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xxl),

                        // Logo
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Image.asset(
                              "assets/logo/group.png",
                              width: isNarrow ? 160 : 220,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Welcome text
                        Text(
                          'Welcome back',
                          style: GoogleFonts.inter(
                            fontSize: isNarrow ? 24 : 28,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Sign in to continue to your account',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // School dropdown
                        _buildSchoolDropdown(theme, isDark),

                        const SizedBox(height: AppSpacing.md),

                        // Username field
                        AppTextField(
                          label: 'Username',
                          hint: 'Enter your username',
                          controller: _userNameController,
                          prefixIcon: CupertinoIcons.person,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter your username'
                              : null,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Password field
                        AppTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          prefixIcon: CupertinoIcons.lock,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter your password'
                              : null,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Login button
                        AppButton.primary(
                          label: 'Sign In',
                          onPressed: isLoading ? null : _handleLogin,
                          isLoading: isLoading,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _buildOrDivider(theme),

                        const SizedBox(height: AppSpacing.lg),

                        _buildCareersEntry(theme, isDark),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrDivider(ThemeData theme) {
    final dividerColor = theme.colorScheme.onSurface.withOpacity(0.15);
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.5);

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor, height: 1)),
      ],
    );
  }

  Widget _buildCareersEntry(ThemeData theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(Routes.careers.name),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerDark
                : AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  CupertinoIcons.briefcase,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Careers',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'View available job opportunities',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolDropdown(ThemeData theme, bool isDark) {
    if (_loadingSchools) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceContainerDark
              : AppColors.surfaceContainerLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Loading schools...',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_schoolLoadError != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.iosRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.iosRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: AppColors.iosRed,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _schoolLoadError!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.iosRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _loadingSchools = true;
                  _schoolLoadError = null;
                });
                _fetchSchools();
              },
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerDark
                : AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: _selectedSchool == null
                ? null
                : Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSchool,
            decoration: InputDecoration(
              hintText: 'Select your school',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(
                CupertinoIcons.building_2_fill,
                color: isDark
                    ? AppColors.iosSystemGrayDark
                    : AppColors.iosSystemGray,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
            ),
            icon: Icon(
              CupertinoIcons.chevron_down,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            dropdownColor: isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            items: _schools.map((s) {
              return DropdownMenuItem(
                value: s.schoolCode,
                child: Text(
                  s.schoolCode,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedSchool = val),
            validator: (v) => v == null ? 'Please select a school' : null,
          ),
        ),
      ],
    );
  }
}
