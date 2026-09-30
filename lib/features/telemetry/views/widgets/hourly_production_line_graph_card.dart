import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// 8-hour shift window hourly production line graph.
/// Teal line = actual output. Dashed teal line = target (833 kg/hr).
/// All data is backend-owned — no frontend logic.
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
                child: const Icon(Icons.show_chart_rounded, color: AppColors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hourly Production', style: AppTypography.heading2),
                    Text(
                      'Shift ${production.currentShift} · 8-hr window · Target: ${production.hourlyTargetKg.toInt()} kg/hr',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (data.isNotEmpty)
            SizedBox(
              height: 100,
              child: _ProductionLinePainterWidget(points: data),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              child: const Text('Awaiting shift data...', style: TextStyle(color: AppColors.textMuted)),
            ),

          const SizedBox(height: 10),

          // Legend
          Row(
            children: [
              _legendDot(AppColors.teal, 'Actual output'),
              const SizedBox(width: 16),
              _legendDash(AppColors.teal.withValues(alpha: 0.5), 'Target (${production.hourlyTargetKg.toInt()} kg/hr)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        ],
      );

  Widget _legendDash(Color color, String label) => Row(
        children: [
          Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
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
    final double maxVal = (targetKg * 1.2).ceilToDouble();
    final double minVal = (targetKg * 0.7).floorToDouble();
    final double range = maxVal - minVal;
    final double labelAreaHeight = 14.0;
    final double graphHeight = size.height - labelAreaHeight;

    double xStep = size.width / (points.length <= 1 ? 1 : points.length - 1);

    // --- Target dashed line ---
    final targetY = graphHeight - ((targetKg - minVal) / range * graphHeight);
    final dashPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.45)
      ..strokeWidth = 1.2;
    double dashX = 0;
    while (dashX < size.width) {
      canvas.drawLine(Offset(dashX, targetY), Offset(dashX + 7, targetY), dashPaint);
      dashX += 12;
    }

    // --- Actual line + fill ---
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
          colors: [AppColors.teal.withValues(alpha: 0.15), AppColors.teal.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, graphHeight)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.teal
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // --- Dots + labels ---
    final dotFill = Paint()..color = AppColors.teal;
    final dotBg = Paint()..color = Colors.white;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      final double x = i * xStep;
      final double y = graphHeight - ((points[i].actualKg - minVal) / range * graphHeight);
      canvas.drawCircle(Offset(x, y), 4.0, dotBg);
      canvas.drawCircle(Offset(x, y), 2.5, dotFill);

      // Hour label below
      tp.text = TextSpan(
        text: points[i].hour,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w500),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - labelAreaHeight));
    }
  }

  @override
  bool shouldRepaint(_ProductionLinePainter old) => old.points != points;
}
