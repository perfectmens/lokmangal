import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lokmangal/features/app_update/viewmodels/app_update_viewmodel.dart';
import 'package:lokmangal/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lokmangal/features/home/page_registry/home_page_registry.dart';
import 'package:lokmangal/features/home/views/home_screen.dart';
import 'package:lokmangal/features/telemetry/viewmodels/telemetry_viewmodel.dart';

import 'app_update_test.dart';

void main() {
  setUp(() {
    HomeScreenPageRegistry.resetForTesting();
  });

  testWidgets('Auraliss HomeScreen renders Executive as Slide 0 and Operations as Slide 1 with Floating Dock', (WidgetTester tester) async {
    final mockUpdateRepo = MockAppUpdateRepository();
    final updateVm = AppUpdateViewModel(repository: mockUpdateRepo);
    final telemetryVm = TelemetryViewModel(autoStart: false);
    final authVm = AuthViewModel(initialAuthenticated: true);

    addTearDown(() {
      telemetryVm.dispose();
      updateVm.dispose();
      authVm.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authVm),
          ChangeNotifierProvider.value(value: updateVm),
          ChangeNotifierProvider.value(value: telemetryVm),
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

    // Verify Floating Dock menu items (Executive first, Operations second)
    expect(find.text('Executive'), findsOneWidget);
    expect(find.text('Operations'), findsOneWidget);

    // Verify developer provisions are NOT shown in UI
    expect(find.text('History'), findsNothing);
    expect(find.text('Alarms'), findsNothing);
    expect(find.text('Diagnostics'), findsNothing);

    // Verify Bottom Navigation is removed
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Verify Executive content is on primary initial Slide 0
    expect(find.text('Corelife Wholefoods'), findsWidgets);
    expect(find.text('Shift-wise Output'), findsOneWidget);
    expect(find.text('Plant Design Capacity'), findsOneWidget);
    expect(find.text('Electricity Consumption'), findsOneWidget);

    // Verify Shift-wise Output has Live shift on top and Done shift
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Navigate to Operations (Slide 1) via dock
    await tester.tap(find.text('Operations'));
    await tester.pumpAndSettle();

    // Verify Operations content (Slide 1)
    expect(find.text('Production Targets'), findsOneWidget);
    expect(find.text('Hourly Production Pacing'), findsOneWidget);
    expect(find.text('Powder Maker'), findsOneWidget);
    expect(find.text('Storage Inventory'), findsOneWidget);

    // Open Side Drawer via Logo Tap
    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();

    // Verify User Guide & Walkthrough item is present in Drawer
    expect(find.text('User Guide & Walkthrough'), findsOneWidget);
    await tester.tap(find.text('User Guide & Walkthrough'));
    await tester.pumpAndSettle();

    // Verify Guide Modal opened on Step 1
    expect(find.text('Plant Capacity & High-Level KPIs'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Floor Controls & Production Pacing'), findsOneWidget);
  });
}
