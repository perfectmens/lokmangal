import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../app_update/views/settings_page.dart';
import '../../plant/viewmodels/plant_viewmodel.dart';
import '../../plant/views/pages/alarms_tab_view.dart';
import '../../plant/views/pages/energy_tab_view.dart';
import '../../plant/views/pages/home_tab_view.dart';
import '../../plant/views/pages/process_tab_view.dart';
import '../../plant/views/pages/production_tab_view.dart';
import '../page_registry/home_page_registry.dart';
import 'widgets/neumorphic_bottom_nav.dart';
import 'widgets/side_drawer.dart';
import 'widgets/top_floating_dock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ScrollController _navScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedPageIndex = 0; // 0: Home, 1: Process, 2: Production, 3: Energy, 4: Alarms
  int _selectedDrawerIndex = 0; // 0: Home, 5: Settings, etc.

  @override
  void initState() {
    super.initState();

    // Developer provision registry initialization
    HomeScreenPageRegistry.initialize(
      telemetryPageBuilder: (context) => HomeTabView(onNavigateTab: _navigateToPage),
      energyPageBuilder: (context) => const EnergyTabView(),
    );

    // Initial load and polling of authoritative plant telemetry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navScrollController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedPageIndex = index;
      _selectedDrawerIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedPageIndex = index;
    });

    // Auto-scroll nav dock to keep active item visible
    if (_navScrollController.hasClients) {
      final double offset = (index - 1) * 80.0;
      _navScrollController.animateTo(
        offset.clamp(0.0, _navScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showProfilePopup(BuildContext context) {
    final plantVm = context.read<PlantViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.teal),
            ),
            const SizedBox(width: 12),
            const Text('Operator Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Corelife Plant Operator', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 2),
            const Text('operator@corelife.com', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 14),
            const Text('Plant: Corelife Wholefoods', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Text('Unit: Jaggery & Liquid Sugars', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: plantVm.isOnline ? AppColors.teal : AppColors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Connection: ${plantVm.isOnline ? "ONLINE (Simulation Live)" : "OFFLINE"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: plantVm.isOnline ? AppColors.teal : AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Host: ${plantVm.baseUrl}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedDrawerIndex = 5); // Navigate to Settings
            },
            child: const Text('Settings', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // If settings is selected from side drawer
    if (_selectedDrawerIndex == 5) {
      return SettingsPage(
        onBack: () {
          setState(() {
            _selectedDrawerIndex = 0;
          });
        },
      );
    }

    if (_selectedDrawerIndex != 0) {
      return _buildDrawerFeaturePage(_selectedDrawerIndex);
    }

    // 5 Corelife Destinations
    final List<Widget> pages = [
      HomeTabView(onNavigateTab: _navigateToPage),
      const ProcessTabView(),
      const ProductionTabView(),
      const EnergyTabView(),
      const AlarmsTabView(),
    ];

    return Stack(
      children: [
        // Background PageView with the 5 Corelife tabs
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: pages,
        ),

        // Floating Top Neumorphic Dock
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: TopFloatingDock(
              navScrollController: _navScrollController,
              selectedPageIndex: _selectedPageIndex,
              onSelectPage: _navigateToPage,
              onLogoTap: () => _navigateToPage(0),
              onProfileTap: () {
                HapticFeedback.lightImpact();
                _showProfilePopup(context);
              },
            ),
          ),
        ),

        // Neumorphic Bottom Navigation Bar
        NeumorphicBottomNav(
          currentIndex: _selectedPageIndex,
          onTap: _navigateToPage,
        ),
      ],
    );
  }

  Widget _buildDrawerFeaturePage(int index) {
    String title;
    IconData icon;

    switch (index) {
      case 1:
        title = 'Powder Making Process';
        icon = Icons.precision_manufacturing_rounded;
        break;
      case 2:
        title = 'Production Targets';
        icon = Icons.factory_rounded;
        break;
      case 3:
        title = 'Energy Analytics';
        icon = Icons.bolt_rounded;
        break;
      case 4:
        title = 'Plant Alarms';
        icon = Icons.notifications_active_rounded;
        break;
      case 6:
        title = 'Help & SCADA Specs';
        icon = Icons.help_outline_rounded;
        break;
      case 7:
        title = 'About Auraliss Platform';
        icon = Icons.info_outline_rounded;
        break;
      default:
        title = 'Operator Profile';
        icon = Icons.person_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedDrawerIndex = 0),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(icon, size: 64, color: AppColors.teal),
                    const SizedBox(height: 16),
                    Text('$title is active and synchronized with telemetry.',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // System Back Button Unwinding as specified in architectural guide
        if (_selectedDrawerIndex != 0) {
          setState(() => _selectedDrawerIndex = 0);
        } else if (_selectedPageIndex != 0) {
          _navigateToPage(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.3,
        drawer: _selectedDrawerIndex == 0
            ? SideDrawer(
                selectedDrawerIndex: _selectedPageIndex,
                onSelectDrawerIndex: (index) {
                  if (index >= 0 && index <= 4) {
                    _navigateToPage(index);
                  } else {
                    setState(() => _selectedDrawerIndex = index);
                  }
                },
              )
            : null,
        body: _buildBody(),
      ),
    );
  }
}
