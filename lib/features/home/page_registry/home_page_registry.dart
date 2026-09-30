import 'package:flutter/material.dart';

typedef PageBuilder = Widget Function(BuildContext context);

class HomePageModule {
  final String id;
  final String menuLabel; // e.g. 'menu1', 'menu2'
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
/// Contains exactly 2 active pages reflected in the application (Page 0 & Page 1).
/// Provides developer provisions to register additional pages (menu3, menu4, menu5, etc.)
/// without reflecting them in the UI until explicitly enabled.
class HomeScreenPageRegistry {
  static final List<HomePageModule> _registry = [];

  static bool _initialized = false;

  static void initialize({
    required Widget Function(BuildContext) primaryPageBuilder,
    required Widget Function(BuildContext) secondaryPageBuilder,
  }) {
    if (_initialized) return;

    _registry.clear();

    // -------------------------------------------------------------
    // Page 0: Primary View (ACTIVE IN UI)
    // -------------------------------------------------------------
    _registry.add(
      HomePageModule(
        id: 'primary_dashboard',
        menuLabel: 'menu1',
        title: 'Primary View',
        icon: Icons.dashboard_rounded,
        builder: primaryPageBuilder,
        isVisibleInUi: true,
      ),
    );

    // -------------------------------------------------------------
    // Page 1: Secondary View (ACTIVE IN UI)
    // -------------------------------------------------------------
    _registry.add(
      HomePageModule(
        id: 'secondary_analytics',
        menuLabel: 'menu2',
        title: 'Secondary View',
        icon: Icons.insights_rounded,
        builder: secondaryPageBuilder,
        isVisibleInUi: true,
      ),
    );

    // -------------------------------------------------------------
    // DEVELOPER PROVISIONS (Pre-registered future expansion modules)
    // Note: isVisibleInUi = false ensures these are NOT reflected in the application.
    // -------------------------------------------------------------
    _registry.add(
      HomePageModule(
        id: 'quality_assurance',
        menuLabel: 'menu3',
        title: 'Brix & Purity Analytics',
        icon: Icons.biotech_rounded,
        builder: (ctx) => const Center(child: Text('Quality Assurance Module')),
        isVisibleInUi: false, // Provision only - hidden from UI
      ),
    );

    _registry.add(
      HomePageModule(
        id: 'machine_diagnostics',
        menuLabel: 'menu4',
        title: 'Turbine Vibration & Health',
        icon: Icons.build_circle_rounded,
        builder: (ctx) => const Center(child: Text('Diagnostics Module')),
        isVisibleInUi: false, // Provision only - hidden from UI
      ),
    );

    _registry.add(
      HomePageModule(
        id: 'logistics_dispatch',
        menuLabel: 'menu5',
        title: 'Weighbridge & Cane Logistics',
        icon: Icons.local_shipping_rounded,
        builder: (ctx) => const Center(child: Text('Logistics Module')),
        isVisibleInUi: false, // Provision only - hidden from UI
      ),
    );

    _initialized = true;
  }

  /// Returns only pages configured to be displayed in the UI (exactly 2 pages)
  static List<HomePageModule> get activePages =>
      _registry.where((p) => p.isVisibleInUi).toList();

  /// Returns all registered pages including developer provisions
  static List<HomePageModule> get allRegisteredPages =>
      List.unmodifiable(_registry);

  /// Developer provision API to register a new module dynamically
  static void registerModule(HomePageModule module) {
    final existingIdx = _registry.indexWhere((p) => p.id == module.id);
    if (existingIdx >= 0) {
      _registry[existingIdx] = module;
    } else {
      _registry.add(module);
    }
  }

  /// Developer provision API to toggle module visibility
  static void setModuleVisibility(String id, bool isVisible) {
    final idx = _registry.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _registry[idx] = _registry[idx].copyWith(isVisibleInUi: isVisible);
    }
  }
}
