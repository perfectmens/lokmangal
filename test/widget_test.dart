import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lokmangal/features/app_update/viewmodels/app_update_viewmodel.dart';
import 'package:lokmangal/features/plant/repositories/plant_repository.dart';
import 'package:lokmangal/features/plant/viewmodels/plant_viewmodel.dart';
import 'package:lokmangal/features/telemetry/models/telemetry_data.dart';
import 'package:lokmangal/features/telemetry/repositories/telemetry_repository.dart';
import 'package:lokmangal/features/telemetry/viewmodels/telemetry_viewmodel.dart';
import 'package:lokmangal/features/home/views/home_screen.dart';

import 'app_update_test.dart';

class MockTelemetryRepository implements TelemetryRepository {
  @override
  Future<PlantTelemetry> getPlantTelemetry() async => PlantTelemetry.initial();

  @override
  Future<EnergyAnalytics> getEnergyAnalytics() async => EnergyAnalytics.initial();

  @override
  Future<void> refreshAllData() async {}
}

void main() {
  testWidgets('Auraliss HomeScreen renders Floating Dock and 5 Corelife Destinations', (WidgetTester tester) async {
    final mockUpdateRepo = MockAppUpdateRepository();
    final updateVm = AppUpdateViewModel(repository: mockUpdateRepo);
    final telemetryRepo = MockTelemetryRepository();
    final telemetryVm = TelemetryViewModel(repository: telemetryRepo);
    final plantRepo = PlantRepositoryImpl();
    final plantVm = PlantViewModel(repository: plantRepo);

    addTearDown(() {
      plantVm.stopAutoPolling();
      plantVm.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: updateVm),
          ChangeNotifierProvider.value(value: telemetryVm),
          ChangeNotifierProvider.value(value: plantVm),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump and advance clock
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify Floating Dock tabs
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Process'), findsWidgets);
    expect(find.text('Production'), findsWidgets);
    expect(find.text('Energy'), findsWidgets);
    expect(find.text('Alarms'), findsWidgets);

    // Verify Factory Header identity
    expect(find.text('Corelife Wholefoods'), findsOneWidget);

    // Verify Bottom Navigation items
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.precision_manufacturing_rounded), findsWidgets);
    expect(find.byIcon(Icons.factory_rounded), findsWidgets);
    expect(find.byIcon(Icons.bolt_rounded), findsWidgets);
    expect(find.byIcon(Icons.notifications_active_rounded), findsWidgets);

    // Stop timers before test ends so invariant check passes
    plantVm.stopAutoPolling();
    // Unmount widget tree to cancel ticker timer
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
