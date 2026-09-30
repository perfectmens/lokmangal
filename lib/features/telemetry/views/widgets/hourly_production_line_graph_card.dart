import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// 8-hour shift window hourly production line graph.
/// - Target Line & Area Fill: Warm Accent Orange (#F68420 / #F6A560)
/// - Actual Line & Live Dot: Dynamic Telemetry Teal (#11CFC9 with #3311CFC9 pulse glow)
/// - Target Labels & Units: Muted Slate Grey (#8C929C)
/// - Gridlines & Baselines: Soft Neumorphic Neutral Grey (#E2E4E9)
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
                    const Text('Hourly Production', style: AppTypography.heading2),
                    Text(
                      'Shift ${production.currentShift} · 8-hr window · Target: ${production.hourlyTargetKg.toInt()} kg/hr',
                      style: AppTypography.caption.copyWith(color: AppColors.slateGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (data.isNotEmpty)
            SizedBox(
              height: 110,
              child: _ProductionLinePainterWidget(points: data),
            )
          else
            Container(
              height: 110,
              alignment: Alignment.center,
              child: const Text('Awaiting shift data...', style: TextStyle(color: AppColors.slateGrey)),
            ),

          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _legendDot(AppColors.telemetryTeal, 'Actual output'),
              const SizedBox(width: 16),
              _legendDash(AppColors.targetLineOrange, 'Target (${production.hourlyTargetKg.toInt()} kg/hr)'),
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
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slateGrey, fontWeight: FontWeight.w500)),
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
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slateGrey, fontWeight: FontWeight.w500)),
        ],
      );
}

class _ProductionLinePainterWidget extends StatelessWidget {
  final List<ProductionDataPoint> points;
  const _ProductionLinePainterWidget({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProductionLinePainter(points: points),
      child: const SizedBox.expand(),
    );
  }
}

class _ProductionLinePainter extends CustomPainter {
  final List<ProductionDataPoint> points;

  _ProductionLinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double targetKg = points.first.targetKg;
    final double maxVal = (targetKg * 1.25).ceilToDouble();
    final double minVal = (targetKg * 0.65).floorToDouble();
    final double range = maxVal - minVal;
    final double labelAreaHeight = 16.0;
    final double graphHeight = size.height - labelAreaHeight;

    double xStep = size.width / (points.length <= 1 ? 1 : points.length - 1);

    // --- Baselines & Gridlines: Soft Neumorphic Neutral Grey (#E2E4E9) ---
    final gridPaint = Paint()
      ..color = AppColors.gridGrey
      ..strokeWidth = 1.0;

    // Bottom Baseline
    canvas.drawLine(Offset(0, graphHeight), Offset(size.width, graphHeight), gridPaint);

    // Mid Baseline
    canvas.drawLine(Offset(0, graphHeight * 0.5), Offset(size.width, graphHeight * 0.5),
        gridPaint..color = AppColors.gridGrey.withValues(alpha: 0.5));

    // --- Target Line: Warm Accent Orange (#F68420) dashed ---
    final targetY = graphHeight - ((targetKg - minVal) / range * graphHeight);
    final targetDashPaint = Paint()
      ..color = AppColors.targetLineOrange
      ..strokeWidth = 1.5;
    double dashX = 0;
    while (dashX < size.width) {
      canvas.drawLine(Offset(dashX, targetY), Offset(dashX + 6, targetY), targetDashPaint);
      dashX += 11;
    }

    // Target label at right
    final targetTp = TextPainter(
      text: TextSpan(
        text: '${targetKg.toInt()} kg',
        style: const TextStyle(fontSize: 9, color: AppColors.slateGrey, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    targetTp.paint(canvas, Offset(size.width - targetTp.width - 2, targetY - targetTp.height - 2));

    // --- Area Fill: Warm Accent Orange (#F6A560) gradient ---
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
    fillPath.lineTo((points.length - 1) * xStep, graphHeight);
    fillPath.lineTo(0, graphHeight);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.targetAreaFillOrange.withValues(alpha: 0.24),
            AppColors.targetAreaFillOrange.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, graphHeight)),
    );

    // --- Actual Line: Dynamic Telemetry Teal (#11CFC9) ---
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.telemetryTeal
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // --- Dots & Live Dot with Pulse Glow (#3311CFC9) ---
    final dotBg = Paint()..color = Colors.white;
    final dotFill = Paint()..color = AppColors.telemetryTeal;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = graphHeight - ((points[i].actualKg - minVal) / range * graphHeight);
      final bool isLiveDot = (i == points.length - 1);

      if (isLiveDot) {
        // Live Dot Pulse Glow (#3311CFC9)
        canvas.drawCircle(Offset(x, y), 8.0, Paint()..color = AppColors.telemetryTealGlow);
        canvas.drawCircle(Offset(x, y), 4.5, dotBg);
        canvas.drawCircle(Offset(x, y), 3.0, dotFill);
      } else {
        canvas.drawCircle(Offset(x, y), 3.5, dotBg);
        canvas.drawCircle(Offset(x, y), 2.2, dotFill);
      }

      // Hour label below in Muted Slate Grey (#8C929C)
      tp.text = TextSpan(
        text: points[i].hour,
        style: TextStyle(
          fontSize: 9.5,
          color: isLiveDot ? AppColors.telemetryTeal : AppColors.slateGrey,
          fontWeight: isLiveDot ? FontWeight.bold : FontWeight.w500,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - labelAreaHeight + 2));
    }
  }

  @override
  bool shouldRepaint(_ProductionLinePainter old) => old.points != points;
}
