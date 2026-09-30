import 'package:admin_app/UI/public/jobs/components/shared/card_decoration.dart';
import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:flutter/material.dart';

/// Profile surface. Delegates to [CardDecoration] so profile cards, job cards
/// and detail cards share one radius, border and shadow.
class ProfileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ProfileCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(CareersSpacing.cardPadding),
      decoration: CardDecoration.build(context),
      child: child,
    );
  }
}
