import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  const NeumorphicTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: AppShadows.pill(isSelected: true),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
