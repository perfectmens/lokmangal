import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';

class GuideStepData {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<GuideFeatureItem> items;

  const GuideStepData({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.items,
  });
}

class GuideFeatureItem {
  final String label;
  final String detail;
  final IconData icon;

  const GuideFeatureItem({
    required this.label,
    required this.detail,
    required this.icon,
  });
}

class AppGuideModal extends StatefulWidget {
  const AppGuideModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const AppGuideModal(),
    );
  }

  @override
  State<AppGuideModal> createState() => _AppGuideModalState();
}

class _AppGuideModalState extends State<AppGuideModal> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const List<GuideStepData> _steps = [
    GuideStepData(
      category: 'EXECUTIVE C-SUITE · SLIDE 0',
      title: 'Plant Capacity & High-Level KPIs',
      description:
          'Strategic high-level overview tailored for leadership, plant managers, and decision-makers.',
      icon: Icons.insights_rounded,
      accentColor: AppColors.teal,
      items: [
        GuideFeatureItem(
          label: 'Plant Design Capacity',
          detail:
              'View 20 TPD benchmark, shift targets (6,667 kg), realtime factory output (3,410 kg), and utilization percentage.',
          icon: Icons.speed_rounded,
        ),
        GuideFeatureItem(
          label: 'Electricity Consumption',
          detail:
              'Live hourly power draw (kW), specific energy per kg produced (kWh/kg), and total shift consumption.',
          icon: Icons.bolt_rounded,
        ),
        GuideFeatureItem(
          label: 'Shift-wise Output History',
          detail:
              'Chronological bar chart of Shift A, B, and C with the current active shift pinned to the top.',
          icon: Icons.bar_chart_rounded,
        ),
      ],
    ),
    GuideStepData(
      category: 'OPERATIONS FLOOR · SLIDE 1',
      title: 'Floor Controls & Production Pacing',
      description:
          'Real-time machine pacing and operational instrumentation for floor supervisors and line technicians.',
      icon: Icons.precision_manufacturing_rounded,
      accentColor: AppColors.orange,
      items: [
        GuideFeatureItem(
          label: 'Production Targets Console',
          detail:
              'Dual circular arc gauges tracking Shift Target completion and hourly pacing with 20 TPD shift tracker.',
          icon: Icons.track_changes_rounded,
        ),
        GuideFeatureItem(
          label: 'Hourly Production Pacing Graph',
          detail:
              'Full 8-hour shift timeline with 100% width target line (833 kg/h) and a moving live half-trend line.',
          icon: Icons.show_chart_rounded,
        ),
        GuideFeatureItem(
          label: 'Machinery & Storage Silos',
          detail:
              'Live crystallization state for Powder Maker #1 and fill levels for finished storage silos & syrup tanks.',
          icon: Icons.inventory_2_rounded,
        ),
      ],
    ),
    GuideStepData(
      category: 'NAVIGATION · SIDE PANEL',
      title: 'Side Panel & Quick Switcher',
      description:
          'Instant, non-intrusive navigation drawer to jump between executive analytics and floor controls.',
      icon: Icons.menu_open_rounded,
      accentColor: AppColors.teal,
      items: [
        GuideFeatureItem(
          label: 'Open from Anywhere',
          detail:
              'Swipe right from the left screen edge or tap the Plant Logo button on the top floating dock.',
          icon: Icons.swipe_right_rounded,
        ),
        GuideFeatureItem(
          label: 'One-Tap Slide Switching',
          detail:
              'Instantly switch between Executive (C-Suite) and Operations (Floor) slides without losing context.',
          icon: Icons.tab_rounded,
        ),
        GuideFeatureItem(
          label: 'Operator Session & Logout',
          detail:
              'Verify active operator session (demo) and securely sign out with one tap.',
          icon: Icons.account_circle_rounded,
        ),
      ],
    ),
    GuideStepData(
      category: 'LIFECYCLE · SETTINGS & UPDATES',
      title: 'Over-The-Air (OTA) Updates',
      description:
          'Built-in software delivery engine ensuring your plant terminal always runs the latest validated build.',
      icon: Icons.system_update_rounded,
      accentColor: AppColors.orange,
      items: [
        GuideFeatureItem(
          label: 'Automated Update Detection',
          detail:
              'Scans GitHub Releases in the background for signed APK binaries with version comparison.',
          icon: Icons.cloud_download_rounded,
        ),
        GuideFeatureItem(
          label: '1-Tap Background Download & Install',
          detail:
              'Direct APK download with live percentage progress, checksum integrity validation, and instant install.',
          icon: Icons.verified_user_rounded,
        ),
        GuideFeatureItem(
          label: 'Telemetry Server Configuration',
          detail:
              'Seamlessly adjust backend REST endpoints between simulated demo and live factory network servers.',
          icon: Icons.router_rounded,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    HapticFeedback.lightImpact();
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final bool isLast = _currentStep == _steps.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 660),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppShadows.card(),
          ),
          child: Column(
            children: [
              // Top Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: step.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: step.accentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'STEP ${_currentStep + 1} OF ${_steps.length}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: step.accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textMuted),
                      splashRadius: 20,
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close Guide',
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Page View Body
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (idx) {
                    setState(() => _currentStep = idx);
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final data = _steps[index];
                    return _buildStepSlide(data);
                  },
                ),
              ),

              const Divider(height: 1),

              // Bottom Navigation & Stepper Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(_steps.length, (idx) {
                        final bool isActive = idx == _currentStep;
                        return GestureDetector(
                          onTap: () => _goToStep(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? step.accentColor : AppColors.divider,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),

                    // Back Button (hidden on step 0)
                    if (_currentStep > 0) ...[
                      NeumorphicButton(
                        tone: NeumorphicTone.neutral,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        borderRadius: 14,
                        onPressed: () => _goToStep(_currentStep - 1),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],

                    // Next / Finish Button
                    NeumorphicButton(
                      tone: isLast ? NeumorphicTone.teal : NeumorphicTone.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      borderRadius: 14,
                      onPressed: () {
                        if (isLast) {
                          Navigator.of(context).pop();
                        } else {
                          _goToStep(_currentStep + 1);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Got It' : 'Next',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isLast ? AppColors.teal : AppColors.orange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 16,
                            color: isLast ? AppColors.teal : AppColors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepSlide(GuideStepData data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon & Badge Row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppShadows.circularButton(),
                ),
                child: Icon(data.icon, color: data.accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.category,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: data.accentColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Features List Card
          NeumorphicCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: data.items.map((item) {
                final bool isLastItem = item == data.items.last;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLastItem ? 0 : 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: data.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, size: 14, color: data.accentColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.detail,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
