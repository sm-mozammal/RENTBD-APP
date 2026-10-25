import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'bari_button.dart';

/// Global fallback widget replacing Flutter's default Red/Grey Screen of Death.
/// Ensures the app remains interactive, accessible, and user-friendly even if
/// an unhandled rendering or widget assertion exception occurs.
class BariCrashRecoveryWidget extends StatelessWidget {
  const BariCrashRecoveryWidget({
    super.key,
    required this.errorDetails,
  });

  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft icon badge
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.home_work_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'RentBD অ্যাপ্লিকেশন',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'স্ক্রিনের কোনো একটি অংশ লোড হতে সাময়িক সমস্যা হয়েছে। আপনার ডাটা সম্পূর্ণ নিরাপদ আছে।',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BariButton(
                      label: 'হোম পেজে ফিরুন',
                      isFullWidth: false,
                      leadingIcon: const Icon(Icons.home_rounded, size: 18),
                      onPressed: () {
                        try {
                          AppRouter.router.goNamed(RouteNames.home);
                        } catch (_) {}
                      },
                    ),
                  ],
                ),

                // Debug info accordion for developers in debug mode only
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Details (Visible only in debug mode):',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          errorDetails.exceptionAsString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.black87,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
