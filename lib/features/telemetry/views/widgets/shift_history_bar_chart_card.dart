import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

/// Horizontal bar chart showing last 7 shifts.
/// Teal = historical completed shifts. Orange = current live shift.
/// All data is backend-owned (is_current flag set by Python backend).
class ShiftHistoryBarChartCard extends StatelessWidget {
  final List<ShiftHistoryEntry> shifts;

  const ShiftHistoryBarChartCard({super.key, required this.shifts});

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return const SizedBox.shrink();
    }

    final double maxKg = shifts.map((s) => s.targetKg).reduce((a, b) => a > b ? a : b) * 1.1;

    // Ensure display order is new-to-old (current shift up, older shifts below)
    final displayShifts = (shifts.isNotEmpty && !shifts.first.isCurrent && shifts.any((s) => s.isCurrent))
        ? shifts.reversed.toList()
        : shifts;

    return NeumorphicCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppShadows.circularButton(),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: AppColors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Shift-wise Output', style: AppTypography.heading2),
                    const Text('Last 7 shifts · Target: 6,667 kg', style: AppTypography.caption),
                  ],
                ),
              ),
              // Legend
              Row(
                children: [
                  _legendDot(AppColors.teal, 'Done'),
                  const SizedBox(width: 10),
                  _legendDot(AppColors.orange, 'Live'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scrollable bar list (Newest/Current shift on top, older below)
          SizedBox(
            height: displayShifts.length * 48.0,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: displayShifts.length,
              itemBuilder: (context, i) {
                final shift = displayShifts[i];
                final double pct = (shift.actualKg / maxKg).clamp(0.0, 1.0);
                final double targetPct = (shift.targetKg / maxKg).clamp(0.0, 1.0);
                final Color barColor = shift.isCurrent ? AppColors.orange : AppColors.teal;
                final Color bgColor = shift.isCurrent ? AppColors.orangeLight : AppColors.tealLight;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      // Shift label
                      SizedBox(
                        width: 68,
                        child: Text(
                          shift.shiftLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: shift.isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: shift.isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // Bar
                      Expanded(
                        child: Stack(
                          children: [
                            // Background track
                            Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x120A0D2F), offset: Offset(2, 2), blurRadius: 4),
                                  BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
                                ],
                              ),
                            ),
                            // Target marker line
                            FractionallySizedBox(
                              widthFactor: targetPct,
                              child: Container(
                                height: 28,
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 1.5,
                                  color: AppColors.textMuted.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            // Actual bar
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              widthFactor: pct,
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: barColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  '${(shift.actualKg / 1000).toStringAsFixed(2)}t',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: barColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      );
}
