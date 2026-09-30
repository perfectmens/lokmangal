import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

class NeumorphicBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeumorphicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, left: 16.0, right: 16.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppShadows.dock(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.precision_manufacturing_rounded, 'Process'),
              _buildNavItem(2, Icons.factory_rounded, 'Production'),
              _buildNavItem(3, Icons.bolt_rounded, 'Energy'),
              _buildNavItem(4, Icons.notifications_active_rounded, 'Alarms'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String tooltip) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x100A0D2F),
                    offset: Offset(3, 3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.teal : AppColors.textMuted,
          size: 22,
        ),
      ),
    );
  }
}
