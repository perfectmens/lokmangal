import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/telemetry_viewmodel.dart';
import 'widgets/electricity_quota_card.dart';
import 'widgets/plant_capacity_card.dart';

class ExecutivePage extends StatelessWidget {
  const ExecutivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TelemetryViewModel>();
    final telemetry = vm.telemetry;

    // Guaranteed clearance: Status Bar + Dock Height (64) + Top Margin (12) + Spacing (16)
    final double topClearance = MediaQuery.of(context).padding.top + 64.0 + 12.0 + 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: topClearance,
          left: 16.0,
          right: 16.0,
          bottom: 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlantCapacityCard(data: telemetry.production),
            const SizedBox(height: 16),
            ElectricityQuotaCard(data: telemetry.electricity),
          ],
        ),
      ),
    );
  }
}
