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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Plant Design Capacity', style: AppTypography.heading2),
                    Text(
                      '${data.product} • ${data.plantCapacityTpd.toInt()} TPD Rating',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  '${data.shiftsPerDay} Shifts/Day',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 20 TPD Yield Metric
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

          // Operational Targets Summary with Realtime Produced KG
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Shift Target & Actual',
                  actualValue: '${data.shiftActualKg.toInt()} kg',
                  targetText: 'Target: ${data.shiftTargetKg.toInt()} kg',
                  subtext: '${data.shiftDurationHours}h · ${((data.shiftActualKg / data.shiftTargetKg) * 100).toStringAsFixed(1)}%',
                  color: AppColors.teal,
                  isLive: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Hourly Target & Actual',
                  actualValue: '${data.hourlyActualKg.toInt()} kg/h',
                  targetText: 'Target: ${data.hourlyTargetKg.toInt()} kg/h',
                  subtext: 'Pacing · ${((data.hourlyActualKg / data.hourlyTargetKg) * 100).toStringAsFixed(1)}%',
                  color: AppColors.orange,
                  isLive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String actualValue,
    required String targetText,
    required String subtext,
    required Color color,
    bool isLive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0A0D2F),
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            actualValue,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            targetText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
