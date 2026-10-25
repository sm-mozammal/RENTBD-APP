import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BariPriceSize { compact, normal, large, hero }

/// Reusable Price Tag widget for BDT Currency formatting (৳).
class BariPriceTag extends StatelessWidget {
  const BariPriceTag({
    super.key,
    required this.amount,
    this.period = '/mo',
    this.size = BariPriceSize.normal,
    this.color,
    this.showPeriod = true,
  });

  final num amount;
  final String period;
  final BariPriceSize size;
  final Color? color;
  final bool showPeriod;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,###', 'en_US');
    final formattedAmount = formatter.format(amount);
    final effectiveColor = color ?? AppColors.primary;

    TextStyle amountStyle;
    TextStyle periodStyle;

    switch (size) {
      case BariPriceSize.compact:
        amountStyle = AppTypography.titleMedium.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w700,
        );
        periodStyle = AppTypography.labelSmall.copyWith(
          color: AppColors.lightTextSecondary,
        );
        break;
      case BariPriceSize.normal:
        amountStyle = AppTypography.headlineMedium.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w800,
        );
        periodStyle = AppTypography.bodySmall.copyWith(
          color: AppColors.lightTextSecondary,
        );
        break;
      case BariPriceSize.large:
        amountStyle = AppTypography.headlineLarge.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w800,
        );
        periodStyle = AppTypography.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        );
        break;
      case BariPriceSize.hero:
        amountStyle = AppTypography.displayMedium.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w800,
        );
        periodStyle = AppTypography.titleMedium.copyWith(
          color: AppColors.lightTextSecondary,
        );
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '৳ $formattedAmount',
          style: amountStyle,
        ),
        if (showPeriod) ...[
          const SizedBox(width: 2),
          Text(
            period,
            style: periodStyle,
          ),
        ],
      ],
    );
  }
}
