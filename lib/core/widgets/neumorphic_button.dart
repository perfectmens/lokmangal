import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

enum NeumorphicTone { orange, teal, neutral }

class NeumorphicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final NeumorphicTone tone;
  final bool isFullWidth;
  final bool isLoading;
  final double borderRadius;
  final EdgeInsets padding;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.tone = NeumorphicTone.orange,
    this.isFullWidth = false,
    this.isLoading = false,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    Color bg;
    Color fg;

    switch (widget.tone) {
      case NeumorphicTone.orange:
        bg = AppColors.surface;
        fg = isDisabled ? AppColors.textMuted : AppColors.orange;
        break;
      case NeumorphicTone.teal:
        bg = AppColors.surface;
        fg = isDisabled ? AppColors.textMuted : AppColors.teal;
        break;
      case NeumorphicTone.neutral:
        bg = AppColors.surface;
        fg = isDisabled ? AppColors.textMuted : AppColors.textPrimary;
        break;
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.isFullWidth ? double.infinity : null,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.tone == NeumorphicTone.orange
                ? AppColors.orange.withValues(alpha: 0.3)
                : widget.tone == NeumorphicTone.teal
                    ? AppColors.teal.withValues(alpha: 0.3)
                    : AppColors.borderLight.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: (_isPressed || isDisabled)
              ? null
              : AppShadows.raised(
                  blur: 10,
                  offset: const Offset(4, 4),
                  darkOpacity: 0.08,
                ),
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              : widget.child ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 18),
                        if (widget.text != null) const SizedBox(width: 8),
                      ],
                      if (widget.text != null)
                        Text(
                          widget.text!,
                          style: AppTypography.button.copyWith(color: fg),
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}
