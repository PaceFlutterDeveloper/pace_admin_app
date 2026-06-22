import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/application_models.dart';

class ApplicationCard extends StatelessWidget {
  final Application application;

  const ApplicationCard({
    Key? key,
    required this.application,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = ApplicationStatus.fromString(application.application.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Job Title and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.job.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        application.job.school,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),

            SizedBox(height: 16.h),

            // Job Details
            _buildJobDetails(),

            SizedBox(height: 16.h),

            // Application Details
            _buildApplicationDetails(),

            SizedBox(height: 16.h),

            // Footer with Applied Date and Actions
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ApplicationStatus.applied:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case ApplicationStatus.reviewed:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case ApplicationStatus.shortlisted:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case ApplicationStatus.interviewed:
        backgroundColor = Colors.indigo[100]!;
        textColor = Colors.indigo[800]!;
        break;
      case ApplicationStatus.accepted:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case ApplicationStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildJobDetails() {
    return Column(
      children: [
        _buildDetailRow(
          icon: Icons.location_on,
          label: 'Location',
          value: application.job.location,
        ),
        SizedBox(height: 8.h),
        _buildDetailRow(
          icon: Icons.work,
          label: 'Employment Type',
          value: application.job.employmentType,
        ),
        SizedBox(height: 8.h),
        _buildDetailRow(
          icon: Icons.attach_money,
          label: 'Salary Range',
          value: application.job.salaryRange,
        ),
      ],
    );
  }

  Widget _buildApplicationDetails() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Details',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          _buildDetailRow(
            icon: Icons.source,
            label: 'Source',
            value: application.application.source,
          ),
          SizedBox(height: 8.h),
          _buildDetailRow(
            icon: Icons.description,
            label: 'CV File',
            value: application.application.cvFile,
          ),
          SizedBox(height: 8.h),
          _buildDetailRow(
            icon: Icons.check_circle,
            label: 'Availability',
            value: application.application.availabilityOk
                ? 'Available'
                : 'Not Available',
            valueColor: application.application.availabilityOk
                ? Colors.green[600]
                : Colors.red[600],
          ),
          if (application.application.coverLetter.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Cover Letter',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              application.application.coverLetter,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.w,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: valueColor ?? Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applied on',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          application.application.appliedDate,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
