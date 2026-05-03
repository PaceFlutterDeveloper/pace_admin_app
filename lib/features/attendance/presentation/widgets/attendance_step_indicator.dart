import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class AttendanceStepIndicator extends StatelessWidget {
  final int currentStep;

  const AttendanceStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _StepTile(
            label: 'Location',
            icon: Icons.place_rounded,
            isCurrent: currentStep == 0,
            isComplete: currentStep > 0,
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _StepTile(
            label: 'Face Scan',
            icon: Icons.camera_alt_rounded,
            isCurrent: currentStep == 1,
            isComplete: currentStep > 1,
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _StepTile(
            label: 'Marked',
            icon: Icons.check_circle_rounded,
            isCurrent: currentStep == 2,
            isComplete: false,
          ),
        ),
      ),
    ]);
  }
}

class _StepTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCurrent;
  final bool isComplete;

  const _StepTile({
    required this.label,
    required this.icon,
    this.isCurrent = false,
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color fgColor;
    final Color bgColor;

    if (isCurrent) {
      borderColor = ConstColors.primary;
      fgColor = ConstColors.primary;
      bgColor = ConstColors.primary.withValues(alpha: 0.12);
    } else if (isComplete) {
      borderColor = ConstColors.primary.withValues(alpha: 0.45);
      fgColor = ConstColors.primary.withValues(alpha: 0.85);
      bgColor = ConstColors.primary.withValues(alpha: 0.06);
    } else {
      borderColor = Colors.grey.shade400;
      fgColor = Colors.grey.shade500;
      bgColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
