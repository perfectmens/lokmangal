import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokmangal/features/home/page_registry/home_page_registry.dart';

void main() {
  group('HomeScreenPageRegistry Unit Tests', () {
    test('Registry initializes with exactly 2 active pages reflected in UI', () {
      HomeScreenPageRegistry.initialize(
        primaryPageBuilder: (context) => const SizedBox(),
        secondaryPageBuilder: (context) => const SizedBox(),
      );

      final activePages = HomeScreenPageRegistry.activePages;

      // Assert exactly 2 active pages are reflected in the application
      expect(activePages.length, 2);
      expect(activePages[0].menuLabel, 'menu1');
      expect(activePages[0].id, 'primary_dashboard');
      expect(activePages[1].menuLabel, 'menu2');
      expect(activePages[1].id, 'secondary_analytics');
    });

    test('Registry contains developer provisions for extra pages without reflecting in UI', () {
      final allPages = HomeScreenPageRegistry.allRegisteredPages;

      // Total registered pages including provisions should be > 2
      expect(allPages.length, greaterThanOrEqualTo(5));

      // Extra provisions must NOT be visible in the UI
      final extraPages = allPages.where((p) => !p.isVisibleInUi).toList();
      expect(extraPages.length, greaterThanOrEqualTo(3));
      expect(extraPages.any((p) => p.menuLabel == 'menu3'), isTrue);
      expect(extraPages.any((p) => p.menuLabel == 'menu4'), isTrue);
      expect(extraPages.any((p) => p.menuLabel == 'menu5'), isTrue);
    });

    test('Developer provision can register additional pages dynamically without affecting active UI', () {
      const customModule = HomePageModule(
        id: 'distillery_ai_ingest',
        menuLabel: 'menu6',
        title: 'Email AI Ingest Daemon',
        icon: Icons.mark_email_read_rounded,
        builder: _dummyBuilder,
        isVisibleInUi: false,
      );

      HomeScreenPageRegistry.registerModule(customModule);

      final activePages = HomeScreenPageRegistry.activePages;
      expect(activePages.length, 2); // UI count strictly preserved
      expect(HomeScreenPageRegistry.allRegisteredPages.any((p) => p.id == 'distillery_ai_ingest'), isTrue);
    });
  });
}

Widget _dummyBuilder(BuildContext context) => const SizedBox();
