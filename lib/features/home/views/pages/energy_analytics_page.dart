import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_dial.dart';
import '../../../telemetry/viewmodels/telemetry_viewmodel.dart';

class EnergyAnalyticsPage extends StatelessWidget {
  const EnergyAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TelemetryViewModel>();
    final analytics = vm.analytics;

    return RefreshIndicator(
      color: AppColors.teal,
      backgroundColor: AppColors.surface,
      onRefresh: () => vm.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16.0, 92.0, 16.0, 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cogen Summary Card
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              boxShadow: AppShadows.circularButton(),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.teal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Cogeneration Power Plant', style: AppTypography.heading2),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tealLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'GRID SYNCED',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn('TOTAL GEN', '${analytics?.powerGeneratedMw.toStringAsFixed(1) ?? "32.5"} MW', AppColors.textPrimary),
                      Container(width: 1, height: 40, color: AppColors.borderLight.withValues(alpha: 0.4)),
                      _buildMetricColumn('GRID EXPORT', '${analytics?.gridExportMw.toStringAsFixed(1) ?? "24.8"} MW', AppColors.teal),
                      Container(width: 1, height: 40, color: AppColors.borderLight.withValues(alpha: 0.4)),
                      _buildMetricColumn('INTERNAL LOAD', '${analytics?.internalConsumptionMw.toStringAsFixed(1) ?? "7.7"} MW', AppColors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Turbogenerator Speed & CO2 Offset
            Row(
              children: [
                Expanded(
                  child: NeumorphicCard(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: NeumorphicDial(
                      value: (analytics?.turbogeneratorRpm ?? 5400) / 100,
                      min: 0,
                      max: 60,
                      unit: 'x100 RPM',
                      title: 'Turbogenerator Speed',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco_rounded, color: AppColors.teal, size: 18),
                            const SizedBox(width: 6),
                            Text('Green Carbon Offset', style: AppTypography.caption),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${analytics?.co2EmissionsOffsetTons.toStringAsFixed(1) ?? "142.6"} T',
                          style: AppTypography.heading1.copyWith(
                            fontSize: 22,
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bagasse-fired renewable energy credit certified under Clean Dev Mechanism.',
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hourly Generation Trend Chart Representation
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hourly Export Profile (MW)', style: AppTypography.heading2),
                      Row(
                        children: [
                          _buildLegendDot('Generation', AppColors.teal),
                          const SizedBox(width: 10),
                          _buildLegendDot('Grid Export', AppColors.orange),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tactile Bar Representation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: (analytics?.hourlyTrend ?? []).map((point) {
                      final genHeight = (point.generationMw * 3.0).clamp(20.0, 100.0);
                      final exportHeight = (point.exportMw * 3.0).clamp(16.0, 80.0);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 14,
                                height: genHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Container(
                                width: 14,
                                height: exportHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(point.hour, style: AppTypography.caption.copyWith(fontSize: 11)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Energy report exported successfully.'),
                          backgroundColor: AppColors.teal,
                        ),
                      );
                    },
                    text: 'Export Log',
                    icon: Icons.file_download_outlined,
                    tone: NeumorphicTone.neutral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Grid dispatch schedule synchronizing with SLDC.'),
                          backgroundColor: AppColors.orange,
                        ),
                      );
                    },
                    text: 'Dispatch Sync',
                    icon: Icons.send_rounded,
                    tone: NeumorphicTone.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading2.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
