import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_dial.dart';
import '../../../telemetry/viewmodels/telemetry_viewmodel.dart';

class TelemetryOverviewPage extends StatelessWidget {
  const TelemetryOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TelemetryViewModel>();
    final telemetry = vm.telemetry;

    return RefreshIndicator(
      color: AppColors.teal,
      backgroundColor: AppColors.surface,
      onRefresh: () => vm.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16.0, 92.0, 16.0, 100.0), // Padding for top floating dock & bottom bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Health Card
            NeumorphicCard(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.teal,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6011CFC9),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokmangal Sugar & Ethanol Complex',
                          style: AppTypography.heading2.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Plant Status: ${telemetry?.plantStatus ?? "ONLINE"} • Real-Time Telemetry',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => vm.refresh(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        boxShadow: AppShadows.circularButton(),
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        color: AppColors.teal,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tactile Dials Row: Boiler Pressure & Steam Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: NeumorphicCard(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: NeumorphicDial(
                      value: telemetry?.boilerPressureBar ?? 64.2,
                      min: 0,
                      max: 100,
                      unit: 'BAR',
                      title: 'Boiler Pressure',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicCard(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: NeumorphicDial(
                      value: telemetry?.steamTemperatureCelsius ?? 485.0,
                      min: 100,
                      max: 600,
                      unit: '°C',
                      title: 'Steam Temp',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Key Performance Metrics Grid
            Row(
              children: [
                Expanded(
                  child: NeumorphicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed_rounded, color: AppColors.teal, size: 18),
                            const SizedBox(width: 6),
                            Text('Milling Efficiency', style: AppTypography.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${telemetry?.millingEfficiencyPercent.toStringAsFixed(1) ?? "96.4"}%',
                          style: AppTypography.heading1.copyWith(
                            fontSize: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Target: 95.0% • (+1.4% Optimal)', style: AppTypography.caption.copyWith(color: AppColors.teal)),
                      ],
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
                            const Icon(Icons.agriculture_rounded, color: AppColors.orange, size: 18),
                            const SizedBox(width: 6),
                            Text('Cane Crushed', style: AppTypography.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${telemetry?.caneCrushedTodayTons.toStringAsFixed(1) ?? "4850.5"} T',
                          style: AppTypography.heading1.copyWith(
                            fontSize: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Today (Tandem 1 & 2)', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Distillation & Distillery Bio-Ethanol Card
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.science_rounded, color: AppColors.teal, size: 18),
                          const SizedBox(width: 8),
                          const Text('Distillery & Ethanol Rate', style: AppTypography.heading2),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tealLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LIVE BATCH',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(telemetry?.distillationRateLpd ?? 125000) / 1000}k LPD',
                            style: AppTypography.display.copyWith(fontSize: 24),
                          ),
                          Text('Anhydrous Ethanol (Fuel Grade)', style: AppTypography.caption),
                        ],
                      ),
                      NeumorphicButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Distillation batch parameters verified.'),
                              backgroundColor: AppColors.teal,
                            ),
                          );
                        },
                        text: 'Inspect Batch',
                        tone: NeumorphicTone.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
