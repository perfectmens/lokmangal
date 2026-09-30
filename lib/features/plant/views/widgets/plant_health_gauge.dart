import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class PlantHealthGauge extends StatelessWidget {
  final double score;
  final PlantHealthBreakdown breakdown;
  final VoidCallback onTap;

  const PlantHealthGauge({
    super.key,
    required this.score,
    required this.breakdown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.circularButton(),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular arc indicator
            CustomPaint(
              size: const Size(74, 74),
              painter: _GaugePainter(score: score),
            ),
            // Center content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🏭',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${score.toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.15)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.teal, Color(0xFF00E5FF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
