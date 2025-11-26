import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_states.dart';
import 'package:admin_app/UI/public/user/components/index.dart';
import 'package:admin_app/UI/public/user/pages/complete_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => LogoutDialog.show(context),
          ),
        ],
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProfileHeaderCard(),
              const SizedBox(height: 24),
              ProfileInfoCard(),
              const SizedBox(height: 24),
              ProfileCompletionButton(
                onNavigateToCompleteProfile: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
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
