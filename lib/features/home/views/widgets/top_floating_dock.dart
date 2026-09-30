import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

class DockNavItem {
  final String label;
  final IconData icon;

  const DockNavItem({required this.label, required this.icon});
}

class TopFloatingDock extends StatelessWidget {
  final ScrollController navScrollController;
  final int selectedPageIndex;
  final ValueChanged<int> onSelectPage;
  final VoidCallback onLogoTap;
  final VoidCallback onProfileTap;
  final List<DockNavItem> items;

  const TopFloatingDock({
    super.key,
    required this.navScrollController,
    required this.selectedPageIndex,
    required this.onSelectPage,
    required this.onLogoTap,
    required this.onProfileTap,
    this.items = const [
      DockNavItem(label: 'Home', icon: Icons.home_rounded),
      DockNavItem(label: 'Process', icon: Icons.precision_manufacturing_rounded),
      DockNavItem(label: 'Production', icon: Icons.factory_rounded),
      DockNavItem(label: 'Energy', icon: Icons.bolt_rounded),
      DockNavItem(label: 'Alarms', icon: Icons.notifications_active_rounded),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppShadows.dock(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // 1. Scrollable Menus in the background
              Positioned.fill(
                child: ListView.separated(
                  controller: navScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 80, right: 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final bool isSelected = selectedPageIndex == index;

                    return Center(
                      child: GestureDetector(
                        onTap: () => onSelectPage(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: AppColors.teal.withValues(alpha: 0.5), width: 1.0)
                                : null,
                            boxShadow: isSelected
                                ? []
                                : const [
                                    BoxShadow(
                                      color: Color(0x100A0D2F),
                                      offset: Offset(3, 3),
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                    ),
                                    BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(-3, -3),
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 16,
                                color: isSelected ? AppColors.teal : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                  color: isSelected ? AppColors.teal : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Left Fixed Panel (Auraliss Logo + Gradient Fade Mask)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
                      stops: [0.0, 0.85, 1.0],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onLogoTap,
                        child: Image.asset(
                          'assets/auraliss_logo.png',
                          height: 44,
                          width: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.factory_rounded,
                            color: AppColors.teal,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Right Fixed Panel (Profile Button + Gradient Fade Mask)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0x00FFFFFF), Colors.white, Colors.white],
                      stops: [0.0, 0.25, 1.0],
                    ),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: onProfileTap,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          boxShadow: AppShadows.circularButton(),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.textMuted,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
