import 'dart:io';

import 'package:admin_app/UI/components/home_header.dart';
import 'package:admin_app/UI/home/components/home_drawer.dart';
import 'package:admin_app/UI/home/components/menu_component.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/features/attendance/utils/attendance_permissions_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _scheduledMarkAttendancePermissionIntro = false;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    await context.read<HomeCubit>().getMenu();
  }

  /// One-time intro so location + camera can be granted before opening Mark attendance.
  Future<void> _maybeMarkAttendancePermissionIntro() async {
    if (!mounted) return;
    if (await AttendancePermissionsPrefs.isIntroCompleted()) return;
    if (await areMarkAttendancePermissionsGranted()) {
      await AttendancePermissionsPrefs.setIntroCompleted();
      return;
    }
    if (!mounted) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark attendance'),
        content: const Text(
          'Location and camera are used to confirm you are on campus and to verify '
          'your identity. You can enable them now, or later from Mark attendance in the menu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (go == true) {
      await requestMarkAttendancePermissions();
    }
    await AttendancePermissionsPrefs.setIntroCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive constants you can tweak:
    final horizontalMargin = w * 0.05; // ~5% of width
    final verticalMargin = h * 0.02; // ~2% of height
    final contentPadding = w * 0.03; // ~3% of width inside the card
    final cornerRadius = w * 0.05; // ~5% of width for border radii
    final gridVSpacing = h * 0.015; // vertical spacing between tiles
    final gridHSpacing = w * 0.015; // horizontal spacing
    final gridCrossSpacing = w * 0.02; // cross-axis spacing
    final gridMainSpacing = h * 0.02; // main-axis spacing

    // Decide how many columns based on breakpoints:
    int columns;
    if (w >= 1200) {
      columns = 6;
    } else if (w >= 900) {
      columns = 4;
    } else if (w >= 600) {
      columns = 3;
    } else {
      columns = 3;
    }

    // Aspect ratio tweak for larger screens
    final childAspect = w > 600 ? 1.2 : 1.0;

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (msg) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg))),
          success: (_) {
            if (_scheduledMarkAttendancePermissionIntro) return;
            _scheduledMarkAttendancePermissionIntro = true;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _maybeMarkAttendancePermissionIntro();
              }
            });
          },
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: HomeDrawer(scaffoldKey: _scaffoldKey),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with safe area inset
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: Platform.isIOS ? verticalMargin : verticalMargin,
                ),
                child: HomeHeader(),
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                decoration: BoxDecoration(
                  color: ConstColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(cornerRadius),
                    topRight: Radius.circular(cornerRadius),
                  ),
                ),
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: _fetchMenu,
                      child: state.maybeWhen(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        success: (menuItems) => GridView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: gridVSpacing,
                            horizontal: gridHSpacing,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: gridCrossSpacing,
                            mainAxisSpacing: gridMainSpacing,
                            childAspectRatio: childAspect,
                          ),
                          itemCount: menuItems.length,
                          itemBuilder: (ctx, i) {
                            return MenuComponent(
                              item: menuItems[i],
                            );
                          },
                        ),
                        orElse: () => const Center(
                          child: Text("No data available"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
