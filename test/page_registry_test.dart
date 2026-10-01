import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokmangal/features/home/page_registry/home_page_registry.dart';

void main() {
  group('HomeScreenPageRegistry Unit Tests', () {
    setUp(() {
      HomeScreenPageRegistry.resetForTesting();
    });

    test('Registry initializes with exactly 2 active pages reflected in UI', () {
      HomeScreenPageRegistry.initialize(
        operationsPageBuilder: (context) => const SizedBox(),
        executivePageBuilder: (context) => const SizedBox(),
      );

      final activePages = HomeScreenPageRegistry.activePages;

      // Assert exactly 2 active pages are reflected in the application (Executive first, Operations second)
      expect(activePages.length, 2);
      expect(activePages[0].menuLabel, 'Executive');
      expect(activePages[0].id, 'executive');
      expect(activePages[1].menuLabel, 'Operations');
      expect(activePages[1].id, 'operations');
    });

    test('Registry contains developer provisions for extra pages without reflecting in UI', () {
      HomeScreenPageRegistry.initialize(
        operationsPageBuilder: (context) => const SizedBox(),
        executivePageBuilder: (context) => const SizedBox(),
      );

      final allPages = HomeScreenPageRegistry.allProvisions;

      // Total registered pages including provisions should be >= 5
      expect(allPages.length, greaterThanOrEqualTo(5));

      // Extra provisions must NOT be visible in the UI
      final extraPages = allPages.where((p) => !p.isVisibleInUi).toList();
      expect(extraPages.length, greaterThanOrEqualTo(3));
      expect(extraPages.any((p) => p.id == 'dev_provision_batch_history'), isTrue);
      expect(extraPages.any((p) => p.id == 'dev_provision_alarm_management'), isTrue);
      expect(extraPages.any((p) => p.id == 'dev_provision_diagnostics'), isTrue);
    });

    test('Developer provision can register additional pages dynamically without affecting active UI', () {
      HomeScreenPageRegistry.initialize(
        operationsPageBuilder: (context) => const SizedBox(),
        executivePageBuilder: (context) => const SizedBox(),
      );

      const customModule = HomePageModule(
        id: 'distillery_ai_ingest',
        menuLabel: 'Distillery',
        title: 'Email AI Ingest Daemon',
        icon: Icons.mark_email_read_rounded,
        builder: _dummyBuilder,
        isVisibleInUi: false,
      );

      HomeScreenPageRegistry.registerCustomModule(customModule);

      final activePages = HomeScreenPageRegistry.activePages;
      expect(activePages.length, 2); // UI count strictly preserved
      expect(HomeScreenPageRegistry.allProvisions.any((p) => p.id == 'distillery_ai_ingest'), isTrue);
    });
  });
}

Widget _dummyBuilder(BuildContext context) => const SizedBox();
