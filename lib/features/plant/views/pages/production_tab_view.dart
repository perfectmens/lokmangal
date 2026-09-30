import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';
import '../../viewmodels/plant_viewmodel.dart';

class ProductionTabView extends StatelessWidget {
  const ProductionTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final p = vm.production;
    final batches = vm.batches;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 96.0,
        bottom: 100.0,
        left: 16.0,
        right: 16.0,
      ),
      children: [
        // Daily Production Target Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DAILY TARGET (20 TPD)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '${p.dailyTargetPercent.toStringAsFixed(1)}% Achieved',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${p.todayKg.toInt()} kg',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '/ ${p.dailyTargetKg.toInt()} kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (p.dailyTargetPercent / 100.0).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: AppColors.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Shift Breakdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '3-SHIFT OPERATIONAL TARGETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              _buildShiftRow('Shift 1 (06:00 - 14:00)', 6680.0, 6667.0, isCompleted: true),
              const SizedBox(height: 12),
              _buildShiftRow('Shift 2 (14:00 - 22:00) • Active', p.shiftKg, p.shiftTargetKg, isActive: true),
              const SizedBox(height: 12),
              _buildShiftRow('Shift 3 (22:00 - 06:00)', 0.0, 6667.0, isPending: true),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Production Batches Table
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT BATCHES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Target: 500 kg / 36 min',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...batches.map((b) => _buildBatchItem(b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftRow(String label, double actual, double target, {bool isCompleted = false, bool isActive = false, bool isPending = false}) {
    final pct = (actual / target).clamp(0.0, 1.0);
    final color = isActive ? AppColors.teal : isCompleted ? AppColors.teal.withValues(alpha: 0.7) : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.teal : AppColors.textPrimary,
              ),
            ),
            Text(
              isPending ? 'Pending' : '${actual.toInt()} / ${target.toInt()} kg',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isPending ? 0.0 : pct,
            minHeight: 5,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchItem(BatchRecord b) {
    final bool isRunning = b.status.toUpperCase() == 'RUNNING';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? AppColors.teal.withValues(alpha: 0.15) : AppColors.surface,
                ),
                child: Center(
                  child: Text(
                    '#${b.batchNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isRunning ? AppColors.teal : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${b.weightKg.toInt()} kg',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${b.startTime}${b.endTime.isNotEmpty ? ' - ${b.endTime}' : ''} (${b.durationMinutes.toInt()} min)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isRunning ? AppColors.teal.withValues(alpha: 0.12) : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              b.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isRunning ? AppColors.teal : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
