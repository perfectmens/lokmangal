import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';
import '../../viewmodels/plant_viewmodel.dart';

class AlarmsTabView extends StatefulWidget {
  const AlarmsTabView({super.key});

  @override
  State<AlarmsTabView> createState() => _AlarmsTabViewState();
}

class _AlarmsTabViewState extends State<AlarmsTabView> {
  int _filterIndex = 0; // 0: All, 1: Critical, 2: Warnings, 3: Acknowledged

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();
    final alarmsResp = vm.alarms;

    List<AlarmItem> filteredAlarms;
    if (_filterIndex == 1) {
      filteredAlarms = alarmsResp.alarms.where((a) => a.isCritical && !a.isAcknowledged).toList();
    } else if (_filterIndex == 2) {
      filteredAlarms = alarmsResp.alarms.where((a) => !a.isCritical && !a.isAcknowledged).toList();
    } else if (_filterIndex == 3) {
      filteredAlarms = alarmsResp.alarms.where((a) => a.isAcknowledged).toList();
    } else {
      filteredAlarms = alarmsResp.alarms;
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 96.0,
        bottom: 100.0,
        left: 16.0,
        right: 16.0,
      ),
      children: [
        // Top summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCountBadge('CRITICAL', '${alarmsResp.criticalCount}', AppColors.orange),
              Container(width: 1, height: 36, color: AppColors.divider),
              _buildCountBadge('WARNINGS', '${alarmsResp.warningCount}', const Color(0xFFFFB020)),
              Container(width: 1, height: 36, color: AppColors.divider),
              _buildCountBadge('ACKNOWLEDGED', '${alarmsResp.alarms.where((a) => a.isAcknowledged).length}', AppColors.teal),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(0, 'All Alarms (${alarmsResp.alarms.length})'),
              const SizedBox(width: 8),
              _buildFilterChip(1, 'Critical (${alarmsResp.criticalCount})'),
              const SizedBox(width: 8),
              _buildFilterChip(2, 'Warnings (${alarmsResp.warningCount})'),
              const SizedBox(width: 8),
              _buildFilterChip(3, 'Acknowledged'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Alarms list
        if (filteredAlarms.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.card(),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.teal),
                  SizedBox(height: 12),
                  Text(
                    'No alarms in this category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All equipment telemetry operating within tolerances.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredAlarms.map((a) => _buildAlarmCard(context, a, vm)),
      ],
    );
  }

  Widget _buildCountBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final bool isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x0C0A0D2F),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, AlarmItem alarm, PlantViewModel vm) {
    final bool isCritical = alarm.isCritical;
    final color = isCritical ? AppColors.orange : const Color(0xFFFFB020);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card(),
        border: Border.all(
          color: alarm.isAcknowledged
              ? Colors.transparent
              : color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alarm.code,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    alarm.equipment,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ],
              ),
              Text(
                alarm.triggeredAt,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alarm.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          if (alarm.value != null || alarm.limit != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (alarm.value != null)
                    Text(
                      'Actual: ${alarm.value}  ',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                    ),
                  if (alarm.limit != null)
                    Text(
                      'Threshold: ${alarm.limit}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (alarm.isAcknowledged)
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Text(
                      'Acknowledged by ${alarm.acknowledgedBy ?? 'Operator'} (${alarm.acknowledgedAt ?? ''})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                    const SizedBox(width: 6),
                    Text(
                      'Active Attention Required',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
              if (!alarm.isAcknowledged)
                ElevatedButton(
                  onPressed: () async {
                    final ok = await vm.acknowledgeAlarm(alarm.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alarm ${alarm.code} Acknowledged'),
                          backgroundColor: AppColors.teal,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Acknowledge', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
