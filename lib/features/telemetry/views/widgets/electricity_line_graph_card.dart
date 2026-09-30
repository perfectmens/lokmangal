import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// Minimal line graph showing hourly kWh consumption for the current shift.
/// - Target Line & Area Fill: Warm Accent Orange (#F68420 / #F6A560)
/// - Actual Line & Live Dot: Dynamic Telemetry Teal (#11CFC9 with #3311CFC9 pulse glow)
/// - Target Labels & Units: Muted Slate Grey (#8C929C)
/// - Gridlines & Baselines: Soft Neumorphic Neutral Grey (#E2E4E9)
class ElectricityLineGraphCard extends StatelessWidget {
  final ElectricityMetrics data;

  const ElectricityLineGraphCard({super.key, required this.data});

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
                child: const Icon(Icons.bolt_rounded, color: AppColors.targetLineOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Electricity Consumption', style: AppTypography.heading2),
                    Text(
                      'Shift trend  •  Limit: ${data.hourlyMaxKwh.toInt()} kWh/hr',
                      style: AppTypography.caption.copyWith(color: AppColors.slateGrey),
                    ),
                  ],
                ),
              ),
              // Live reading badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.targetLineOrange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${data.hourlyKwh.toStringAsFixed(1)} kWh',
                  style: const TextStyle(
                    color: AppColors.targetLineOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Line Graph
          if (data.hourlyKwhHistory.isNotEmpty)
            SizedBox(
              height: 100,
              child: _KwhLineGraph(
                points: data.hourlyKwhHistory,
                limitKwh: data.hourlyMaxKwh,
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              child: const Text('Awaiting data...', style: TextStyle(color: AppColors.slateGrey)),
            ),

          const SizedBox(height: 12),

          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statPill('Shift', '${data.shiftKwh.toStringAsFixed(0)} / ${data.shiftMaxKwh.toInt()} kWh', AppColors.telemetryTeal),
              _statPill('Daily', '${data.dailyKwh.toStringAsFixed(0)} / ${data.dailyMaxKwh.toInt()} kWh', AppColors.targetLineOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x120A0D2F), offset: Offset(3, 3), blurRadius: 6),
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.slateGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _KwhLineGraph extends StatelessWidget {
  final List<KwhDataPoint> points;
  final double limitKwh;

  const _KwhLineGraph({required this.points, required this.limitKwh});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _KwhLinePainter(points: points, limitKwh: limitKwh),
      child: const SizedBox.expand(),
    );
  }
}

class _KwhLinePainter extends CustomPainter {
  final List<KwhDataPoint> points;
  final double limitKwh;

  _KwhLinePainter({required this.points, required this.limitKwh});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double maxVal = (limitKwh * 1.15);
    final double minVal = 0.0;
    final double range = maxVal - minVal;
    final double labelAreaHeight = 16.0;
    final double graphHeight = size.height - labelAreaHeight;

    double xStep = size.width / (points.length - 1 == 0 ? 1 : points.length - 1);

    // --- Gridlines & Baselines: Soft Neumorphic Neutral Grey (#E2E4E9) ---
    final gridPaint = Paint()
      ..color = AppColors.gridGrey
      ..strokeWidth = 1.0;

    // Bottom Baseline
    canvas.drawLine(Offset(0, graphHeight), Offset(size.width, graphHeight), gridPaint);

    // Mid Baseline
    canvas.drawLine(Offset(0, graphHeight * 0.5), Offset(size.width, graphHeight * 0.5),
        gridPaint..color = AppColors.gridGrey.withValues(alpha: 0.5));

    // --- Target/Limit Dotted Line: Warm Accent Orange (#F68420) ---
    final limitY = graphHeight - ((limitKwh - minVal) / range * graphHeight);
    final dashPaint = Paint()
      ..color = AppColors.targetLineOrange
      ..strokeWidth = 1.2;
    double dashX = 0;
    while (dashX < size.width) {
      canvas.drawLine(Offset(dashX, limitY), Offset(dashX + 6, limitY), dashPaint);
      dashX += 10;
    }

    // Limit label in Muted Slate Grey (#8C929C)
    final limitTp = TextPainter(
      text: TextSpan(
        text: 'Limit ${limitKwh.toInt()} kWh',
        style: const TextStyle(fontSize: 8.5, color: AppColors.slateGrey, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    limitTp.paint(canvas, Offset(size.width - limitTp.width - 2, limitY - limitTp.height - 2));

    // --- Area Fill: Warm Accent Orange (#F6A560) gradient ---
    final fillPath = Path();
    final linePath = Path();

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = graphHeight - ((points[i].kwh - minVal) / range * graphHeight);
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

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.targetAreaFillOrange.withValues(alpha: 0.22),
          AppColors.targetAreaFillOrange.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, graphHeight));
    canvas.drawPath(fillPath, fillPaint);

    // --- Actual Line: Dynamic Telemetry Teal (#11CFC9) ---
    final linePaint = Paint()
      ..color = AppColors.telemetryTeal
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // --- Dots & Live Dot with Pulse Glow (#3311CFC9) ---
    final dotPaint = Paint()..color = AppColors.telemetryTeal;
    final dotBg = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = graphHeight - ((points[i].kwh - minVal) / range * graphHeight);
      final bool isLiveDot = (i == points.length - 1);

      if (isLiveDot) {
        // Live Dot Pulse Glow (#3311CFC9)
        canvas.drawCircle(Offset(x, y), 8.0, Paint()..color = AppColors.telemetryTealGlow);
        canvas.drawCircle(Offset(x, y), 4.5, dotBg);
        canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
      } else {
        canvas.drawCircle(Offset(x, y), 3.5, dotBg);
        canvas.drawCircle(Offset(x, y), 2.2, dotPaint);
      }
    }

    // --- Hour Labels in Muted Slate Grey (#8C929C) ---
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final bool isLiveDot = (i == points.length - 1);
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
  bool shouldRepaint(_KwhLinePainter old) => old.points != points;
}
