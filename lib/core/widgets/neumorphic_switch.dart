import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

class NeumorphicSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? AppColors.tealLight : AppColors.surface,
          border: Border.all(
            color: value ? AppColors.teal.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: AppShadows.pill(isSelected: value),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? AppColors.teal : AppColors.textMuted,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x200A0D2F),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
