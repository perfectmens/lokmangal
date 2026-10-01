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
                    Text('Jaggery Powder · Liquid Sugars', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Silo 1 & Silo 2 side-by-side
          Row(
            children: [
              Expanded(
                child: _buildSiloUnit(
                  label: 'Silo 1',
                  currentKg: data.silo1Kg,
                  maxKg: data.siloMaxKg,
                  isActive: data.activeSilo == 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSiloUnit(
                  label: 'Silo 2',
                  currentKg: data.silo2Kg,
                  maxKg: data.siloMaxKg,
                  isActive: data.activeSilo == 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Syrup Tank full-width
          _buildStorageUnit(
            title: 'Syrup Tank',
            subtitle: 'Liquid Sugars · Max 5,000 kg',
            weightKg: data.syrupTankKg,
            maxKg: data.syrupTankMaxKg,
            pct: syrupPct,
            icon: Icons.opacity_rounded,
            accentColor: AppColors.orange,
            bgColor: AppColors.orangeLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSiloUnit({
    required String label,
    required double currentKg,
    required double maxKg,
    required bool isActive,
  }) {
    final double pct = (currentKg / maxKg).clamp(0.0, 1.0);
    final int pctInt = (pct * 100).toInt();
    final Color accent = isActive ? AppColors.teal : AppColors.textMuted;
    final Color bg = isActive ? AppColors.tealLight : AppColors.background;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: AppColors.teal.withValues(alpha: 0.35), width: 1.0)
            : Border.all(color: AppColors.borderLight, width: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0A0D2F), offset: Offset(3, 3), blurRadius: 6),
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg,
                  border: isActive ? null : Border.all(color: AppColors.borderLight),
                ),
                child: Icon(Icons.grain_rounded, color: accent, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Active / Standby tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? bg : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive ? null : Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  isActive ? 'Active' : 'Standby',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.teal : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${currentKg.toStringAsFixed(0)} kg',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'of ${maxKg.toInt()} kg  ($pctInt%)',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(isActive ? AppColors.teal : AppColors.borderLight),
              minHeight: 6,
            ),
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
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A0A0D2F), offset: Offset(3, 3), blurRadius: 6),
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${weightKg.toStringAsFixed(0)} kg',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                'Max: ${maxKg.toInt()} kg  (${(pct * 100).toInt()}%)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
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
