import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

class PowderMakerCard extends StatelessWidget {
  final PowderMakerData data;

  const PowderMakerCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double pct = (data.batchCurrentKg / data.batchCapacityKg).clamp(0.0, 1.0);
    final int pctInt = (pct * 100).toInt();

    return NeumorphicCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
                  Icons.blender_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Powder Maker', style: AppTypography.heading2),
                    Text(
                      'Batch Capacity: ${data.batchCapacityKg.toInt()} kg • 5-Stage Automation',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  data.status.displayName,
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 5-Stage Horizontal Flow Stepper
          _buildStageStepper(),

          const SizedBox(height: 18),

          // Batch Weight & Load Cell Scale
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batch Load Cell: ${data.batchCurrentKg.toStringAsFixed(1)} kg',
                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$pctInt% filled',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Neumorphic Recessed Progress Bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
              boxShadow: AppShadows.insetField(),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, Color(0xFF38E5DE)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3311CFC9),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Footer Metrics: Cycle timer & batches completed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Cycle: ${_formatSeconds(data.batchCycleSeconds)}',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Today: ${data.completedBatchesToday} Batches Done',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageStepper() {
    final stages = PowderMakerStatus.values;
    final int activeIndex = stages.indexOf(data.status);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            final stage = stages[index];
            final bool isPassed = index < activeIndex;
            final bool isCurrent = index == activeIndex;

            Color bgColor;
            Color textColor;
            List<BoxShadow> shadows;

            if (isCurrent) {
              bgColor = AppColors.surface;
              textColor = AppColors.teal;
              shadows = [];
            } else if (isPassed) {
              bgColor = AppColors.teal.withValues(alpha: 0.1);
              textColor = AppColors.teal;
              shadows = [];
            } else {
              bgColor = AppColors.surface;
              textColor = AppColors.textMuted;
              shadows = const [
                BoxShadow(
                  color: Color(0x100A0D2F),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-2, -2),
                  blurRadius: 4,
                ),
              ];
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: isCurrent
                        ? Border.all(color: AppColors.teal, width: 1.5)
                        : null,
                    boxShadow: shadows,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isPassed
                            ? Icons.check_circle_rounded
                            : isCurrent
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                        size: 14,
                        color: textColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stageShortName(stage),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  static String _stageShortName(PowderMakerStatus s) {
    switch (s) {
      case PowderMakerStatus.systemReady:
        return 'Ready';
      case PowderMakerStatus.mixing:
        return 'Mixing';
      case PowderMakerStatus.crystallization:
        return 'Cryst.';
      case PowderMakerStatus.powderMaking:
        return 'Powder';
      case PowderMakerStatus.discharge:
        return 'Discharge';
    }
  }

  static String _formatSeconds(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} min';
  }
}
