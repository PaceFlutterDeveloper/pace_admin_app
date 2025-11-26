import 'package:admin_app/UI/public/user/bloc/user_bloc.dart';
import 'package:admin_app/UI/public/user/bloc/user_events.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<UserBloc>().add(LogoutEvent());
          },
          child: Text(
            'Logout',
            style: TextStyle(color: ConstColors.primary),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
  }
}
