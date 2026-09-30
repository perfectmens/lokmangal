import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../viewmodels/plant_viewmodel.dart';

class ProcessTabView extends StatelessWidget {
  const ProcessTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final pm = vm.powderMaker;

    final steps = [
      {'key': 'SYSTEM_READY', 'label': 'System Ready', 'time': '00:00', 'completed': true},
      {'key': 'MIXING', 'label': 'Mixing Stage', 'time': '04:32', 'completed': true},
      {'key': 'CRYSTALLIZATION', 'label': 'Crystallization', 'time': '08:17', 'completed': true},
      {'key': 'POWDER_MAKING', 'label': 'Powder Making', 'time': '${pm.elapsedMinutes.toInt()} min', 'active': true},
      {'key': 'DISCHARGE', 'label': 'Discharge & Transfer', 'time': 'Pending', 'pending': true},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 96.0,
        bottom: 100.0,
        left: 16.0,
        right: 16.0,
      ),
      children: [
        // Title Bar
        Container(
          padding: const EdgeInsets.all(18),
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
                    'POWDER MAKER #1',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pm.equipmentStatus,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'PLC Controlled Crystallization & Powder Pulverizer',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Stage Machine Steps
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
                'PLC STATE MACHINE PROGRESSION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              ...steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isLast = idx == steps.length - 1;
                final bool isCompleted = item['completed'] == true;
                final bool isActive = item['active'] == true;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? AppColors.teal
                                : isCompleted
                                    ? AppColors.teal.withValues(alpha: 0.2)
                                    : AppColors.background,
                            border: Border.all(
                              color: isActive ? AppColors.teal : AppColors.teal.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_rounded, size: 16, color: AppColors.teal)
                                : isActive
                                    ? Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 36,
                            color: isCompleted ? AppColors.teal : AppColors.divider,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                color: isActive ? AppColors.teal : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              item['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive ? AppColors.teal : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Live Batch Deep Dive
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
                  Text(
                    'BATCH #${pm.batchNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${pm.currentWeightKg.toInt()} / ${pm.targetWeightKg.toInt()} kg',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (pm.progressPercent / 100.0).clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: AppColors.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricTile('Elapsed Time', '${pm.elapsedMinutes.toInt()} min'),
                  _buildMetricTile('Target Cycle', '${pm.targetCycleMinutes.toInt()} min'),
                  _buildMetricTile('Rate', '${pm.currentRateKgH.toInt()} kg/h'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
