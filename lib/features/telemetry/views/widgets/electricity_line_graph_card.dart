import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// Minimal line graph showing hourly kWh consumption for the current shift.
/// All data points are backend-owned — this widget only renders.
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
                child: const Icon(Icons.bolt_rounded, color: AppColors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Electricity Consumption', style: AppTypography.heading2),
                    Text(
                      'Shift trend  •  Limit: ${data.hourlyMaxKwh.toInt()} kWh/hr',
                      style: AppTypography.caption,
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
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${data.hourlyKwh.toStringAsFixed(1)} kWh',
                  style: const TextStyle(
                    color: AppColors.orange,
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
              height: 90,
              child: _KwhLineGraph(
                points: data.hourlyKwhHistory,
                limitKwh: data.hourlyMaxKwh,
              ),
            )
          else
            Container(
              height: 90,
              alignment: Alignment.center,
              child: const Text('Awaiting data...', style: TextStyle(color: AppColors.textMuted)),
            ),

          const SizedBox(height: 12),

          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statPill('Shift', '${data.shiftKwh.toStringAsFixed(0)} / ${data.shiftMaxKwh.toInt()} kWh', AppColors.teal),
              _statPill('Daily', '${data.dailyKwh.toStringAsFixed(0)} / ${data.dailyMaxKwh.toInt()} kWh', AppColors.orange),
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
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
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

    final double maxVal = (limitKwh * 1.1);
    final double minVal = 0.0;
    final double range = maxVal - minVal;

    double xStep = size.width / (points.length - 1 == 0 ? 1 : points.length - 1);

    // Gradient fill path
    final fillPath = Path();
    final linePath = Path();

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = size.height - ((points[i].kwh - minVal) / range * size.height);
      if (i == 0) {
        fillPath.moveTo(x, y);
        linePath.moveTo(x, y);
      } else {
        fillPath.lineTo(x, y);
        linePath.lineTo(x, y);
      }
    }

    fillPath.lineTo((points.length - 1) * xStep, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.orange.withValues(alpha: 0.18),
          AppColors.orange.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = AppColors.orange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Draw limit dotted line
    final limitY = size.height - ((limitKwh - minVal) / range * size.height);
    final dashPaint = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    double dashX = 0;
    while (dashX < size.width) {
      canvas.drawLine(Offset(dashX, limitY), Offset(dashX + 6, limitY), dashPaint);
      dashX += 10;
    }

    // Draw dots at each point
    final dotPaint = Paint()..color = AppColors.orange;
    final dotBg = Paint()..color = Colors.white;
    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = size.height - ((points[i].kwh - minVal) / range * size.height);
      canvas.drawCircle(Offset(x, y), 4.0, dotBg);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }

    // Draw hour labels on x-axis
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      tp.text = TextSpan(
        text: points[i].hour,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_KwhLinePainter old) => old.points != points;
}
