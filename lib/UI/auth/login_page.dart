import 'dart:convert';

import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/auth/models/startup_school.dart';
import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/UI/components/careers_button.dart';
import 'package:admin_app/UI/components/drop_down_with_label.dart';
import 'package:admin_app/UI/components/form_field_with_label.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  List<StartupSchool> _schools = [];
  String? _selectedSchool;
  bool _loadingSchools = true;
  String? _schoolLoadError;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
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
          _schoolLoadError = 'Failed to load schools (${res.statusCode})';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // tweak these ratios as needed
    final sidePadding = w * 0.04; // ~16px on 400px width
    final verticalPadding = h * 0.02; // ~16px on 800px height
    final logoWidth = w * 0.6; // ~250px on 420px width
    final titleFont = w * 0.06; // ~24px
    final subtitleFont = w * 0.035; // ~14px
    final fieldIconPadding = w * 0.02; // ~8px
    final gapSmall = h * 0.015; // ~12px
    final gapMedium = h * 0.02; // ~16px
    final loaderSize = w * 0.12; // ~48px
    final loaderLarge = w * 0.18; // ~70px

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding,
            vertical: verticalPadding,
          ),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                loginFailure: (msg) => showToast(msg),
                loginSuccess: () {
                  context.read<HomeCubit>().getMenu();
                  context.goNamed(Routes.root.name);
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          "assets/logo/group.png",
                          width: logoWidth,
                        ),
                      ),
                      SizedBox(height: gapMedium),

                      // Title
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: const Color(0xFF101828),
                          fontSize: titleFont,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: gapSmall),

                      // Subtitle
                      Text(
                        'Sign in to my account',
                        style: TextStyle(
                          color: const Color(0xFF475467),
                          fontSize: subtitleFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: gapMedium),

                      // School dropdown / loader / error
                      if (_loadingSchools)
                        Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: ConstColors.primary,
                            size: loaderSize,
                          ),
                        )
                      else if (_schoolLoadError != null)
                        Text(
                          _schoolLoadError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: subtitleFont,
                          ),
                        )
                      else
                        DropdownWithLabel(
                          labelText: 'School',
                          hintText: 'Select School',
                          items: _schools.map((s) => s.schoolCode).toList(),
                          selectedValue: _selectedSchool,
                          onChanged: (val) =>
                              setState(() => _selectedSchool = val),
                          validator: (v) =>
                              v == null ? 'Please select a school' : null,
                        ),

                      SizedBox(height: gapSmall),

                      // Username
                      FormFeildWithLabel(
                        icon: Padding(
                          padding: EdgeInsets.all(fieldIconPadding),
                          child: SvgPicture.asset('assets/icons/employee.svg'),
                        ),
                        labelText: "User Name",
                        controller: userNameController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please enter a valid user name'
                            : null,
                      ),
                      SizedBox(height: gapSmall),

                      // Password
                      FormFeildWithLabel(
                        icon: Padding(
                          padding: EdgeInsets.all(fieldIconPadding),
                          child: SvgPicture.asset('assets/icons/password.svg'),
                        ),
                        labelText: "Password",
                        controller: passwordController,
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Please enter a valid password'
                            : null,
                      ),
                      SizedBox(height: gapMedium),

                      // Login button or loader
                      state.maybeWhen(
                        loading: () => Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: ConstColors.primary,
                            size: loaderLarge,
                          ),
                        ),
                        orElse: () => ButtonComponent(
                          buttonText: "LOGIN",
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              locator<AuthCubit>().login(
                                userName: userNameController.text,
                                password: passwordController.text,
                                schoolCode: _selectedSchool!.toLowerCase(),
                              );
                            }
                          },
                        ),
                      ),

                      SizedBox(height: gapMedium),

                      // // Careers button
                      // const CareersButton(
                      //   title: 'Explore Careers',
                      //   subtitle: 'View available job opportunities',
                      //   icon: Icons.work_outline,
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
