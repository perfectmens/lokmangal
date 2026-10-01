import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// 8-hour shift window hourly production line graph.
/// - Full 8-Hour Shift Timeline: Horizontal Target Benchmark spans 100% width.
/// - Live Production Half-Trend: Actual line & area fill cover elapsed hours (e.g. half-width),
///   moving along the timeline as time progresses.
/// - Dynamic Telemetry Teal for actuals, Warm Accent Orange for target line.
class HourlyProductionLineGraphCard extends StatelessWidget {
  final List<ProductionDataPoint> data;
  final ProductionMetrics production;

  const HourlyProductionLineGraphCard({
    super.key,
    required this.data,
    required this.production,
  });

  @override
  Widget build(BuildContext context) {
    final int totalHours = math.max(production.shiftDurationHours, 8);
    final int elapsedHours = data.length;
    final double elapsedPct = (elapsedHours / totalHours).clamp(0.0, 1.0);

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
                child: const Icon(Icons.show_chart_rounded, color: AppColors.telemetryTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hourly Production Pacing', style: AppTypography.heading2),
                    Text(
                      'Shift ${production.currentShift} · $totalHours-hr window · Target: ${production.hourlyTargetKg.toInt()} kg/hr',
                      style: AppTypography.caption.copyWith(color: AppColors.slateGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.telemetryTeal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$elapsedHours of $totalHours hrs (${(elapsedPct * 100).toInt()}%)',
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

          if (data.isNotEmpty)
            SizedBox(
              height: 120,
              child: _ProductionLinePainterWidget(
                points: data,
                totalShiftHours: totalHours,
                targetKg: production.hourlyTargetKg,
              ),
            )
          else
            Container(
              height: 120,
              alignment: Alignment.center,
              child: const Text('Awaiting shift data...', style: TextStyle(color: AppColors.slateGrey)),
            ),

          const SizedBox(height: 14),

          // Legend
          Row(
            children: [
              _legendDot(
                AppColors.telemetryTeal,
                data.isNotEmpty ? 'Live output: ${data.last.actualKg.toInt()} kg/h' : 'Actual output',
              ),
              const Spacer(),
              _legendDash(AppColors.targetLineOrange, 'Target: ${production.hourlyTargetKg.toInt()} kg/h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.telemetryTealGlow,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slateGrey, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _legendDash(Color color, String label) => Row(
        children: [
          Container(
            width: 16,
            height: 2.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slateGrey, fontWeight: FontWeight.w600)),
        ],
      );
}

class _ProductionLinePainterWidget extends StatelessWidget {
  final List<ProductionDataPoint> points;
  final int totalShiftHours;
  final double targetKg;

  const _ProductionLinePainterWidget({
    required this.points,
    required this.totalShiftHours,
    required this.targetKg,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProductionLinePainter(
        points: points,
        totalShiftHours: totalShiftHours,
        targetKg: targetKg,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ProductionLinePainter extends CustomPainter {
  final List<ProductionDataPoint> points;
  final int totalShiftHours;
  final double targetKg;

  _ProductionLinePainter({
    required this.points,
    required this.totalShiftHours,
    required this.targetKg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int totalSlots = math.max(points.length, totalShiftHours);
    final double maxVal = (targetKg * 1.25).ceilToDouble();
    final double minVal = (targetKg * 0.65).floorToDouble();
    final double range = maxVal - minVal;
    final double labelAreaHeight = 18.0;
    final double graphHeight = size.height - labelAreaHeight;

    // Timeline slots step across 100% of card width
    final double xStep = size.width / (totalSlots <= 1 ? 1 : totalSlots - 1);

    // Build 8-hour labels starting from points[0].hour
    int startHour = 8;
    if (points.isNotEmpty) {
      try {
        startHour = int.parse(points.first.hour.split(':')[0]);
      } catch (_) {}
    }
    final List<String> allHours = List.generate(totalSlots, (i) {
      if (i < points.length) {
        return points[i].hour;
      }
      final h = (startHour + i) % 24;
      return '${h.toString().padLeft(2, '0')}:00';
    });

    // --- Baselines & Gridlines: Soft Neumorphic Neutral Grey (#E2E4E9) ---
    final gridPaint = Paint()
      ..color = AppColors.gridGrey
      ..strokeWidth = 1.0;

    // Bottom Baseline
    canvas.drawLine(Offset(0, graphHeight), Offset(size.width, graphHeight), gridPaint);

    // Mid Baseline
    canvas.drawLine(
      Offset(0, graphHeight * 0.5),
      Offset(size.width, graphHeight * 0.5),
      gridPaint..color = AppColors.gridGrey.withValues(alpha: 0.5),
    );

    // --- Full Timeline Horizontal Target Line: Warm Accent Orange (#F68420) dashed ---
    final targetY = graphHeight - ((targetKg - minVal) / range * graphHeight);
    final targetDashPaint = Paint()
      ..color = AppColors.targetLineOrange
      ..strokeWidth = 1.5;

    double dashX = 0;
    while (dashX < size.width) {
      canvas.drawLine(Offset(dashX, targetY), Offset(math.min(dashX + 6, size.width), targetY), targetDashPaint);
      dashX += 11;
    }

    // Target benchmark badge at far right
    final targetTp = TextPainter(
      text: TextSpan(
        text: 'Target ${targetKg.toInt()} kg',
        style: const TextStyle(
          fontSize: 9,
          color: AppColors.targetLineOrange,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    targetTp.paint(canvas, Offset(size.width - targetTp.width - 2, targetY - targetTp.height - 3));

    if (points.isEmpty) return;

    // --- Area Fill: Dynamic Telemetry Teal (#11CFC9) gradient covering elapsed half-trend ---
    final fillPath = Path();
    final linePath = Path();

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = graphHeight - ((points[i].actualKg - minVal) / range * graphHeight);
      if (i == 0) {
        fillPath.moveTo(x, y);
        linePath.moveTo(x, y);
      } else {
        fillPath.lineTo(x, y);
        linePath.lineTo(x, y);
      }
    }

    final double lastX = (points.length - 1) * xStep;
    fillPath.lineTo(lastX, graphHeight);
    fillPath.lineTo(0, graphHeight);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.telemetryTeal.withValues(alpha: 0.24),
            AppColors.telemetryTeal.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, lastX, graphHeight)),
    );

    // --- Actual Line: Dynamic Telemetry Teal (#11CFC9) spanning elapsed hours ---
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.telemetryTeal
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // --- Dots for Elapsed Hours & Live Dot with Pulse Glow ---
    final dotBg = Paint()..color = Colors.white;
    final dotFill = Paint()..color = AppColors.telemetryTeal;

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = graphHeight - ((points[i].actualKg - minVal) / range * graphHeight);
      final bool isLiveDot = (i == points.length - 1);

      if (isLiveDot) {
        // Glowing Pulse Dot (#3311CFC9)
        canvas.drawCircle(Offset(x, y), 8.5, Paint()..color = AppColors.telemetryTealGlow);
        canvas.drawCircle(Offset(x, y), 4.5, dotBg);
        canvas.drawCircle(Offset(x, y), 3.0, dotFill);

        // Live reading readout above live dot
        final liveValTp = TextPainter(
          text: TextSpan(
            text: '${points[i].actualKg.toInt()} kg',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.telemetryTeal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        liveValTp.paint(canvas, Offset(x - liveValTp.width / 2, y - liveValTp.height - 6));
      } else {
        canvas.drawCircle(Offset(x, y), 3.5, dotBg);
        canvas.drawCircle(Offset(x, y), 2.2, dotFill);
      }
    }

    // --- Upcoming Hour Slot Markers on Target Line ---
    for (int i = points.length; i < totalSlots; i++) {
      final double x = i * xStep;
      canvas.drawCircle(
        Offset(x, targetY),
        2.5,
        Paint()..color = AppColors.targetLineOrange.withValues(alpha: 0.4),
      );
    }

    // --- Bottom X-Axis Hour Labels (Full 8-Hour Shift Timeline) ---
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < totalSlots; i++) {
      final double x = i * xStep;
      final bool isElapsed = i < points.length;
      final bool isLive = i == points.length - 1;

      tp.text = TextSpan(
        text: allHours[i],
        style: TextStyle(
          fontSize: 9.5,
          color: isLive
              ? AppColors.telemetryTeal
              : (isElapsed ? AppColors.textPrimary : AppColors.slateGrey.withValues(alpha: 0.6)),
          fontWeight: isLive ? FontWeight.w800 : (isElapsed ? FontWeight.w600 : FontWeight.w500),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - labelAreaHeight + 4));
    }
  }

  @override
  bool shouldRepaint(_ProductionLinePainter old) =>
      old.points != points || old.totalShiftHours != totalShiftHours || old.targetKg != targetKg;
}
