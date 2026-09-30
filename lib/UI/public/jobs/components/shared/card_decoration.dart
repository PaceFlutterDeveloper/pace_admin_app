import 'package:flutter/material.dart';

import '../../../shared/theme/careers_tokens.dart';

/// The one surface definition for careers cards. Job cards, detail cards and
/// profile cards all build from this so radius, border and shadow stay in sync.
class CardDecoration {
  const CardDecoration._();

  static BoxDecoration build(BuildContext context) {
    return const BoxDecoration(
      color: CareersColors.surface,
      borderRadius: CareersRadius.cardAll,
      border: Border.fromBorderSide(
        BorderSide(color: CareersColors.border),
      ),
      boxShadow: CareersShadows.card,
    );
  }

  /// Flat variant for cards nested inside another card or a coloured section.
  static BoxDecoration nested(BuildContext context) {
    return const BoxDecoration(
      color: CareersColors.surfaceMuted,
      borderRadius: CareersRadius.chipAll,
      border: Border.fromBorderSide(
        BorderSide(color: CareersColors.divider),
      ),
    );
  }
}
