import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final bool isInset;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 20.0,
    this.backgroundColor = AppColors.surface,
    this.border,
    this.onTap,
    this.isInset = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: isInset ? null : AppShadows.raised(),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
