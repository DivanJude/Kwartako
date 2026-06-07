import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class WeeklySummaryCard extends StatelessWidget {
  final double allowance;
  final double totalSpent;
  final double remaining;
  final VoidCallback? onReflectTap;

  const WeeklySummaryCard({
    super.key,
    required this.allowance,
    required this.totalSpent,
    required this.remaining,
    this.onReflectTap,
  });

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<GlassThemeExtension>();
    final spentRatio = allowance > 0 ? (totalSpent / allowance).clamp(0.0, 1.0) : 0.0;
    final remainingPercentage = ((1.0 - spentRatio) * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: glassTheme?.accentCardDecoration ?? BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining Allowance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${remaining.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentCyan.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$remainingPercentage% left',
                  style: const TextStyle(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: ₱${totalSpent.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    'Total Allowance: ₱${allowance.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: spentRatio,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    spentRatio > 0.8 
                        ? AppColors.dangerRed 
                        : (spentRatio > 0.5 ? AppColors.warningYellow : AppColors.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 14),
          // Loop action tip
          GestureDetector(
            onTap: onReflectTap,
            child: Row(
              children: [
                const Icon(
                  Icons.loop_rounded,
                  color: AppColors.secondaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Weekly loop active: Saturday reflection awaits you.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.secondaryBlue,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
