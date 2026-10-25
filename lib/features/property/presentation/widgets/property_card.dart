import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/property.dart';

/// Reusable Property Feed Card component.
/// Displays verified photo badge, fair rent badge, specs, and price tag.
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onToggleSave,
  });

  final Property property;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    final firstImage = property.images.isNotEmpty
        ? property.images.first.imageUrl
        : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800';

    return BariCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: BariImage(
                    imageUrl: firstImage,
                    fit: BoxFit.cover,
                    placeholderIcon: Icons.apartment_rounded,
                  ),
                ),
              ),

              // Gradient Overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(80),
                        Colors.transparent,
                        Colors.black.withAlpha(60),
                      ],
                    ),
                  ),
                ),
              ),

              // Badges top-left
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    if (property.isPendingReview)
                      const BariBadge(
                        type: BariBadgeType.underReview,
                        isCompact: true,
                      )
                    else if (property.hasGeoTaggedPhotos)
                      const BariBadge(
                        type: BariBadgeType.geoTaggedPhoto,
                        isCompact: true,
                      ),
                    if (property.fairPriceStatus == FairPriceStatus.greatDeal) ...[
                      const SizedBox(width: 6),
                      const BariBadge(
                        type: BariBadgeType.greatDeal,
                        isCompact: true,
                      ),
                    ],
                  ],
                ),
              ),

              // Wishlist Heart Button top-right
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withAlpha(220),
                  shape: const CircleBorder(),
                  child: IconButton(
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      property.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: property.isSaved ? AppColors.error : AppColors.lightTextPrimary,
                      size: 20,
                    ),
                    onPressed: onToggleSave,
                  ),
                ),
              ),

              // Category Badge bottom-left
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    property.tenantCategoryLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Location line
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.areaNeighborhood}, Dhaka',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Specs chips: Beds, Baths, SqFt
                Row(
                  children: [
                    _buildSpecItem(Icons.bed_outlined, property.bedrooms > 0 ? '${property.bedrooms} Beds' : 'N/A Beds'),
                    const SizedBox(width: 12),
                    _buildSpecItem(Icons.bathtub_outlined, property.bathrooms > 0 ? '${property.bathrooms} Baths' : 'N/A Baths'),
                    const SizedBox(width: 12),
                    _buildSpecItem(Icons.square_foot_rounded, property.squareFeet > 0 ? '${property.squareFeet} sqft' : 'N/A sqft'),
                    const Spacer(),
                    _buildSpecItem(
                      Icons.traffic_rounded,
                      property.alleyWidthFeet > 0 ? '${property.alleyWidthFeet.toInt()}ft road' : 'N/A road',
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Price and Landlord credibility
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BariPriceTag(
                      amount: property.rentAmount,
                      size: BariPriceSize.normal,
                    ),
                    Row(
                      children: [
                        if (property.landlordIsNidVerified) ...[
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          property.landlordName.trim().isNotEmpty ? property.landlordName.trim() : 'N/A',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text, {Color? color}) {
    final effectiveColor = color ?? AppColors.lightTextSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: effectiveColor),
        const SizedBox(width: 3.5),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: effectiveColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
