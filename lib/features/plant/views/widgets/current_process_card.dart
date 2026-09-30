import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class CurrentProcessCard extends StatelessWidget {
  final PowderMakerState powderMaker;
  final VoidCallback onDrilldown;

  const CurrentProcessCard({
    super.key,
    required this.powderMaker,
    required this.onDrilldown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDrilldown,
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      powderMaker.stateDisplayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Batch #${powderMaker.batchNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Weight & Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${powderMaker.currentWeightKg.toInt()} kg / ${powderMaker.targetWeightKg.toInt()} kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${powderMaker.progressPercent.toInt()}%',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (powderMaker.progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            ),
            const SizedBox(height: 14),

            // Metrics row: Elapsed, Target, Current Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubMetric('Elapsed', '${powderMaker.elapsedMinutes.toInt()} min'),
                _buildSubMetric('Cycle Target', '${powderMaker.targetCycleMinutes.toInt()} min'),
                _buildSubMetric('Current Rate', '${powderMaker.currentRateKgH.toInt()} kg/h'),
                Row(
                  children: [
                    const Text('Drilldown', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.teal),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
