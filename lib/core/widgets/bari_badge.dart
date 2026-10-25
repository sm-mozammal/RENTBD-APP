import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BariBadgeType {
  geoTaggedPhoto,
  nidVerified,
  greatDeal,
  fairPrice,
  overpriced,
  bachelor,
  family,
  sublet,
  rented,
  available,
  underReview,
  approved,
  custom,
}

/// RentBD Status & Quality Badge.
class BariBadge extends StatelessWidget {
  const BariBadge({
    super.key,
    required this.type,
    this.customLabel,
    this.customIcon,
    this.customColor,
    this.customBgColor,
    this.isCompact = false,
  });

  final BariBadgeType type;
  final String? customLabel;
  final IconData? customIcon;
  final Color? customColor;
  final Color? customBgColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    String label;
    IconData? icon;
    Color color;
    Color bgColor;

    switch (type) {
      case BariBadgeType.geoTaggedPhoto:
        label = 'Verified Real Photo';
        icon = Icons.verified_rounded;
        color = AppColors.primary;
        bgColor = AppColors.primarySoft;
        break;
      case BariBadgeType.nidVerified:
        label = 'NID Verified';
        icon = Icons.verified_user_rounded;
        color = AppColors.primaryDark;
        bgColor = AppColors.primarySoft;
        break;
      case BariBadgeType.greatDeal:
        label = 'Great Deal';
        icon = Icons.trending_down_rounded;
        color = AppColors.greatDeal;
        bgColor = AppColors.successSoft;
        break;
      case BariBadgeType.fairPrice:
        label = 'Fair Price';
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.fairPrice;
        bgColor = AppColors.infoSoft;
        break;
      case BariBadgeType.overpriced:
        label = 'Above Average';
        icon = Icons.trending_up_rounded;
        color = AppColors.overpriced;
        bgColor = AppColors.errorSoft;
        break;
      case BariBadgeType.bachelor:
        label = 'Bachelor';
        icon = Icons.person_rounded;
        color = AppColors.bachelor;
        bgColor = AppColors.bachelorSoft;
        break;
      case BariBadgeType.family:
        label = 'Family';
        icon = Icons.people_alt_rounded;
        color = AppColors.family;
        bgColor = AppColors.familySoft;
        break;
      case BariBadgeType.sublet:
        label = 'Sublet';
        icon = Icons.meeting_room_rounded;
        color = AppColors.sublet;
        bgColor = AppColors.subletSoft;
        break;
      case BariBadgeType.rented:
        label = 'Rented Out';
        icon = Icons.lock_outline_rounded;
        color = AppColors.lightTextMuted;
        bgColor = AppColors.lightDivider;
        break;
      case BariBadgeType.available:
        label = 'Available Now';
        icon = Icons.check_circle_rounded;
        color = AppColors.primary;
        bgColor = AppColors.primarySoft;
        break;
      case BariBadgeType.underReview:
        label = 'Under Admin Review';
        icon = Icons.hourglass_top_rounded;
        color = AppColors.secondary;
        bgColor = AppColors.secondary.withAlpha(30);
        break;
      case BariBadgeType.approved:
        label = 'Admin Approved';
        icon = Icons.verified_rounded;
        color = AppColors.success;
        bgColor = AppColors.successSoft;
        break;
      case BariBadgeType.custom:
        label = customLabel ?? '';
        icon = customIcon;
        color = customColor ?? AppColors.primary;
        bgColor = customBgColor ?? AppColors.primarySoft;
        break;
    }

    final verticalPadding = isCompact ? 3.0 : 5.0;
    final horizontalPadding = isCompact ? 8.0 : 10.0;
    final iconSize = isCompact ? 13.0 : 15.0;
    final textStyle = isCompact ? AppTypography.labelSmall : AppTypography.labelMedium;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(40),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            label,
            style: textStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
