import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// Operational Production Targets Console (Floor View).
/// Displays executive-equivalent targets (Daily 20 TPD, Shift 6,667 kg, Hourly 833 kg)
/// with tactile floor-operations visual dials and segmented shift progression.
class HourlyPacingCard extends StatelessWidget {
  final ProductionMetrics data;

  const HourlyPacingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double hourlyPct = (data.hourlyActualKg / data.hourlyTargetKg).clamp(0.0, 1.25);
    final double shiftPct = (data.shiftActualKg / data.shiftTargetKg).clamp(0.0, 1.0);
    final double dailyTonnes = data.dailyActualKg / 1000.0;
    final double dailyPct = (dailyTonnes / data.plantCapacityTpd).clamp(0.0, 1.0);

    return NeumorphicCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                      '${data.product} • Shift ${data.currentShift} of ${data.shiftsPerDay}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${data.plantCapacityTpd.toInt()} TPD Rating',
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

          // Dual Radial Operational Gauges (Shift Output & Hourly Pacing)
          Row(
            children: [
              // 1. Shift Target Gauge
              Expanded(
                child: _buildOperationalGauge(
                  label: 'Shift Target Progress',
                  actual: '${data.shiftActualKg.toInt()} kg',
                  target: 'Target: ${data.shiftTargetKg.toInt()} kg',
                  percentage: shiftPct,
                  accentColor: AppColors.orange,
                  statusText: 'Shift ${data.currentShift} Live',
                ),
              ),
              const SizedBox(width: 12),

              // 2. Hourly Pacing Gauge
              Expanded(
                child: _buildOperationalGauge(
                  label: 'Hourly Pacing Rate',
                  actual: '${data.hourlyActualKg.toInt()} kg/h',
                  target: 'Target: ${data.hourlyTargetKg.toInt()} kg/h',
                  percentage: (hourlyPct).clamp(0.0, 1.0),
                  accentColor: AppColors.teal,
                  statusText: data.hourlyActualKg >= data.hourlyTargetKg ? 'ON PACE' : 'ACTIVE PACE',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Executive-Equivalent Daily 20 TPD Segmented Shift Tracker
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.insetField(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '20 TPD Daily Cumulative Yield',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${dailyTonnes.toStringAsFixed(2)} / ${data.plantCapacityTpd.toInt()} t (${(dailyPct * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: dailyPct,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shiftMilestone('Shift 1 (Active)', isCurrent: data.currentShift == 1),
                    _shiftMilestone('Shift 2', isCurrent: data.currentShift == 2),
                    _shiftMilestone('Shift 3', isCurrent: data.currentShift == 3),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalGauge({
    required String label,
    required String actual,
    required String target,
    required double percentage,
    required Color accentColor,
    required String statusText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Tactile Circular Arc Gauge
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(76, 76),
                  painter: _CircularGaugePainter(
                    percentage: percentage,
                    color: accentColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Text(
            actual,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            target,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shiftMilestone(String text, {required bool isCurrent}) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent ? AppColors.primaryOrange : AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? AppColors.primaryOrange : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  _CircularGaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc (starts from top -pi/2)
    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularGaugePainter old) =>
      old.percentage != percentage || old.color != color;
}
