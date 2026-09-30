import 'package:flutter/material.dart';

/// Section heading inside a careers card. Typography comes from the careers
/// text theme so every section header matches across screens.
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}
