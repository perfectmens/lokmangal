import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

class ElectricityQuotaCard extends StatelessWidget {
  final ElectricityMetrics data;

  const ElectricityQuotaCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double hourlyPct = (data.hourlyKwh / data.hourlyMaxKwh).clamp(0.0, 1.0);
    final double shiftPct = (data.shiftKwh / data.shiftMaxKwh).clamp(0.0, 1.0);
    final double dailyPct = (data.dailyKwh / data.dailyMaxKwh).clamp(0.0, 1.0);

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
                  Icons.bolt_rounded,
                  color: AppColors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Electricity Quota & Power', style: AppTypography.heading2),
                    Text(
                      'Live Demand: ${data.currentPowerKw.toStringAsFixed(1)} kW',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
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
                child: Text(
                  'SEC: ${data.specificEnergyConsumption.toStringAsFixed(3)} kWh/kg',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Hourly Quota (134 kWh max)
          _buildQuotaRow(
            label: 'Hourly Consumption',
            current: data.hourlyKwh,
            max: data.hourlyMaxKwh,
            pct: hourlyPct,
            unit: 'kWh',
          ),
          const SizedBox(height: 12),

          // Shift Quota (1074 kWh max)
          _buildQuotaRow(
            label: 'Shift Cumulative',
            current: data.shiftKwh,
            max: data.shiftMaxKwh,
            pct: shiftPct,
            unit: 'kWh',
          ),
          const SizedBox(height: 12),

          // Daily Quota (3221 kWh max)
          _buildQuotaRow(
            label: 'Daily Cumulative',
            current: data.dailyKwh,
            max: data.dailyMaxKwh,
            pct: dailyPct,
            unit: 'kWh',
          ),

          const SizedBox(height: 14),

          // Energy Efficiency Benchmark Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.insetField(),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, size: 16, color: AppColors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Energy efficiency is within optimal band (< 0.185 kWh/kg standard benchmark).',
                    style: AppTypography.caption.copyWith(fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaRow({
    required String label,
    required double current,
    required double max,
    required double pct,
    required String unit,
  }) {
    final bool isNearLimit = pct > 0.85;
    final Color barColor = isNearLimit ? AppColors.orange : AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)} / ${max.toInt()} $unit (${(pct * 100).toInt()}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}
