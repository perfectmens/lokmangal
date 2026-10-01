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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Powder Maker', style: AppTypography.heading2),
                    Text('500 kg batch capacity', style: AppTypography.caption),
                  ],
                ),
              ),
              // Current Status Badge (single, clear)
              _StatusBadge(status: data.status),
            ],
          ),
          const SizedBox(height: 16),

          // Batch Weight Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batch Weight',
                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  text: '${data.batchCurrentKg.toStringAsFixed(1)} kg ',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '·  $pctInt%',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Neumorphic Recessed Progress Bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(5),
              boxShadow: AppShadows.insetField(),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PowderMakerStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;

    switch (status) {
      case PowderMakerStatus.systemReady:
        bg = AppColors.tealLight;
        fg = AppColors.teal;
        icon = Icons.check_circle_outline_rounded;
        break;
      case PowderMakerStatus.mixing:
        bg = AppColors.orangeLight;
        fg = AppColors.orange;
        icon = Icons.loop_rounded;
        break;
      case PowderMakerStatus.crystallization:
        bg = AppColors.tealLight;
        fg = AppColors.mutedTeal;
        icon = Icons.ac_unit_rounded;
        break;
      case PowderMakerStatus.powderMaking:
        bg = AppColors.tealLight;
        fg = AppColors.teal;
        icon = Icons.grain_rounded;
        break;
      case PowderMakerStatus.discharge:
        bg = AppColors.orangeLight;
        fg = AppColors.orange;
        icon = Icons.download_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
