import 'package:admin_app/core/widgets/app_badge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class TicketPriorityBadge extends StatelessWidget {
  final String priorityName;

  const TicketPriorityBadge({
    super.key,
    required this.priorityName,
  });

  @override
  Widget build(BuildContext context) {
    switch (priorityName) {
      case 'High':
        return AppBadge.error(
          label: priorityName,
          icon: CupertinoIcons.flag_fill,
          filled: true,
          size: AppBadgeSize.small,
        );
      case 'Medium':
        return AppBadge.warning(
          label: priorityName,
          icon: CupertinoIcons.flag_fill,
          filled: true,
          size: AppBadgeSize.small,
        );
      default:
        return AppBadge.neutral(
          label: priorityName,
          icon: CupertinoIcons.flag,
          size: AppBadgeSize.small,
        );
    }
  }
}
