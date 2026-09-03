import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_dialogs.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutDialog {
  LogoutDialog._();

  static Future<void> show(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    context.read<UserBloc>().add(const LogoutEvent());
  }
}

/// Full-screen blocking overlay shown while [UserBloc] is in [LogoutLoading].
class LogoutLoadingOverlay extends StatelessWidget {
  final Widget child;

  const LogoutLoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (previous, current) => current is LogoutError,
      listener: (context, state) {
        if (state is LogoutError) {
          AppToast.error(context, state.message);
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        buildWhen: (previous, current) =>
            previous is LogoutLoading || current is LogoutLoading,
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (state is LogoutLoading) const _LogoutBarrier(),
            ],
          );
        },
      ),
    );
  }
}

class _LogoutBarrier extends StatelessWidget {
  const _LogoutBarrier();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned.fill(
      child: PopScope(
        canPop: false,
        child: AbsorbPointer(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: Material(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: AppRadius.borderRadiusLg,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator.adaptive(),
                      AppSpacing.vGapMd,
                      Text(
                        'Signing out...',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
