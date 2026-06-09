import 'package:admin_app/UI/public/jobs/components/careers_scaffold.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyJobsPage extends StatelessWidget {
  const MyJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CareersScaffold(
      title: 'My Jobs',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            icon: CupertinoIcons.bookmark,
            title: 'No Saved Jobs Yet',
            subtitle: 'Jobs you save will appear here',
          ),
        ),
      ),
    );
  }
}
