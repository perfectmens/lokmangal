import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../app_update/views/settings_page.dart';
import '../../telemetry/views/executive_page.dart';
import '../../telemetry/views/operations_page.dart';
import '../page_registry/home_page_registry.dart';
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

  int _selectedPageIndex = 0;
  bool _isSettingsOpen = false;

  @override
  void initState() {
    super.initState();
    HomeScreenPageRegistry.initialize(
      operationsPageBuilder: (context) => const OperationsPage(),
      executivePageBuilder: (context) => const ExecutivePage(),
    );
    _selectedPageIndex = 0;
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
      _isSettingsOpen = false;
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
            const Text('User Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Corelife Operations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 2),
            Text('Corelife Wholefoods Facility', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            SizedBox(height: 14),
            Text('Products: Jaggery Powder & Liquid Sugars', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Design Capacity: 20 TPD (3 Shifts/Day)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isSettingsOpen = true);
            },
            child: const Text('Settings & Updates', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700)),
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
    if (_isSettingsOpen) {
      return SettingsPage(
        onBack: () {
          setState(() {
            _isSettingsOpen = false;
          });
        },
      );
    }

    final activePages = HomeScreenPageRegistry.activePages;

    return Stack(
      children: [
        // Swipe right from left edge to open drawer
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
              _scaffoldKey.currentState?.openDrawer();
            }
          },
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: activePages.length,
            itemBuilder: (context, index) {
              return activePages[index].builder(context);
            },
          ),
        ),

        // Floating Top Neumorphic Dock
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: TopFloatingDock(
              navScrollController: _navScrollController,
              selectedPageIndex: _selectedPageIndex,
              onSelectPage: _navigateToPage,
              onLogoTap: () {
                HapticFeedback.lightImpact();
                _scaffoldKey.currentState?.openDrawer();
              },
              onProfileTap: () {
                HapticFeedback.lightImpact();
                _showProfilePopup(context);
              },
              items: activePages
                  .map((p) => DockNavItem(label: p.menuLabel, icon: p.icon))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SideDrawer(
        selectedPageIndex: _selectedPageIndex,
        onSelectPage: _navigateToPage,
        onOpenSettings: () {
          setState(() => _isSettingsOpen = true);
        },
      ),
      body: _buildBody(),
    );
  }
}
