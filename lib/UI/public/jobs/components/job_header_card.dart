import 'package:admin_app/UI/public/jobs/components/shared/card_decoration.dart';
import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JobHeaderCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onShare;

  const JobHeaderCard({Key? key, required this.job, this.onShare})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: CardDecoration.build(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobTitleRow(context, w, h),
          SizedBox(height: h * 0.015),
          _buildCompanyInfo(w, h),
          SizedBox(height: h * 0.008),
          _buildLocationInfo(w, h),
          SizedBox(height: h * 0.01),
          _buildPostedDateInfo(w, h),
          SizedBox(height: h * 0.008),
          _buildDeadlineInfo(w, h),
        ],
      ),
    );
  }

  Widget _buildJobTitleRow(BuildContext context, double w, double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            job.title,
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.w700,
              color: ConstColors.textDark,
              height: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            _buildShareButton(context, w),
            SizedBox(width: w * 0.02),
            _buildStatusBadge(w, h),
          ],
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context, double w) {
    return GestureDetector(
      onTap: () => _shareJob(context),
      child: Container(
        padding: EdgeInsets.all(w * 0.02),
        decoration: BoxDecoration(
          color: ConstColors.backgroundColor,
          borderRadius: BorderRadius.circular(w * 0.015),
        ),
        child: Icon(Icons.share, size: w * 0.04, color: ConstColors.textDark),
      ),
    );
  }

  Widget _buildStatusBadge(double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.006),
      decoration: BoxDecoration(
        color: _getStatusColor(job.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(w * 0.015),
        border: Border.all(color: _getStatusColor(job.status), width: 1),
      ),
      child: Text(
        job.status,
        style: TextStyle(
          fontSize: w * 0.03,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(job.status),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(double w, double h) {
    return Row(
      children: [
        Icon(Icons.business, size: w * 0.035, color: ConstColors.textLight),
        SizedBox(width: w * 0.015),
        Expanded(
          child: Text(
            job.schoolName,
            style: TextStyle(
              fontSize: w * 0.035,
              fontWeight: FontWeight.w600,
              color: ConstColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(double w, double h) {
    return Row(
      children: [
        Icon(Icons.location_on, size: w * 0.035, color: ConstColors.textLight),
        SizedBox(width: w * 0.015),
        Expanded(
          child: Text(
            job.location,
            style: TextStyle(
              fontSize: w * 0.032,
              fontWeight: FontWeight.w500,
              color: ConstColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostedDateInfo(double w, double h) {
    return Row(
      children: [
        Icon(Icons.schedule, size: w * 0.04, color: ConstColors.textLight),
        SizedBox(width: w * 0.02),
        Text(
          'Posted ${_formatPostedDate(job)}',
          style: TextStyle(
            fontSize: w * 0.032,
            fontWeight: FontWeight.w500,
            color: ConstColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineInfo(double w, double h) {
    return Row(
      children: [
        Icon(Icons.event, size: w * 0.04, color: Colors.red),
        SizedBox(width: w * 0.02),
        Text(
          'Deadline: ${_formatDeadline(job.deadline)}',
          style: TextStyle(
            fontSize: w * 0.032,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'on hold':
        return Colors.orange;
      default:
        return ConstColors.blueColor;
    }
  }

  String _formatPostedDate(JobModel job) {
    final date = job.postedDate;
    if (date != null) return _formatDate(date);
    if (job.createdAt.isNotEmpty) return job.createdAt;
    return 'recently';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDeadline(String deadline) {
    if (deadline.isEmpty) return 'Not specified';

    try {
      final deadlineDate = _parseDisplayDate(deadline);
      if (deadlineDate == null) return deadline;

      final now = DateTime.now();
      final difference = deadlineDate.difference(now);

      if (difference.inDays < 0) {
        return 'Expired';
      } else if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Tomorrow';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days left';
      } else {
        return '${deadlineDate.day}/${deadlineDate.month}/${deadlineDate.year}';
      }
    } catch (e) {
      return deadline;
    }
  }

  DateTime? _parseDisplayDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length == 3) {
        return DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
    }
    return DateTime.tryParse(value);
  }

  void _shareJob(BuildContext context) {
    final shareText =
        '''
${job.title} at ${job.schoolName}
Location: ${job.location}
Employment Type: ${job.employmentType}
Salary: ${job.salaryRange.isNotEmpty ? job.salaryRange : 'Not specified'}

${job.description}

Apply now!
''';

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Job details copied to clipboard',
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: ConstColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
