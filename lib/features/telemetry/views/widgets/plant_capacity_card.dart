import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

class PlantCapacityCard extends StatelessWidget {
  final ProductionMetrics data;

  const PlantCapacityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double dailyTonnes = data.dailyActualKg / 1000.0;
    final double capacityPct = (dailyTonnes / data.plantCapacityTpd).clamp(0.0, 1.0);
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
                  Icons.insights_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Executive Capacity Scorecard', style: AppTypography.heading2),
                    Text(
                      'Plant Rating: 20 TPD (3 Shifts/Day)',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OEE: 94.6%',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Big 20 TPD Yield Metric
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.insetField(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Cumulative Yield',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(capacityPct * 100).toStringAsFixed(1)}% of 20 TPD',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      dailyTonnes.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ ${data.plantCapacityTpd.toInt()} Tonnes/Day',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: capacityPct,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Shift 1, 2, 3 Breakdown
          Row(
            children: [
              Expanded(
                child: _buildShiftTile(
                  shiftNumber: 1,
                  actualKg: data.shiftActualKg,
                  targetKg: data.shiftTargetKg,
                  pct: shiftPct,
                  isActive: data.shiftNumber == 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShiftTile(
                  shiftNumber: 2,
                  actualKg: 0,
                  targetKg: data.shiftTargetKg,
                  pct: 0,
                  isActive: data.shiftNumber == 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShiftTile(
                  shiftNumber: 3,
                  actualKg: 0,
                  targetKg: data.shiftTargetKg,
                  pct: 0,
                  isActive: data.shiftNumber == 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTile({
    required int shiftNumber,
    required double actualKg,
    required double targetKg,
    required double pct,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: AppColors.orange, width: 1.2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x100A0D2F),
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Shift $shiftNumber',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.orange : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isActive ? '${(actualKg / 1000).toStringAsFixed(1)} T' : 'Pending',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Target: ${(targetKg / 1000).toStringAsFixed(1)} T',
            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
