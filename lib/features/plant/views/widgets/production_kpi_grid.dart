import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class ProductionKPIGrid extends StatelessWidget {
  final ProductionSummary production;

  const ProductionKPIGrid({super.key, required this.production});

  @override
  Widget build(BuildContext context) {
    final rateTargetPct = (production.hourlyRateKgH / production.hourlyTargetKgH * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'PRODUCTION KPIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'TODAY',
                primaryValue: '${production.todayKg.toInt()} kg',
                subValue: '${production.dailyTargetPercent.toStringAsFixed(1)}% of 20T Target',
                accentColor: AppColors.teal,
                icon: Icons.calendar_today_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'RATE',
                primaryValue: '${production.hourlyRateKgH.toInt()} kg/h',
                subValue: '$rateTargetPct% (Target: ${production.hourlyTargetKgH.toInt()})',
                accentColor: production.hourlyRateKgH >= production.hourlyTargetKgH
                    ? AppColors.teal
                    : AppColors.orange,
                icon: Icons.speed_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'SHIFT ${production.currentShift}',
                primaryValue: '${production.shiftKg.toInt()} kg',
                subValue: '/ ${production.shiftTargetKg.toInt()} kg Target',
                accentColor: AppColors.teal,
                icon: Icons.timelapse_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'ENERGY',
                primaryValue: '${production.energyKwh.toInt()} kWh',
                subValue: '/ ${production.energyBudgetKwh.toInt()} kWh Limit',
                accentColor: AppColors.orange,
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String primaryValue,
    required String subValue,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            primaryValue,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
