import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

class HourlyPacingCard extends StatelessWidget {
  final ProductionMetrics data;

  const HourlyPacingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double hourlyPct = (data.hourlyActualKg / data.hourlyTargetKg).clamp(0.0, 1.0);
    final double shiftPct = (data.shiftActualKg / data.shiftTargetKg).clamp(0.0, 1.0);

    return NeumorphicCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppShadows.circularButton(),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: AppColors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Production Targets', style: AppTypography.heading2),
                    Text(
                      '${data.product} • ${data.shiftDurationHours}h Shift Pace',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hourly Pace (833 kg target)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hourly Output: ${data.hourlyActualKg.toStringAsFixed(0)} kg',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              Text(
                'Target: ${data.hourlyTargetKg.toInt()} kg/hr (${(hourlyPct * 100).toInt()}%)',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hourlyPct,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 14),

          // Shift Pace (6667 kg target)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shift Output: ${data.shiftActualKg.toStringAsFixed(0)} kg',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              Text(
                'Target: ${data.shiftTargetKg.toInt()} kg (${(shiftPct * 100).toInt()}%)',
                style: const TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: shiftPct,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
