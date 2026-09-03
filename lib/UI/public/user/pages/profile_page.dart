import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_bloc.dart';
import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_states.dart';
import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/components/index.dart';
import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';
import 'package:admin_app/UI/public/user/models/profile_data_models.dart';
import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
import 'package:admin_app/UI/public/user/utils/profile_file_paths.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_button.dart';
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
  final bool embedded;
  final VoidCallback? onAuthChanged;

  const CareersProfilePage({
    super.key,
    this.embedded = false,
    this.onAuthChanged,
  });

  @override
  State<CareersProfilePage> createState() => _CareersProfilePageState();
}

class _CareersProfilePageState extends State<CareersProfilePage>
    with AutomaticKeepAliveClientMixin {
  ProfileModel? _profile;

  @override
  bool get wantKeepAlive => widget.embedded;
  ProfileCompletionModel? _completion;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (locator<CareersUserService>().isCareersUserLoggedIn()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    } else {
      _loading = false;
    }
  }

  void _load() {
    if (!mounted) return;
    if (!locator<CareersUserService>().isCareersUserLoggedIn()) {
      setState(_resetLocalProfile);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final bloc = context.read<CareersProfileBloc>();
    bloc.add(const LoadProfileEvent());
    bloc.add(const CheckProfileCompletionEvent());
  }

  void _resetLocalProfile() {
    _profile = null;
    _completion = null;
    _loading = false;
    _error = null;
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
    } else if (state is ProfileFilesUploaded) {
      final candidate = ProfileFilePaths.extractCandidateMap(
        state.uploadData ?? const {},
      );
      if (candidate != null) {
        final uploaded = ProfileModel.fromJson(candidate);
        if (CareersMediaUrl.isDisplayableRemote(uploaded.avatarFile)) {
          setState(() {
            _profile = (_profile ?? uploaded).copyWith(
              avatarFile: uploaded.avatarFile,
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = MultiBlocListener(
      listeners: [
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              _load();
              widget.onAuthChanged?.call();
            } else if (state is LogoutSuccess) {
              setState(_resetLocalProfile);
              widget.onAuthChanged?.call();
              if (!widget.embedded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Navigator.of(context).pop();
                });
              }
            }
          },
        ),
        BlocListener<CareersProfileBloc, CareersProfileState>(
          listener: _onProfileStateChange,
        ),
      ],
      child: _buildBody(context),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right),
            tooltip: 'Logout',
            onPressed: () => LogoutDialog.show(context),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!locator<CareersUserService>().isCareersUserLoggedIn()) {
      return _buildLoginPrompt(context);
    }

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
            ProfileHeaderCard(
              name: cachedUser.name,
              email: cachedUser.email,
              avatarUrl: CareersMediaUrl.isDisplayableRemote(
                    cachedUser.profileImage,
                  )
                  ? cachedUser.profileImage
                  : null,
            ),
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
            avatarUrl: CareersMediaUrl.isDisplayableRemote(profile?.avatarFile)
                ? profile?.avatarFile
                : null,
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
          if (widget.embedded) ...[
            AppSpacing.vGapLg,
            AppButton.secondary(
              label: 'Logout',
              leadingIcon: CupertinoIcons.square_arrow_right,
              onPressed: () => LogoutDialog.show(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_crop_circle,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapMd,
            Text(
              'Sign in to view your profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.vGapSm,
            Text(
              'Log in to manage your candidate profile and apply for jobs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vGapLg,
            AppButton.primary(
              label: 'Login',
              isFullWidth: false,
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute<void>(
                        builder: (context) => const LoginPage(),
                      ),
                    )
                    .then((_) {
                      widget.onAuthChanged?.call();
                      if (mounted &&
                          locator<CareersUserService>()
                              .isCareersUserLoggedIn()) {
                        _load();
                      }
                    });
              },
            ),
          ],
        ),
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
