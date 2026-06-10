import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/components/index.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Candidate profile page, driven by the `get-profile` and
/// `profile-completion` APIs through [CareersProfileBloc].
///
/// Hive (`CareersUserManager`) is used only as an offline fallback for the
/// header while the API loads or fails.
class CareersProfilePage extends StatefulWidget {
  const CareersProfilePage({super.key});

  @override
  State<CareersProfilePage> createState() => _CareersProfilePageState();
}

class _CareersProfilePageState extends State<CareersProfilePage> {
  ProfileModel? _profile;
  ProfileCompletionModel? _completion;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _loading = true;
      _error = null;
    });
    final bloc = context.read<CareersProfileBloc>();
    bloc.add(const LoadProfileEvent());
    bloc.add(const CheckProfileCompletionEvent());
  }

  Future<void> _openCompleteProfile() async {
    await context.pushNamed(Routes.careersCompleteProfile.name);
    if (mounted) _load();
  }

  void _onProfileStateChange(BuildContext context, CareersProfileState state) {
    if (state is ProfileLoading) {
      setState(() => _loading = true);
    } else if (state is ProfileLoaded) {
      setState(() {
        _profile = state.profile;
        _loading = false;
        _error = null;
      });
    } else if (state is ProfileError) {
      setState(() {
        _loading = false;
        _error = state.message;
      });
    } else if (state is ProfileCompletionLoaded) {
      setState(() => _completion = state.completion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CareersScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.square_arrow_right),
          tooltip: 'Logout',
          onPressed: () => LogoutDialog.show(context),
        ),
      ],
      body: MultiBlocListener(
        listeners: [
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                Navigator.of(context).pop();
              }
            },
          ),
          BlocListener<CareersProfileBloc, CareersProfileState>(
            listener: _onProfileStateChange,
          ),
        ],
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _profile == null) {
      return const _ProfileShimmer();
    }

    if (_error != null && _profile == null) {
      // Offline fallback: show the cached Hive identity if available.
      final cachedUser = CareersUserManager.getCurrentUser();
      if (cachedUser == null) {
        return Center(
          child: AppErrorState.generic(message: _error, onRetry: _load),
        );
      }
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ProfileHeaderCard(name: cachedUser.name, email: cachedUser.email),
            AppSpacing.vGapMd,
            AppInlineError(message: _error!, onRetry: _load),
          ],
        ),
      );
    }

    final profile = _profile;
    final cachedUser = CareersUserManager.getCurrentUser();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ProfileHeaderCard(
            name: profile?.name ?? cachedUser?.name ?? 'Guest User',
            email: profile?.email ?? cachedUser?.email ?? '',
            avatarUrl: profile?.avatarFile,
            isComplete: _completion?.isComplete,
            completionPercentage: _completion?.percentage,
          ),
          AppSpacing.vGapLg,
          if (profile != null) ...[
            ProfileInfoCard(profile: profile),
            AppSpacing.vGapLg,
          ],
          ProfileCompletionButton(
            completion: _completion,
            onNavigateToCompleteProfile: _openCompleteProfile,
          ),
        ],
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.md),
      child: AppShimmer(
        child: Column(
          children: [
            ShimmerCircle(size: AppSizes.avatarXl),
            AppSpacing.vGapMd,
            ShimmerLine(width: 160, height: 20),
            AppSpacing.vGapSm,
            ShimmerLine(width: 220, height: 14),
            AppSpacing.vGapLg,
            ShimmerCard(height: 280),
            AppSpacing.vGapLg,
            ShimmerCard(height: 96),
          ],
        ),
      ),
    );
  }
}
