import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/telemetry_viewmodel.dart';
import 'widgets/hourly_pacing_card.dart';
import 'widgets/hourly_production_line_graph_card.dart';
import 'widgets/operations_header_banner.dart';
import 'widgets/powder_maker_card.dart';
import 'widgets/storage_inventory_card.dart';

class OperationsPage extends StatelessWidget {
  const OperationsPage({super.key});

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
            OperationsHeaderBanner(
              telemetry: telemetry,
              isSimulated: vm.isSimulated,
              shiftInfo: vm.formattedShiftInfo,
            ),
            const SizedBox(height: 16),
            PowderMakerCard(data: telemetry.powderMaker),
            const SizedBox(height: 16),
            StorageInventoryCard(data: telemetry.storage),
            const SizedBox(height: 16),
            HourlyPacingCard(data: telemetry.production),
            const SizedBox(height: 16),
            // 8-hour shift window production line graph (backend-owned data)
            HourlyProductionLineGraphCard(
              data: telemetry.hourlyProductionHistory,
              production: telemetry.production,
            ),
          ],
        ),
      ),
    );
  }
}
