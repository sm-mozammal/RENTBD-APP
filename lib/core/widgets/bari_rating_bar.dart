import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Compact star rating and review count indicator.
class BariRatingBar extends StatelessWidget {
  const BariRatingBar({
    super.key,
    required this.rating,
    this.reviewCount,
    this.iconSize = 14.0,
    this.showRatingText = true,
  });

  final double rating;
  final int? reviewCount;
  final double iconSize;
  final bool showRatingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          size: iconSize,
          color: AppColors.secondary,
        ),
        if (showRatingText) ...[
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.lightTextMuted,
            ),
          ),
        ],
      ],
    );
  }
}
