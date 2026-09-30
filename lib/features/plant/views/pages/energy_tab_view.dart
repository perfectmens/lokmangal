import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../viewmodels/plant_viewmodel.dart';

class EnergyTabView extends StatelessWidget {
  const EnergyTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final e = vm.energy;

    final hourlyPct = (e.hourlyKwh / e.hourlyLimitKwh).clamp(0.0, 1.0);
    final shiftPct = (e.shiftKwh / e.shiftLimitKwh).clamp(0.0, 1.0);
    final dayPct = (e.dailyKwh / e.dailyLimitKwh).clamp(0.0, 1.0);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 96.0,
        bottom: 100.0,
        left: 16.0,
        right: 16.0,
      ),
      children: [
        // Live Power Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LIVE POWER DEMAND',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: AppColors.orange),
                        SizedBox(width: 4),
                        Text(
                          'GRID ONLINE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Large Live kW display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${e.livePowerKw.toInt()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'kW',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Power limit threshold: 134 kW',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Efficiency metric
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPECIFIC ENERGY EFFICIENCY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Normalized per kg produced',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${e.efficiencyKwhPerKg.toStringAsFixed(2)} kWh/kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Limits Progress Bars
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'STATUTORY & PLANT LIMITS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              _buildLimitRow('Hourly Limit', e.hourlyKwh, e.hourlyLimitKwh, hourlyPct),
              const SizedBox(height: 14),
              _buildLimitRow('Shift Limit', e.shiftKwh, e.shiftLimitKwh, shiftPct),
              const SizedBox(height: 14),
              _buildLimitRow('Daily Limit', e.dailyKwh, e.dailyLimitKwh, dayPct),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Hourly Trend Bars
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HOURLY CONSUMPTION TREND (kWh)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: e.hourlyTrend.map((point) {
                  final barHeight = (point.kwh / 134.0 * 80.0).clamp(10.0, 80.0);
                  return Column(
                    children: [
                      Text(
                        '${point.kwh.toInt()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        point.hour,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimitRow(String label, double actual, double limit, double pct) {
    final bool isWarning = pct > 0.85;
    final color = isWarning ? AppColors.orange : AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            Text(
              '${actual.toInt()} / ${limit.toInt()} kWh (${(pct * 100).toInt()}%)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
