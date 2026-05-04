import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';

class GeofenceStatusWidget extends StatelessWidget {
  final bool isInside;
  final double distanceMeters;
  final String schoolName;
  final VoidCallback onPrimaryAction;
  final String primaryLabel;
  final VoidCallback onRetry;

  const GeofenceStatusWidget({
    super.key,
    required this.isInside,
    required this.distanceMeters,
    required this.schoolName,
    required this.onPrimaryAction,
    required this.primaryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDistance = distanceMeters.toStringAsFixed(0);
    final color = isInside ? Colors.green : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isInside ? Icons.verified_rounded : Icons.location_off_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isInside
                      ? 'Inside school - ${formattedDistance}m from center'
                      : 'You are ${formattedDistance}m away from school',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            schoolName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isInside
                ? 'You can continue to face verification.'
                : 'Please move within the school compound to mark attendance.',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(primaryLabel),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
