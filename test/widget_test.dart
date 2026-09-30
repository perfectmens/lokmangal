import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lokmangal/features/app_update/viewmodels/app_update_viewmodel.dart';
import 'package:lokmangal/features/home/views/home_screen.dart';

import 'app_update_test.dart';

void main() {
  testWidgets('Auraliss HomeScreen renders skeleton Floating Dock and 2 Pages', (WidgetTester tester) async {
    final mockUpdateRepo = MockAppUpdateRepository();
    final updateVm = AppUpdateViewModel(repository: mockUpdateRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: updateVm),
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

    // Verify Floating Dock menu items (menu1, menu2)
    expect(find.text('menu1'), findsOneWidget);
    expect(find.text('menu2'), findsOneWidget);

    // Verify developer provisions are NOT shown in UI
    expect(find.text('menu3'), findsNothing);
    expect(find.text('menu4'), findsNothing);
    expect(find.text('menu5'), findsNothing);

    // Verify Bottom Navigation items
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.explore_rounded), findsWidgets);
    expect(find.byIcon(Icons.notifications_rounded), findsWidgets);
    expect(find.byIcon(Icons.settings_rounded), findsWidgets);

    // Verify Skeleton content
    expect(find.text('Primary Dashboard'), findsOneWidget);
  });
}
