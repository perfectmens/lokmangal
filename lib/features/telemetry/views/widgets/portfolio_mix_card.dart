import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../models/telemetry_data.dart';

class PortfolioMixCard extends StatelessWidget {
  final PlantInfo plant;

  const PortfolioMixCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Lines', style: AppTypography.heading2),
                    Text(
                      'Corelife Wholefoods Portfolio',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProductTile(
                  name: 'Jaggery',
                  sub: 'Jaggery Powder',
                  detail: '20 TPD Plant Rating',
                  color: AppColors.teal,
                  bgColor: AppColors.tealLight,
                  icon: Icons.grain_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProductTile(
                  name: 'Liquid Sugars',
                  sub: 'Syrup Tank System',
                  detail: '5,000 kg Tank Capacity',
                  color: AppColors.orange,
                  bgColor: AppColors.orangeLight,
                  icon: Icons.water_drop_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile({
    required String name,
    required String sub,
    required String detail,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0A0D2F),
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: AppTypography.caption.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
