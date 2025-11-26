import 'package:admin_app/UI/public/jobs/models/job_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IndeedJobCard extends StatelessWidget {
  final JobModel job;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final VoidCallback? onHide;

  const IndeedJobCard({
    Key? key,
    required this.job,
    this.isBookmarked = false,
    this.onBookmark,
    this.onHide,
  }) : super(key: key);

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
        margin: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.008,
        ),
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: ConstColors.whiteColor,
          borderRadius: BorderRadius.circular(w * 0.02),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title and Action Buttons
            Row(
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBookmark,
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: ConstColors.textLight,
                        size: w * 0.05,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: h * 0.008),

            // Company Name
            Text(
              job.schoolName,
              style: TextStyle(
                fontSize: w * 0.038,
                fontWeight: FontWeight.w500,
                color: ConstColors.textDark,
              ),
            ),

            SizedBox(height: h * 0.005),

            // Location
            Text(
              job.location,
              style: TextStyle(
                fontSize: w * 0.035,
                fontWeight: FontWeight.w400,
                color: ConstColors.textLight,
              ),
            ),

            SizedBox(height: h * 0.01),

            // Tags Row
            Wrap(
              spacing: w * 0.02,
              runSpacing: h * 0.005,
              children: [
                // Experience Tag
                _buildTag(
                  context,
                  '${job.salary.minYears}+ years experience',
                  ConstColors.blueColor,
                  Icons.work,
                  w,
                  h,
                ),

                // Salary Tag
                if (job.salaryRange.isNotEmpty)
                  _buildTag(
                    context,
                    job.salaryRange,
                    Colors.green,
                    Icons.check,
                    w,
                    h,
                  ),
              ],
            ),

            SizedBox(height: h * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    double w,
    double h,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.025,
        vertical: h * 0.005,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(w * 0.015),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: w * 0.035,
          ),
          SizedBox(width: w * 0.01),
          Text(
            text,
            style: TextStyle(
              fontSize: w * 0.032,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
