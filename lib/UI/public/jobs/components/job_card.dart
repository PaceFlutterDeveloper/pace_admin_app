import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return GestureDetector(
      onTap: () {
        context.pushNamed(Routes.jobDetail.name, extra: job.jobId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.008),
        decoration: BoxDecoration(
          color: ConstColors.whiteColor,
          borderRadius: BorderRadius.circular(w * 0.03),
          border: Border.all(color: ConstColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(w * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: TextStyle(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w700,
                        color: ConstColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.025,
                      vertical: h * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(w * 0.02),
                      border: Border.all(
                        color: _getStatusColor(job.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        fontSize: w * 0.032,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(job.status),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.01),

              // Company and Location
              Row(
                children: [
                  Icon(
                    Icons.business,
                    size: w * 0.04,
                    color: ConstColors.textLight,
                  ),
                  SizedBox(width: w * 0.02),
                  Expanded(
                    child: Text(
                      job.schoolName,
                      style: TextStyle(
                        fontSize: w * 0.038,
                        fontWeight: FontWeight.w500,
                        color: ConstColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.008),

              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: w * 0.04,
                    color: ConstColors.textLight,
                  ),
                  SizedBox(width: w * 0.02),
                  Expanded(
                    child: Text(
                      job.location,
                      style: TextStyle(
                        fontSize: w * 0.038,
                        fontWeight: FontWeight.w500,
                        color: ConstColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.008),

              // Posted Date
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: w * 0.04,
                    color: ConstColors.textLight,
                  ),
                  SizedBox(width: w * 0.02),
                  Text(
                    _formatPostedDate(job),
                    style: TextStyle(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.w400,
                      color: ConstColors.textLight,
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.015),

              // Job Details Row
              Row(
                children: [
                  // Employment Type
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.025,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: ConstColors.blueColorTwo,
                        borderRadius: BorderRadius.circular(w * 0.015),
                      ),
                      child: Text(
                        job.employmentType,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          fontWeight: FontWeight.w500,
                          color: ConstColors.blueColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(width: w * 0.02),

                  // Experience Level
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.025,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: ConstColors.secondary,
                        borderRadius: BorderRadius.circular(w * 0.015),
                      ),
                      child: Text(
                        job.experienceLevel,
                        style: TextStyle(
                          fontSize: w * 0.032,
                          fontWeight: FontWeight.w500,
                          color: ConstColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(width: w * 0.02),

                  // Salary
                  if (job.salaryRange.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.025,
                          vertical: h * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: ConstColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(w * 0.015),
                        ),
                        child: Text(
                          job.salaryRange,
                          style: TextStyle(
                            fontSize: w * 0.032,
                            fontWeight: FontWeight.w600,
                            color: ConstColors.primary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),

              if (job.description.isNotEmpty) ...[
                SizedBox(height: h * 0.01),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w400,
                    color: ConstColors.textLight,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
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
    if (job.createdAt.isNotEmpty) return 'Posted ${job.createdAt}';
    return 'Posted recently';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
