import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dangerColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        'Logout',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        'Are you sure you want to logout?',
        style: GoogleFonts.inter(
          fontSize: 15,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<UserBloc>().add(const LogoutEvent());
          },
          child: Text(
            'Logout',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: dangerColor,
            ),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const LogoutDialog());
  }
}
