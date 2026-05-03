import 'dart:io';

import 'package:admin_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceSuccessWidget extends StatelessWidget {
  final AttendanceRecord record;
  final VoidCallback onDone;

  const AttendanceSuccessWidget({
    super.key,
    required this.record,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(record.markedAt.toLocal());
    final date =
        DateFormat('EEEE, d MMM yyyy').format(record.markedAt.toLocal());

    return Column(
      children: [
        const SizedBox(height: 24),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFE8F7ED),
            child:
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 52),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: record.capturedImagePath != null
                        ? FileImage(File(record.capturedImagePath!))
                        : null,
                    child: record.capturedImagePath == null
                        ? const Icon(Icons.person_rounded)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Employee #${record.employeeId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RowItem(label: 'Time', value: 'Marked at $time'),
              _RowItem(label: 'Date', value: date),
              _RowItem(label: 'Location', value: record.schoolName),
              _RowItem(
                label: 'Identity',
                value: 'Verified ${record.confidence.toStringAsFixed(1)}% ✓',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
