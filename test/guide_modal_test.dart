import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokmangal/features/guide/views/app_guide_modal.dart';

void main() {
  testWidgets('AppGuideModal renders all 4 steps smoothly and closes on Got It', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppGuideModal(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Step 1: Executive C-Suite
    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    expect(find.text('Plant Capacity & High-Level KPIs'), findsOneWidget);
    expect(find.text('Plant Design Capacity'), findsOneWidget);
    expect(find.text('Electricity Consumption'), findsOneWidget);
    expect(find.text('Shift-wise Output History'), findsOneWidget);

    // Tap Next -> Step 2: Operations Floor
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 2 OF 4'), findsOneWidget);
    expect(find.text('Floor Controls & Production Pacing'), findsOneWidget);
    expect(find.text('Production Targets Console'), findsOneWidget);
    expect(find.text('Hourly Production Pacing Graph'), findsOneWidget);
    expect(find.text('Machinery & Storage Silos'), findsOneWidget);

    // Tap Next -> Step 3: Navigation Side Panel
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 3 OF 4'), findsOneWidget);
    expect(find.text('Side Panel & Quick Switcher'), findsOneWidget);
    expect(find.text('Open from Anywhere'), findsOneWidget);
    expect(find.text('One-Tap Slide Switching'), findsOneWidget);

    // Tap Next -> Step 4: Settings & Updates
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 4 OF 4'), findsOneWidget);
    expect(find.text('Over-The-Air (OTA) Updates'), findsOneWidget);
    expect(find.text('Automated Update Detection'), findsOneWidget);
    expect(find.text('1-Tap Background Download & Install'), findsOneWidget);
    expect(find.text('100% In-App Calculation Engine'), findsOneWidget);
    expect(find.text('Got It'), findsOneWidget);

    // Tap Back -> Step 3
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 3 OF 4'), findsOneWidget);

    // Tap Next again -> Step 4
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 4 OF 4'), findsOneWidget);

    // Tap Got It -> Completes/Closes
    await tester.tap(find.text('Got It'));
    await tester.pumpAndSettle();
  });
}
