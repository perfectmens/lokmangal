import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

class NeumorphicDial extends StatelessWidget {
  final double value; // current value
  final double min;
  final double max;
  final String unit;
  final String title;
  final double size;

  const NeumorphicDial({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.unit,
    required this.title,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    final double fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: AppShadows.raised(blur: 12, offset: const Offset(5, 5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer track
              CustomPaint(
                size: Size(size * 0.85, size * 0.85),
                painter: _DialArcPainter(
                  fraction: fraction,
                  trackColor: AppColors.background,
                  arcColor: AppColors.teal,
                ),
              ),
              // Inner recessed circle
              Container(
                width: size * 0.58,
                height: size * 0.58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppShadows.circularButton(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: AppTypography.heading2.copyWith(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      unit,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DialArcPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color arcColor;

  _DialArcPainter({
    required this.fraction,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw 240 degree arc from 150 to 390
    const startAngle = 150 * (pi / 180);
    const sweepAngle = 240 * (pi / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * fraction,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DialArcPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.arcColor != arcColor;
}
