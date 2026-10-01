import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../auth/viewmodels/auth_viewmodel.dart';
import '../../../guide/views/app_guide_modal.dart';

class SideDrawer extends StatefulWidget {
  final int selectedPageIndex;
  final ValueChanged<int> onSelectPage;
  final VoidCallback onOpenSettings;

  const SideDrawer({
    super.key,
    required this.selectedPageIndex,
    required this.onSelectPage,
    required this.onOpenSettings,
  });

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version} (Build ${info.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Plant & Operator Identity Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      boxShadow: AppShadows.circularButton(),
                    ),
                    child: const Icon(
                      Icons.factory_rounded,
                      color: AppColors.teal,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Corelife Wholefoods',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Plant Telemetry & Controls • 20 TPD',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),

            // 2. Tailored Navigation Items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                children: [
                  // Executive View
                  _buildDrawerItem(
                    index: 0,
                    icon: Icons.insights_rounded,
                    title: 'Executive',
                    subtitle: 'Capacity, Energy & Shift History',
                    isSelected: widget.selectedPageIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectPage(0);
                    },
                  ),

                  // Operations View
                  _buildDrawerItem(
                    index: 1,
                    icon: Icons.precision_manufacturing_rounded,
                    title: 'Operations',
                    subtitle: 'Powder Maker, Silos & Production Pace',
                    isSelected: widget.selectedPageIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectPage(1);
                    },
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  const SizedBox(height: 12),

                  // Settings & Updates
                  _buildDrawerItem(
                    index: -1,
                    icon: Icons.system_update_rounded,
                    title: 'Settings & Updates',
                    subtitle: 'Software Version & Device Info',
                    isSelected: false,
                    isHighlight: true,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOpenSettings();
                    },
                  ),

                  // User Guide
                  _buildDrawerItem(
                    index: -3,
                    icon: Icons.menu_book_rounded,
                    title: 'User Guide',
                    subtitle: 'Application Features & Walkthrough',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      AppGuideModal.show(context);
                    },
                  ),

                  // Sign Out
                  _buildDrawerItem(
                    index: -2,
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'End current session',
                    isSelected: false,
                    isHighlight: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthViewModel>().logout();
                    },
                  ),
                ],
              ),
            ),

            // 3. Minimal Clean Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Auraliss Corelife',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _version,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    final Color iconColor = isSelected
        ? AppColors.teal
        : isHighlight
            ? AppColors.orange
            : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tealLight : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: AppColors.teal.withValues(alpha: 0.3), width: 1.0)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: isSelected ? [] : AppShadows.circularButton(),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
