import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../app_update/views/settings_page.dart';
import '../page_registry/home_page_registry.dart';
import 'pages/skeleton_page.dart';
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

  int _selectedPageIndex = 0; // Active PageView index (0: menu1, 1: menu2)
  int _selectedDrawerIndex = 0; // 0: Home, 5: Settings, etc.
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize developer page registry with the 2 active skeleton pages
    HomeScreenPageRegistry.initialize(
      primaryPageBuilder: (context) => const SkeletonPage(
        title: 'Primary Dashboard',
        subtitle: 'Main Workspace & Operations',
        icon: Icons.dashboard_rounded,
      ),
      secondaryPageBuilder: (context) => const SkeletonPage(
        title: 'Secondary Analytics',
        subtitle: 'Metrics, Insights & Reports',
        icon: Icons.insights_rounded,
      ),
    );
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
            Text('Operator Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 2),
            Text('user@auraliss.com', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            SizedBox(height: 14),
            Text('Application: Auraliss Platform', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Environment: Production Ready', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
    // If settings is selected from side drawer or bottom nav
    if (_selectedDrawerIndex == 5 || _bottomNavIndex == 3) {
      return SettingsPage(
        onBack: () {
          setState(() {
            _selectedDrawerIndex = 0;
            _bottomNavIndex = 0;
          });
        },
      );
    }

    if (_selectedDrawerIndex != 0) {
      return _buildDrawerFeaturePage(_selectedDrawerIndex);
    }

    final activePages = HomeScreenPageRegistry.activePages;

    return Stack(
      children: [
        // Background PageView with active skeleton pages
        PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          itemCount: activePages.length,
          itemBuilder: (context, index) {
            return activePages[index].builder(context);
          },
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
              items: activePages
                  .map((p) => DockNavItem(label: p.menuLabel, icon: p.icon))
                  .toList(),
            ),
          ),
        ),

        // Neumorphic Bottom Navigation Bar
        NeumorphicBottomNav(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              _bottomNavIndex = index;
              if (index == 0) {
                _selectedDrawerIndex = 0;
                _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              } else if (index == 1) {
                _selectedDrawerIndex = 0;
                _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              } else if (index == 3) {
                _selectedDrawerIndex = 5; // Open Settings
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildDrawerFeaturePage(int index) {
    String title;
    IconData icon;

    switch (index) {
      case 1:
        title = 'Explore Modules';
        icon = Icons.explore_rounded;
        break;
      case 2:
        title = 'Favorites';
        icon = Icons.favorite_rounded;
        break;
      case 3:
        title = 'Notifications';
        icon = Icons.notifications_rounded;
        break;
      case 4:
        title = 'Activity & Logs';
        icon = Icons.list_alt_rounded;
        break;
      case 6:
        title = 'Help & Documentation';
        icon = Icons.help_outline_rounded;
        break;
      case 7:
        title = 'About Auraliss';
        icon = Icons.info_outline_rounded;
        break;
      default:
        title = 'User Profile';
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
                    Text('$title skeleton is ready for implementation.',
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
        if (_bottomNavIndex != 0) {
          setState(() => _bottomNavIndex = 0);
        } else if (_selectedDrawerIndex != 0) {
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
        drawer: (_bottomNavIndex == 0 && _selectedDrawerIndex == 0)
            ? SideDrawer(
                selectedDrawerIndex: _selectedDrawerIndex,
                onSelectDrawerIndex: (index) {
                  setState(() => _selectedDrawerIndex = index);
                },
              )
            : null,
        body: _buildBody(),
      ),
    );
  }
}
