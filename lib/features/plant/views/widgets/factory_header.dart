import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';
import 'live_plant_event_ticker.dart';
import 'plant_health_gauge.dart';

class FactoryHeader extends StatelessWidget {
  final PlantStatus status;
  final List<PlantEvent> events;

  const FactoryHeader({
    super.key,
    required this.status,
    required this.events,
  });

  void _showHealthBreakdownModal(BuildContext context) {
    final b = status.healthBreakdown;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A0A0D2F),
              offset: Offset(0, -6),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Health Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Operational Weighted Indicator Score',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${status.healthScore.toInt()}%',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildScoreItem('Production Performance (Weight 30%)', b.production, 30.0, AppColors.teal),
            _buildScoreItem('Equipment Reliability (Weight 30%)', b.equipment, 30.0, AppColors.teal),
            _buildScoreItem('Energy Efficiency (Weight 15%)', b.energy, 15.0, AppColors.orange),
            _buildScoreItem('Storage Headroom (Weight 15%)', b.storage, 15.0, AppColors.teal),
            _buildScoreItem('PLC Connectivity (Weight 10%)', b.connectivity, 10.0, AppColors.teal),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Calculated deterministically from live plant signals.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, double actual, double max, Color accentColor) {
    final double pct = (actual / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              Text(
                '${actual.toStringAsFixed(1)} / ${max.toInt()}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Plant identity & LIVE/OFFLINE badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.location,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // LIVE / OFFLINE Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.isOnline
                      ? AppColors.teal.withValues(alpha: 0.12)
                      : AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: status.isOnline
                        ? AppColors.teal.withValues(alpha: 0.4)
                        : AppColors.orange.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status.isOnline ? AppColors.teal : AppColors.orange,
                        boxShadow: status.isOnline
                            ? [
                                BoxShadow(
                                  color: AppColors.teal.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.connectionStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: status.isOnline ? AppColors.teal : AppColors.orange,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Middle row: Revolving Event Ticker & Plant Health Gauge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE PLANT TELEMETRY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LivePlantEventTicker(events: events),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              PlantHealthGauge(
                score: status.healthScore,
                breakdown: status.healthBreakdown,
                onTap: () => _showHealthBreakdownModal(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
