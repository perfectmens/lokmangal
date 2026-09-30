import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/telemetry_viewmodel.dart';
import 'widgets/electricity_quota_card.dart';
import 'widgets/plant_capacity_card.dart';
import 'widgets/portfolio_mix_card.dart';

class ExecutivePage extends StatelessWidget {
  const ExecutivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TelemetryViewModel>();
    final telemetry = vm.telemetry;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 100.0, // Clearance for top floating dock
          left: 16.0,
          right: 16.0,
          bottom: 32.0, // Generous clearance without bottom nav
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlantCapacityCard(data: telemetry.production),
            const SizedBox(height: 16),
            ElectricityQuotaCard(data: telemetry.electricity),
            const SizedBox(height: 16),
            PortfolioMixCard(plant: telemetry.plant),
          ],
        ),
      ),
    );
  }
}
