import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../models/plant_models.dart';

class LivePlantEventTicker extends StatefulWidget {
  final List<PlantEvent> events;

  const LivePlantEventTicker({super.key, required this.events});

  @override
  State<LivePlantEventTicker> createState() => _LivePlantEventTickerState();
}

class _LivePlantEventTickerState extends State<LivePlantEventTicker>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (widget.events.isNotEmpty && mounted) {
        _animController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % widget.events.length;
            });
            _animController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.orange;
      case 'WARNING':
        return const Color(0xFFFFB020);
      case 'POSITIVE':
        return AppColors.teal;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'CRITICAL':
        return Icons.error_rounded;
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'POSITIVE':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.recessed(),
        ),
        child: const Text(
          'Telemetry telemetry feed active',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      );
    }

    final event = widget.events[_currentIndex % widget.events.length];
    final color = _getCategoryColor(event.category);
    final icon = _getCategoryIcon(event.category);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0A0D2F),
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  event.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
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
