import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

class StorageInventoryCard extends StatelessWidget {
  final StorageMetrics data;

  const StorageInventoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final double combinedPct = (data.combinedSilosKg / data.combinedMaxCapacityKg).clamp(0.0, 1.0);
    final double syrupPct = (data.syrupTankKg / data.syrupTankMaxKg).clamp(0.0, 1.0);

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
                  Icons.warehouse_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Storage Inventory', style: AppTypography.heading2),
                    Text(
                      'Load Cell Monitored Storage',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Combined Silo (2 Silos) Card
          _buildStorageUnit(
            title: 'Combined Silo (${data.numberOfSilos} Silos)',
            subtitle: 'Jaggery Powder Storage',
            weightKg: data.combinedSilosKg,
            maxKg: data.combinedMaxCapacityKg,
            pct: combinedPct,
            hasLoadCell: data.silosLoadCell,
            icon: Icons.grain_rounded,
            accentColor: AppColors.teal,
            bgColor: AppColors.tealLight,
          ),

          const SizedBox(height: 12),

          // 2. Syrup Tank (Liquid Sugars) Card
          _buildStorageUnit(
            title: 'Syrup Tank',
            subtitle: 'Liquid Sugars Storage',
            weightKg: data.syrupTankKg,
            maxKg: data.syrupTankMaxKg,
            pct: syrupPct,
            hasLoadCell: data.syrupTankLoadCell,
            icon: Icons.opacity_rounded,
            accentColor: AppColors.orange,
            bgColor: AppColors.orangeLight,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageUnit({
    required String title,
    required String subtitle,
    required double weightKg,
    required double maxKg,
    required double pct,
    required bool hasLoadCell,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0A0D2F),
            offset: Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                ),
                child: Icon(icon, color: accentColor, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
              if (hasLoadCell)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 11, color: AppColors.teal),
                      SizedBox(width: 4),
                      Text(
                        'Load Cell',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${weightKg.toStringAsFixed(0)} kg',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Max: ${maxKg.toInt()} kg (${(pct * 100).toInt()}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}
