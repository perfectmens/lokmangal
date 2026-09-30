import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class ActiveAlertsCard extends StatelessWidget {
  final AlarmsResponse alarms;
  final Function(String alarmId) onAcknowledge;
  final VoidCallback onViewAll;

  const ActiveAlertsCard({
    super.key,
    required this.alarms,
    required this.onAcknowledge,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final activeAlarms = alarms.alarms.where((a) => !a.isAcknowledged).toList();

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
              Row(
                children: [
                  const Text(
                    'ACTIVE ALERTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (alarms.criticalCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${alarms.criticalCount} Critical',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.orange),
                      ),
                    ),
                ],
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (activeAlarms.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'All systems operational. No active alarms.',
                      style: TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activeAlarms.take(3).map((alarm) => _buildAlarmRow(alarm)),
        ],
      ),
    );
  }

  Widget _buildAlarmRow(AlarmItem alarm) {
    final bool isCritical = alarm.isCritical;
    final color = isCritical ? AppColors.orange : const Color(0xFFFFB020);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCritical ? Icons.error_rounded : Icons.warning_amber_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${alarm.equipment} • ${alarm.triggeredAt}${alarm.value != null ? ' • ${alarm.value}' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onAcknowledge(alarm.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x100A0D2F),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Ack',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
