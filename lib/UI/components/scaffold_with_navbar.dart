import 'package:admin_app/UI/components/user_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: UserBottomNavBar(),
    );
  }
}
