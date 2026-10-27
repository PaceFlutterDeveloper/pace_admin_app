import 'package:flutter/material.dart';

import '../../../shared/theme/careers_tokens.dart';
import 'card_decoration.dart';
import 'section_title.dart';

/// Titled card used for every section on the job detail screen, so padding,
/// radius and heading spacing are identical across sections.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CareersSpacing.cardPadding),
      decoration: CardDecoration.build(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: context.careers.accentText),
                const SizedBox(width: 8),
              ],
              Expanded(child: SectionTitle(title: title)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
