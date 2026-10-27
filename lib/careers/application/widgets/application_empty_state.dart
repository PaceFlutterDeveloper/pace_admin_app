import 'package:admin_app/careers/shared/components/careers_empty_state.dart';
import 'package:flutter/cupertino.dart';

class ApplicationEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseJobs;

  const ApplicationEmptyState({super.key, this.onBrowseJobs});

  @override
  Widget build(BuildContext context) {
    return CareersEmptyState(
      icon: CupertinoIcons.doc_text,
      title: 'No applications yet',
      message: 'Once you apply for a role it will appear here.',
      actionLabel: onBrowseJobs == null ? null : 'Browse jobs',
      onAction: onBrowseJobs,
    );
  }
}
