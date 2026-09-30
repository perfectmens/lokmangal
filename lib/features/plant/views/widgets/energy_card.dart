import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class EnergyCard extends StatelessWidget {
  final EnergyOverview energy;
  final VoidCallback onDrilldown;

  const EnergyCard({
    super.key,
    required this.energy,
    required this.onDrilldown,
  });

  @override
  Widget build(BuildContext context) {
    final shiftPct = (energy.shiftKwh / energy.shiftLimitKwh).clamp(0.0, 1.0);
    final dayPct = (energy.dailyKwh / energy.dailyLimitKwh).clamp(0.0, 1.0);

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
                const Text(
                  'ENERGY CONSUMPTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.textMuted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.electric_bolt_rounded, size: 14, color: AppColors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${energy.livePowerKw.toInt()} kW LIVE',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Specific consumption efficiency (kWh/kg)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specific Efficiency',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Normalized energy per kg of jaggery',
                        style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Text(
                    '${energy.efficiencyKwhPerKg.toStringAsFixed(2)} kWh/kg',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Shift Energy Limit Bar
            _buildLimitBar(
              label: 'Shift Energy Usage',
              current: energy.shiftKwh,
              limit: energy.shiftLimitKwh,
              pct: shiftPct,
              color: shiftPct > 0.9 ? AppColors.orange : AppColors.teal,
            ),
            const SizedBox(height: 10),

            // Daily Energy Limit Bar
            _buildLimitBar(
              label: 'Daily Energy Budget',
              current: energy.dailyKwh,
              limit: energy.dailyLimitKwh,
              pct: dayPct,
              color: dayPct > 0.9 ? AppColors.orange : AppColors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitBar({
    required String label,
    required double current,
    required double limit,
    required double pct,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Text(
              '${current.toInt()} / ${limit.toInt()} kWh (${(pct * 100).toInt()}%)',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
