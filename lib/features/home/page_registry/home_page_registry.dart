import 'package:flutter/material.dart';

typedef PageBuilder = Widget Function(BuildContext context);

class HomePageModule {
  final String id;
  final String menuLabel; // e.g. 'Operations', 'Executive'
  final String title;
  final IconData icon;
  final PageBuilder builder;
  final bool isVisibleInUi; // Set to true to reflect in UI, false to keep as developer provision

  const HomePageModule({
    required this.id,
    required this.menuLabel,
    required this.title,
    required this.icon,
    required this.builder,
    this.isVisibleInUi = true,
  });

  HomePageModule copyWith({bool? isVisibleInUi}) {
    return HomePageModule(
      id: id,
      menuLabel: menuLabel,
      title: title,
      icon: icon,
      builder: builder,
      isVisibleInUi: isVisibleInUi ?? this.isVisibleInUi,
    );
  }
}

/// Extensible Developer Page Registry for the Home Screen.
/// Contains exactly 2 active pages reflected in the application (Operations & Executive).
/// Provides developer provisions to register additional pages (menu3, menu4, menu5, etc.)
/// without reflecting them in the UI until explicitly enabled.
class HomeScreenPageRegistry {
  static final List<HomePageModule> _registry = [];

  static bool _initialized = false;

  static void initialize({
    required Widget Function(BuildContext) operationsPageBuilder,
    required Widget Function(BuildContext) executivePageBuilder,
  }) {
    if (_initialized) return;

    _registry.clear();

    // -------------------------------------------------------------
    // Page 0: Executive View (C-Suite Dashboard)
    // -------------------------------------------------------------
    _registry.add(
      HomePageModule(
        id: 'executive',
        menuLabel: 'Executive',
        title: 'Executive (C-Suite)',
        icon: Icons.insights_rounded,
        builder: executivePageBuilder,
        isVisibleInUi: true,
      ),
    );

    // -------------------------------------------------------------
    // Page 1: Operations View (Floor Dashboard)
    // -------------------------------------------------------------
    _registry.add(
      HomePageModule(
        id: 'operations',
        menuLabel: 'Operations',
        title: 'Operations (Floor)',
        icon: Icons.precision_manufacturing_rounded,
        builder: operationsPageBuilder,
        isVisibleInUi: true,
      ),
    );

    // -------------------------------------------------------------
    // DEVELOPER PROVISIONS: Hidden extra pages (NOT REFLECTED IN UI)
    // -------------------------------------------------------------
    _registry.add(
      HomePageModule(
        id: 'dev_provision_batch_history',
        menuLabel: 'History',
        title: 'Batch History & Logs',
        icon: Icons.history_rounded,
        builder: (context) => const SizedBox.shrink(),
        isVisibleInUi: false,
      ),
    );

    _registry.add(
      HomePageModule(
        id: 'dev_provision_alarm_management',
        menuLabel: 'Alarms',
        title: 'Alarm Lifecycle Management',
        icon: Icons.notifications_active_rounded,
        builder: (context) => const SizedBox.shrink(),
        isVisibleInUi: false,
      ),
    );

    _registry.add(
      HomePageModule(
        id: 'dev_provision_diagnostics',
        menuLabel: 'Diagnostics',
        title: 'SCADA Diagnostics & Calibration',
        icon: Icons.settings_input_component_rounded,
        builder: (context) => const SizedBox.shrink(),
        isVisibleInUi: false,
      ),
    );

    _initialized = true;
  }

  /// Get only active pages that should be displayed in the PageView & Top Floating Dock.
  static List<HomePageModule> get activePages =>
      _registry.where((p) => p.isVisibleInUi).toList();

  /// Total count of active pages reflected in UI.
  static int get activePageCount => activePages.length;

  /// Check developer provision list (includes both active and hidden provisions).
  static List<HomePageModule> get allProvisions => List.unmodifiable(_registry);

  /// Developer provision method: dynamically enable or register a custom module.
  static void registerCustomModule(HomePageModule module) {
    final existingIndex = _registry.indexWhere((p) => p.id == module.id);
    if (existingIndex >= 0) {
      _registry[existingIndex] = module;
    } else {
      _registry.add(module);
    }
  }

  /// Clear registry for testing
  @visibleForTesting
  static void resetForTesting() {
    _registry.clear();
    _initialized = false;
  }
}
