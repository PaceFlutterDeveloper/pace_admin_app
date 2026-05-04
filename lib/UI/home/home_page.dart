import 'package:admin_app/UI/components/home_header.dart';
import 'package:admin_app/UI/home/components/home_drawer.dart';
import 'package:admin_app/UI/home/components/menu_component.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_shimmer.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/core/widgets/app_dialogs.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:admin_app/features/attendance/utils/attendance_permissions_helper.dart';
import 'package:flutter/cupertino.dart';
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

  Future<void> _maybeMarkAttendancePermissionIntro() async {
    if (!mounted) return;
    if (await AttendancePermissionsPrefs.isIntroCompleted()) return;
    if (await areMarkAttendancePermissionsGranted()) {
      await AttendancePermissionsPrefs.setIntroCompleted();
      return;
    }
    if (!mounted) return;

    final go = await showAppConfirmDialog(
      context: context,
      title: 'Mark Attendance',
      message:
          'Location and camera are used to confirm you are on campus and to verify '
          'your identity. You can enable them now, or later from Mark attendance in the menu.',
      confirmLabel: 'Continue',
      cancelLabel: 'Not now',
    );

    if (!mounted) return;
    if (go == true) {
      await requestMarkAttendancePermissions();
    }
    await AttendancePermissionsPrefs.setIntroCompleted();
  }

  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final columns = _getGridColumns(context);

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (msg) => AppToast.error(context, msg),
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
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with safe area
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: const HomeHeader(),
              ),
            ),

            // Main content area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceContainerDark
                      : AppColors.surfaceContainerLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      return AppRefreshIndicator(
                        onRefresh: _fetchMenu,
                        child: state.maybeWhen(
                          loading: () => _buildLoadingGrid(columns),
                          success: (menuItems) => menuItems.isEmpty
                              ? Center(
                                  child: AppEmptyState.noData(
                                    title: 'No menu items',
                                    subtitle: 'Pull down to refresh',
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: AppSpacing.md,
                                    mainAxisSpacing: AppSpacing.md,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: menuItems.length,
                                  itemBuilder: (ctx, i) {
                                    return MenuComponent(item: menuItems[i]);
                                  },
                                ),
                          orElse: () => Center(
                            child: AppEmptyState.noData(
                              title: 'No data available',
                              subtitle: 'Pull down to refresh',
                              onAction: _fetchMenu,
                              actionLabel: 'Refresh',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(int columns) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ShimmerGrid(
        crossAxisCount: columns,
        itemCount: 9,
        spacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
    );
  }
}
