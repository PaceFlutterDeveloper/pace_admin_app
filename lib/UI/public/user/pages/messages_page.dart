import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareersScaffold(
      title: 'Messages',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState.noMessages(
            title: 'No Messages Yet',
            subtitle: 'Your messages with employers will appear here',
          ),
        ),
      ),
    );
  }
}
