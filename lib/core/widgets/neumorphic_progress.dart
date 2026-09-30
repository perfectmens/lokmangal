import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

class NeumorphicProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color progressColor;

  const NeumorphicProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.progressColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AppTypography.caption),
              Text(
                '${(clampedProgress * 100).toStringAsFixed(1)}%',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(6),
            boxShadow: AppShadows.pill(isSelected: true),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
