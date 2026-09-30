import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lokmangal/features/app_update/viewmodels/app_update_viewmodel.dart';
import 'package:lokmangal/features/home/page_registry/home_page_registry.dart';
import 'package:lokmangal/features/home/views/home_screen.dart';
import 'package:lokmangal/features/telemetry/viewmodels/telemetry_viewmodel.dart';

import 'app_update_test.dart';

void main() {
  setUp(() {
    HomeScreenPageRegistry.resetForTesting();
  });

  testWidgets('Auraliss HomeScreen renders 2 slides: Operations and Executive with Floating Dock', (WidgetTester tester) async {
    final mockUpdateRepo = MockAppUpdateRepository();
    final updateVm = AppUpdateViewModel(repository: mockUpdateRepo);
    final telemetryVm = TelemetryViewModel(autoStart: false);

    addTearDown(() {
      telemetryVm.dispose();
      updateVm.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
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

    // Verify Floating Dock renamed menu items (Operations, Executive)
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Executive'), findsOneWidget);

    // Verify developer provisions are NOT shown in UI
    expect(find.text('History'), findsNothing);
    expect(find.text('Alarms'), findsNothing);
    expect(find.text('Diagnostics'), findsNothing);

    // Verify Bottom Navigation is removed
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Verify Operations content (Slide 0)
    expect(find.text('Corelife Wholefoods'), findsOneWidget);
    expect(find.text('Powder Maker'), findsOneWidget);
    expect(find.text('Storage Inventory'), findsOneWidget);
  });
}
