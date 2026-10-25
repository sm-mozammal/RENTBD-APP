import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BariButtonVariant { primary, secondary, outline, danger, ghost }

/// RentBD Universal Button Component.
/// Reusable across all forms, dialogs, bottom sheets, and action bars.
class BariButton extends StatelessWidget {
  const BariButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BariButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.isFullWidth = true,
    this.height = 50.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final BariButtonVariant variant;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case BariButtonVariant.primary:
        backgroundColor = isEnabled ? AppColors.primary : AppColors.primary.withAlpha(120);
        foregroundColor = Colors.white;
        break;
      case BariButtonVariant.secondary:
        backgroundColor = isEnabled ? AppColors.secondary : AppColors.secondary.withAlpha(120);
        foregroundColor = Colors.white;
        break;
      case BariButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.primary : AppColors.lightTextMuted;
        borderSide = BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.lightBorder,
          width: 1.5,
        );
        break;
      case BariButtonVariant.danger:
        backgroundColor = isEnabled ? AppColors.error : AppColors.error.withAlpha(120);
        foregroundColor = Colors.white;
        break;
      case BariButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.primary : AppColors.lightTextMuted;
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Please wait...',
            style: AppTypography.labelLarge.copyWith(color: foregroundColor),
          ),
        ] else ...[
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(color: foregroundColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            trailingIcon!,
          ],
        ],
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          ),
        ),
      ),
    );
  }
}
