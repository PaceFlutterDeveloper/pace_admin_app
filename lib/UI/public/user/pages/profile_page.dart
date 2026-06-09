import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/components/index.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile_page.dart';
import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              const ProfileHeaderCard(),
              const SizedBox(height: AppSpacing.lg),
              const ProfileInfoCard(),
              const SizedBox(height: AppSpacing.lg),
              ProfileCompletionButton(
                onNavigateToCompleteProfile: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const CompleteProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
