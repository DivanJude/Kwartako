import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class BudgetAllocationCard extends StatelessWidget {
  final ExpenseCategory category;
  final double allocatedAmount;
  final double percentage; // 0.0 to 1.0
  final ValueChanged<double>? onChanged;

  const BudgetAllocationCard({
    super.key,
    required this.category,
    required this.allocatedAmount,
    required this.percentage,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<GlassThemeExtension>();
    final catColor = category.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: glassTheme?.cardDecoration ?? BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: catColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Category details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${(percentage * 100).toStringAsFixed(0)}% allocation',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Price text
                Text(
                  '₱${allocatedAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            if (onChanged != null) ...[
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: catColor,
                  inactiveTrackColor: Colors.white.withOpacity(0.05),
                  thumbColor: catColor,
                  overlayColor: catColor.withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: percentage,
                  min: 0.0,
                  max: 1.0,
                  onChanged: onChanged,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
