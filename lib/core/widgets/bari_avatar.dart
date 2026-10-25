import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable user avatar with optional NID verified checkmark badge.
class BariAvatar extends StatelessWidget {
  const BariAvatar({
    super.key,
    this.imageUrl,
    this.name = 'User',
    this.radius = 24.0,
    this.isVerified = false,
  });

  final String? imageUrl;
  final String name;
  final double radius;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primarySoft,
          backgroundImage: imageUrl != null && imageUrl!.startsWith('http')
              ? NetworkImage(imageUrl!)
              : null,
          child: (imageUrl == null || !imageUrl!.startsWith('http'))
              ? Text(
                  initials,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: radius * 0.75,
                  ),
                )
              : null,
        ),
        if (isVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: radius * 0.45,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
