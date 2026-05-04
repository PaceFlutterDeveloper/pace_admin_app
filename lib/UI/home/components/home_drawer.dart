import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/home/components/select_user.dart';
import 'package:admin_app/UI/home/components/user_tile.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_dialogs.dart';
import 'package:admin_app/core/widgets/app_list_tile.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _scaffoldKey = scaffoldKey;

  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: UserTile(
                      onTap: () {
                        _scaffoldKey.currentState?.closeDrawer();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Switch user button
                  Material(
                    color: isDark
                        ? AppColors.surfaceContainerDark
                        : AppColors.surfaceContainerLight,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    child: InkWell(
                      onTap: () {
                        showAppBottomSheet(
                          context: context,
                          builder: (context) => const SelectUser(),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppRadius.circle),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.arrow_up_arrow_down,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                physics: const BouncingScrollPhysics(),
                children: [
                  AppListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.iosRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        CupertinoIcons.square_arrow_right,
                        color: AppColors.iosRed,
                        size: 20,
                      ),
                    ),
                    title: 'Sign Out',
                    titleStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.iosRed,
                    ),
                    onTap: () async {
                      final confirm = await showAppConfirmDialog(
                        context: context,
                        title: 'Sign Out',
                        message: 'Are you sure you want to sign out?',
                        confirmLabel: 'Sign Out',
                        isDestructive: true,
                      );
                      if (confirm == true) {
                        locator<AuthCubit>().logout();
                      }
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'PACE Admin',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
