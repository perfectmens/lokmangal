import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

class SideDrawer extends StatelessWidget {
  final int selectedDrawerIndex;
  final ValueChanged<int> onSelectDrawerIndex;

  const SideDrawer({
    super.key,
    required this.selectedDrawerIndex,
    required this.onSelectDrawerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Static Profile Header
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onSelectDrawerIndex(8); // Dedicated Profile Page
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        boxShadow: AppShadows.circularButton(),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.textMuted,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Corelife Operator',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'operator@corelife.com',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),

            // 2. Scrollable Navigation Groups
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    // Primary Navigation
                    _buildDrawerItem(0, Icons.home_rounded, 'Home', context),
                    _buildDrawerItem(1, Icons.explore_rounded, 'Explore', context),
                    _buildDrawerItem(2, Icons.favorite_rounded, 'Favorites', context),
                    _buildDrawerItem(3, Icons.notifications_rounded, 'Notifications', context),
                    _buildDrawerItem(4, Icons.list_alt_rounded, 'My Activity', context),

                    const Divider(height: 24, indent: 20, endIndent: 20),

                    // Utility & Settings Group
                    _buildDrawerItem(5, Icons.settings_rounded, 'Settings & Updates', context),
                    _buildDrawerItem(6, Icons.help_outline_rounded, 'Help & Support', context),
                    _buildDrawerItem(7, Icons.info_outline_rounded, 'About Auraliss', context),

                    const SizedBox(height: 32),
                    const Divider(height: 24, indent: 20, endIndent: 20),

                    // Special Actions (Dual-Tone Orange Intent Semantics)
                    _buildDrawerItem(-2, Icons.swap_horiz_rounded, 'Switch to C-Suite View', context, isSpecial: true),
                    _buildDrawerItem(-1, Icons.logout_rounded, 'Log Out', context, isIntent: true),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    int index,
    IconData icon,
    String title,
    BuildContext context, {
    bool isIntent = false,
    bool isSpecial = false,
  }) {
    final bool isSelected = selectedDrawerIndex == index;

    Color iconColor = AppColors.textMuted;
    Color textColor = AppColors.textSecondary;

    if (isSelected) {
      iconColor = AppColors.teal; // Teal active state
      textColor = AppColors.textPrimary;
    } else if (isIntent || isSpecial) {
      iconColor = AppColors.orange; // Orange intent accent
      textColor = AppColors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (isSpecial) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Switched to C-Suite Executive Telemetry Dashboard.'),
                backgroundColor: AppColors.orange,
              ),
            );
            return;
          }
          if (isIntent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out of session.'),
                backgroundColor: AppColors.orange,
              ),
            );
            return;
          }
          onSelectDrawerIndex(index);
        },
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x100A0D2F),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
                )
              : BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
          child: ListTile(
            dense: true,
            leading: Icon(icon, color: iconColor, size: 22),
            title: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
