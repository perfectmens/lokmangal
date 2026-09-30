import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class StorageCard extends StatelessWidget {
  final StorageLevels storage;

  const StorageCard({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STORAGE & LOAD CELLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  storage.validationStatus,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.teal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTankItem(
                  title: 'COMBINED SILO',
                  subtitle: 'Silo 1 + Silo 2 (Load Cells)',
                  weightKg: storage.combinedSilo.totalKg,
                  capacityKg: storage.combinedSilo.capacityKg,
                  percent: storage.combinedSilo.percent,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTankItem(
                  title: 'SYRUP TANK',
                  subtitle: 'Liquid Sugar Reserve',
                  weightKg: storage.syrupTank.totalKg,
                  capacityKg: storage.syrupTank.capacityKg,
                  percent: storage.syrupTank.percent,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTankItem({
    required String title,
    required String subtitle,
    required double weightKg,
    required double capacityKg,
    required double percent,
    required Color color,
  }) {
    final fillPct = (percent / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          // Graphical Tank Container
          Container(
            width: 56,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0A0D2F),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Liquid fill
                FractionallySizedBox(
                  heightFactor: fillPct,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    ),
                  ),
                ),
                // Percent text in tank
                Center(
                  child: Text(
                    '${percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: fillPct > 0.5 ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${weightKg.toInt()} kg',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          Text(
            'Cap: ${capacityKg.toInt()} kg',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
