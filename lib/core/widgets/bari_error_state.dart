import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'bari_button.dart';

/// Reusable error state display with retry trigger.
class BariErrorState extends StatelessWidget {
  const BariErrorState({
    super.key,
    required this.message,
    this.title = 'তথ্য লোড করা যায়নি (Unable to Load)',
    this.onRetry,
    this.retryLabel = 'পুনরায় চেষ্টা করুন (Retry)',
    this.customIcon,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData? customIcon;

  IconData _resolveIcon() {
    if (customIcon != null) return customIcon!;
    final lower = message.toLowerCase();
    if (lower.contains('সংযোগ') ||
        lower.contains('ইন্টারনেট') ||
        lower.contains('unreachable') ||
        lower.contains('connection')) {
      return Icons.cloud_off_rounded;
    }
    if (lower.contains('সময়') || lower.contains('timeout')) {
      return Icons.timer_off_outlined;
    }
    if (lower.contains('সেশন') || lower.contains('session') || lower.contains('অনুমতি')) {
      return Icons.lock_clock_outlined;
    }
    return Icons.dns_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorSoft.withAlpha(200),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error.withAlpha(60), width: 1.5),
              ),
              child: Icon(
                _resolveIcon(),
                size: 42,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 22),
              BariButton(
                label: retryLabel,
                onPressed: onRetry,
                isFullWidth: false,
                leadingIcon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
