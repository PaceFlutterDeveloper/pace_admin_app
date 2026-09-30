import 'package:admin_app/UI/public/user/pages/login_page.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/careers_tokens.dart';

/// Shown on tabs that need a signed-in candidate. Pushes the same login page
/// the rest of the app uses and reports back when it closes.
class CareersSignInPrompt extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onReturn;

  const CareersSignInPrompt({
    super.key,
    required this.title,
    required this.message,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CareersSpacing.screenH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: CareersGradients.hero,
                shape: BoxShape.circle,
                boxShadow: CareersShadows.glass,
              ),
              child: const Icon(
                CupertinoIcons.person_crop_circle,
                size: 38,
                color: Colors.white,
              ),
            ),
            CareersSpacing.gap24,
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ),
            CareersSpacing.gap24,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: AppButton.primary(
                label: 'Sign in',
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                      )
                      .then((_) => onReturn?.call());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
