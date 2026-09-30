import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/telemetry_viewmodel.dart';
import 'widgets/hourly_pacing_card.dart';
import 'widgets/operations_header_banner.dart';
import 'widgets/powder_maker_card.dart';
import 'widgets/storage_inventory_card.dart';

class OperationsPage extends StatelessWidget {
  const OperationsPage({super.key});

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
            OperationsHeaderBanner(
              telemetry: telemetry,
              isSimulated: vm.isSimulated,
              shiftCountdown: vm.formattedShiftCountdown,
            ),
            const SizedBox(height: 16),
            PowderMakerCard(data: telemetry.powderMaker),
            const SizedBox(height: 16),
            StorageInventoryCard(data: telemetry.storage),
            const SizedBox(height: 16),
            HourlyPacingCard(data: telemetry.production),
          ],
        ),
      ),
    );
  }
}
