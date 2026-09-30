import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../viewmodels/plant_viewmodel.dart';
import '../widgets/active_alerts_card.dart';
import '../widgets/current_process_card.dart';
import '../widgets/energy_card.dart';
import '../widgets/factory_header.dart';
import '../widgets/production_kpi_grid.dart';
import '../widgets/storage_card.dart';

class HomeTabView extends StatelessWidget {
  final Function(int targetTab) onNavigateTab;

  const HomeTabView({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantViewModel>();

    return RefreshIndicator(
      color: AppColors.teal,
      backgroundColor: AppColors.surface,
      onRefresh: () => vm.loadAllData(),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 96.0, // Space below TopFloatingDock
          bottom: 100.0, // Space above BottomNav
          left: 16.0,
          right: 16.0,
        ),
        children: [
          // 1. Factory Header (Plant Identity, LIVE/OFFLINE, Ticker, Health Gauge)
          FactoryHeader(
            status: vm.plantStatus,
            events: vm.events,
          ),
          const SizedBox(height: 18),

          // 2. Production KPI Grid (4 cards: TODAY, RATE, SHIFT, ENERGY)
          ProductionKPIGrid(production: vm.production),
          const SizedBox(height: 18),

          // 3. Current Process (Powder Maker live state machine)
          CurrentProcessCard(
            powderMaker: vm.powderMaker,
            onDrilldown: () => onNavigateTab(1), // Go to Process tab
          ),
          const SizedBox(height: 18),

          // 4. Storage Levels (Load Cells for Combined Silo and Syrup Tank)
          StorageCard(storage: vm.storage),
          const SizedBox(height: 18),

          // 5. Energy Status (103 kW live, shift/day limit progress, kWh/kg)
          EnergyCard(
            energy: vm.energy,
            onDrilldown: () => onNavigateTab(3), // Go to Energy tab
          ),
          const SizedBox(height: 18),

          // 6. Active Alerts (Critical & Warnings with quick acknowledge)
          ActiveAlertsCard(
            alarms: vm.alarms,
            onAcknowledge: (id) => vm.acknowledgeAlarm(id),
            onViewAll: () => onNavigateTab(4), // Go to Alarms tab
          ),
        ],
      ),
    );
  }
}
