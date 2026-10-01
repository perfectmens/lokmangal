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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Electricity Consumption Caps', style: AppTypography.heading2),
                    Text(
                      'Hourly, Shift & Daily Max Limits',
                      style: AppTypography.caption,
                    ),
                  ],
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
          ),
          const SizedBox(height: 14),

          // Shift Quota (1074 kWh max)
          _buildQuotaRow(
            label: 'Shift Cumulative',
            current: data.shiftKwh,
            max: data.shiftMaxKwh,
            pct: shiftPct,
          ),
          const SizedBox(height: 14),

          // Daily Quota (3221 kWh max)
          _buildQuotaRow(
            label: 'Daily Cumulative',
            current: data.dailyKwh,
            max: data.dailyMaxKwh,
            pct: dailyPct,
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
            RichText(
              text: TextSpan(
                text: '${current.toStringAsFixed(1)} / ${max.toInt()} kWh ',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: '(${(pct * 100).toInt()}%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
                ],
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
