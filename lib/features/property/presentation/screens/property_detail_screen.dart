import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/error_formatter.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';

/// Full Detailed View for a Property Listing with live API fetching,
/// AI Fair Rent Meter, Move-in Cost Estimator, Alley Width Preview,
/// Crowdsourced Dhaka Insights, and Landlord Direct Contact.
class PropertyDetailScreen extends StatefulWidget {
  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.initialProperty,
  });

  final String propertyId;
  final Property? initialProperty;

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _property = widget.initialProperty;

    // If initialProperty wasn't passed, check if PropertyBloc already holds it
    if (_property == null) {
      final blocState = context.read<PropertyBloc>().state;
      if (blocState is PropertyLoaded) {
        final matches = blocState.properties.where((p) => p.id == widget.propertyId);
        if (matches.isNotEmpty) {
          _property = matches.first;
        }
      }
    }

    // Always fetch latest from API in background or foreground to ensure up-to-date data
    _fetchPropertyDetail();
  }

  Future<void> _fetchPropertyDetail({bool isRefresh = false}) async {
    if (_property == null && !isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final fetched = await sl<PropertyRepository>().getPropertyById(widget.propertyId);
      if (!mounted) return;
      setState(() {
        _property = fetched;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_property == null) {
        setState(() {
          _errorMessage = RentBdErrorFormatter.format(e);
          _isLoading = false;
        });
      }
    }
  }

  void _onToggleSave() {
    if (_property == null) return;
    final newSavedStatus = !_property!.isSaved;

    setState(() {
      _property = _property!.copyWith(isSaved: newSavedStatus);
    });

    context.read<PropertyBloc>().add(ToggleSaveEvent(_property!.id));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              newSavedStatus ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              newSavedStatus
                  ? 'Added to Saved Properties'
                  : 'Removed from Saved Properties',
            ),
          ],
        ),
        backgroundColor: newSavedStatus ? AppColors.primary : AppColors.lightTextSecondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImageViewer(List<PropertyImage> images, int initialIndex) {
    if (images.isEmpty) return;
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(235),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final current = images[currentIndex];
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  maxScale: 3.5,
                  child: Center(
                    child: BariImage(
                      imageUrl: current.imageUrl,
                      fit: BoxFit.contain,
                      placeholderIcon: Icons.apartment_rounded,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                Positioned(
                  top: 46,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${images.length} • ${current.roomLabel}',
                      style: AppTypography.labelMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                if (images.length > 1) ...[
                  Positioned(
                    left: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 28),
                        onPressed: currentIndex > 0
                            ? () => setDialogState(() => currentIndex--)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 28),
                        onPressed: currentIndex < images.length - 1
                            ? () => setDialogState(() => currentIndex++)
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertyLoaded && _property != null) {
          final updated = state.properties.where((p) => p.id == _property!.id);
          if (updated.isNotEmpty) {
            setState(() {
              _property = _property!.copyWith(
                isSaved: updated.first.isSaved,
              );
            });
          }
        }
      },
      child: Scaffold(
        body: _buildBody(),
        bottomSheet: _property != null ? _buildBottomActionBar(_property!) : null,
      ),
    );
  }

  Widget _buildBody() {
    // 1. Loading state when no property is cached
    if (_isLoading && _property == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home),
          ),
          title: const Text('Property Details'),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Loading property details...'),
            ],
          ),
        ),
      );
    }

    // 2. Error state when fetching fails and no property is cached
    if (_errorMessage != null && _property == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home),
          ),
          title: const Text('Property Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Listing Not Found',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 24),
                BariButton(
                  label: 'Try Again',
                  leadingIcon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: () => _fetchPropertyDetail(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final property = _property!;
    final images = property.images;
    final currentImage = images.isNotEmpty && _selectedImageIndex < images.length
        ? images[_selectedImageIndex]
        : (images.isNotEmpty ? images.first : null);

    return RefreshIndicator(
      onRefresh: () => _fetchPropertyDetail(isRefresh: true),
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Image Gallery SliverAppBar
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: AppColors.lightTextPrimary,
                onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    property.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: property.isSaved ? AppColors.error : AppColors.lightTextPrimary,
                  ),
                  onPressed: _onToggleSave,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => _showImageViewer(images, _selectedImageIndex),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Active Image
                    if (currentImage != null)
                      BariImage(
                        imageUrl: currentImage.imageUrl,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.apartment_rounded,
                      )
                    else
                      Container(
                        color: AppColors.primarySoft,
                        child: const Center(
                          child: Icon(Icons.home_work_rounded, size: 64, color: AppColors.primary),
                        ),
                      ),

                    // Gradient Bottom Overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(60),
                              Colors.transparent,
                              Colors.black.withAlpha(150),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Room Tag & GPS Tag Badge (Bottom Left)
                    if (currentImage != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(190),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    'AI Tag: ${currentImage.roomLabel}',
                                    style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            if (currentImage.isGeoTagged) ...[
                              const SizedBox(width: 8),
                              const BariBadge(
                                type: BariBadgeType.geoTaggedPhoto,
                                isCompact: true,
                              ),
                            ],
                          ],
                        ),
                      ),

                    // Image Counter / Tap to Enlarge
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(180),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              images.isNotEmpty ? '${_selectedImageIndex + 1}/${images.length}' : '1/1',
                              style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo thumbnails selector strip
                  if (images.length > 1) ...[
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final img = images[index];
                          final isSelected = _selectedImageIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedImageIndex = index),
                            child: Container(
                              width: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: BariImage(
                                imageUrl: img.imageUrl,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(7.5),
                                placeholderColor: AppColors.primarySoft,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Rent Price and Category / Availability Badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BariPriceTag(
                        amount: property.rentAmount,
                        size: BariPriceSize.large,
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.end,
                        children: [
                          BariBadge(
                            type: BariBadgeType.custom,
                            customLabel: property.tenantCategoryLabel,
                            customColor: property.tenantCategory == TenantCategory.family
                                ? AppColors.family
                                : AppColors.bachelor,
                            customBgColor: property.tenantCategory == TenantCategory.family
                                ? AppColors.familySoft
                                : AppColors.bachelorSoft,
                          ),
                          if (property.isPendingReview)
                            const BariBadge(
                              type: BariBadgeType.underReview,
                              isCompact: true,
                            )
                          else ...[
                            const BariBadge(
                              type: BariBadgeType.approved,
                              isCompact: true,
                            ),
                            BariBadge(
                              type: property.isAvailable ? BariBadgeType.available : BariBadgeType.rented,
                              isCompact: true,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Listing Title
                  Text(
                    property.title,
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                  ),

                  if (property.isPendingReview) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withAlpha(70)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, color: AppColors.secondary, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Under Admin Review: This listing is currently awaiting admin verification before becoming publicly available.',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),

                  // Full Address line with Pin icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          property.fullAddress,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.lightTextSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Key Specifications Grid
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpecCol(Icons.bed_rounded, property.bedrooms > 0 ? '${property.bedrooms} Beds' : 'N/A Beds'),
                        _buildSpecCol(Icons.bathtub_rounded, property.bathrooms > 0 ? '${property.bathrooms} Baths' : 'N/A Baths'),
                        _buildSpecCol(Icons.balcony_rounded, property.balconies > 0 ? '${property.balconies} Balcony' : 'N/A Balcony'),
                        _buildSpecCol(Icons.square_foot_rounded, property.squareFeet > 0 ? '${property.squareFeet} SqFt' : 'N/A SqFt'),
                        _buildSpecCol(Icons.stairs_rounded, property.floorLevel > 0 ? 'Floor ${property.floorLevel}' : 'Floor N/A'),
                        _buildSpecCol(Icons.traffic_rounded, property.alleyWidthFeet > 0 ? '${property.alleyWidthFeet.toInt()}ft Road' : 'N/A Road'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 1. Monthly Recurring Cost Breakdown
                  _buildMonthlyRecurringCard(property),
                  const SizedBox(height: 20),

                  // 2. AI Fair Rent Meter Widget
                  _buildAiFairRentMeter(property),
                  const SizedBox(height: 20),

                  // 3. Move-in Cost Estimator Card
                  _buildMoveInCostCard(property),
                  const SizedBox(height: 20),

                  // 4. Street View & Alley Width Inspection Preview
                  _buildAlleyWidthPreview(property),
                  const SizedBox(height: 20),

                  // 5. Crowdsourced Dhaka Area Insights
                  _buildAreaInsights(property),
                  const SizedBox(height: 20),

                  // 6. Property Amenities Checklist
                  _buildAmenitiesGrid(property),
                  const SizedBox(height: 20),

                  // 7. Full Description
                  Text(
                    'About this Property (বিস্তারিত বিবরণ)',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 8. Verified Landlord Profile Card
                  _buildLandlordCard(property),
                  const SizedBox(height: 110), // Padding for bottom floating bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCol(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRecurringCard(Property property) {
    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Monthly Expenses (মাসিক খরচ)',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCostRow('Monthly Flat Rent', '৳ ${property.rentAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'),
          _buildCostRow(
            'Service Charge / Building Maintenance',
            property.serviceCharge > 0
                ? '৳ ${property.serviceCharge.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                : 'N/A',
          ),
          _buildCostRow(
            'Estimated Utilities (WASA & Gas)',
            property.estimatedUtilities > 0
                ? '৳ ${property.estimatedUtilities.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                : 'N/A',
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Monthly Recurring',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '৳ ${property.totalMonthlyRecurring.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}/mo',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiFairRentMeter(Property property) {
    Color statusColor;
    String statusTitle;
    String statusDesc;

    switch (property.fairPriceStatus) {
      case FairPriceStatus.greatDeal:
        statusColor = AppColors.greatDeal;
        statusTitle = 'Great Deal (AI Verified)';
        statusDesc = property.areaAverageRent > 0
            ? '${property.fairPricePercentDiff.abs().toStringAsFixed(1)}% below the ${property.areaNeighborhood.isNotEmpty ? property.areaNeighborhood : "Dhaka"} average!'
            : 'Below neighborhood average rental rate.';
        break;
      case FairPriceStatus.fairPrice:
        statusColor = AppColors.fairPrice;
        statusTitle = 'Fair Market Price';
        statusDesc = 'Matches current neighborhood rental averages accurately.';
        break;
      case FairPriceStatus.overpriced:
        statusColor = AppColors.overpriced;
        statusTitle = 'Slightly Above Average';
        statusDesc = 'Reflects premium luxury fittings and building amenities.';
        break;
    }

    return BariCard(
      backgroundColor: statusColor.withAlpha(15),
      borderColor: statusColor.withAlpha(60),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Fair Rent Meter',
                    style: AppTypography.titleMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              BariBadge(
                type: property.fairPriceStatus == FairPriceStatus.greatDeal
                    ? BariBadgeType.greatDeal
                    : BariBadgeType.fairPrice,
                isCompact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            statusTitle,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusDesc,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Comparison Bar
          if (property.areaAverageRent > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (property.rentAmount / (property.areaAverageRent * 1.3)).clamp(0.1, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listed: ৳ ${property.rentAmount.toInt()}',
                style: AppTypography.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.w700),
              ),
              Text(
                property.areaAverageRent > 0
                    ? 'Area Avg: ৳ ${property.areaAverageRent.toInt()}'
                    : 'Area Avg: N/A',
                style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoveInCostCard(Property property) {
    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Move-in Cost Estimator',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Detailed Calculator →'),
                onPressed: () {
                  context.pushNamed(
                    RouteNames.moveInCalculator,
                    pathParameters: {'id': property.id},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCostRow('Base Rent (1st Month)', '৳ ${property.rentAmount.toInt()}'),
          _buildCostRow(
            'Security Deposit (Advance)',
            property.securityDeposit > 0 ? '৳ ${property.securityDeposit.toInt()}' : 'N/A',
          ),
          _buildCostRow(
            'Service Charge',
            property.serviceCharge > 0 ? '৳ ${property.serviceCharge.toInt()}' : 'N/A',
          ),
          _buildCostRow(
            'Estimated Utilities (WASA/Gas)',
            property.estimatedUtilities > 0 ? '৳ ${property.estimatedUtilities.toInt()}' : 'N/A',
          ),
          _buildCostRow('Estimated Moving Transport', '৳ 3,000'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Upfront Cash',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              BariPriceTag(
                amount: property.defaultUpfrontMoveInCost,
                showPeriod: false,
                size: BariPriceSize.large,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
          ),
          Text(
            amount,
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAlleyWidthPreview(Property property) {
    final hasAlleyWidth = property.alleyWidthFeet > 0;
    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.secondary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Road Access & Alley Width',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  hasAlleyWidth
                      ? '${property.alleyWidthFeet.toInt()} ft Front Road • Moving truck & private car accessible'
                      : 'Front road access info not provided (N/A)',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          BariBadge(
            type: BariBadgeType.custom,
            customLabel: hasAlleyWidth ? '${property.alleyWidthFeet.toInt()} ft' : 'N/A',
            customColor: AppColors.secondary,
            customBgColor: AppColors.secondarySoft,
            isCompact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAreaInsights(Property property) {
    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Crowdsourced Area Insights (এলাকার তথ্য)',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.water_drop_outlined,
                  title: 'Waterlogging',
                  value: property.waterloggingRisk == WaterloggingRisk.none
                      ? 'Zero Risk'
                      : property.waterloggingRisk == WaterloggingRisk.mild
                          ? 'Mild Risk'
                          : 'High Risk',
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Gas Line',
                  value: property.gasSupply == GasSupplyType.lineGas
                      ? 'Line Gas'
                      : property.gasSupply == GasSupplyType.cylinder
                          ? 'Cylinder Gas'
                          : 'N/A',
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.shield_outlined,
                  title: 'Night Safety',
                  value: property.nightSafetyRating > 0 ? '${property.nightSafetyRating} / 5.0' : 'N/A',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(Property property) {
    final amenities = [
      {'label': property.gasSupply == GasSupplyType.lineGas ? 'Line Gas' : 'Cylinder Gas', 'icon': Icons.local_fire_department_rounded},
      {'label': 'Elevator / Lift', 'icon': Icons.elevator_rounded},
      {'label': 'Generator Backup', 'icon': Icons.bolt_rounded},
      {'label': '24/7 Security Guard', 'icon': Icons.security_rounded},
      {'label': 'CCTV Surveillance', 'icon': Icons.videocam_outlined},
      {'label': 'Car Parking', 'icon': Icons.local_parking_rounded},
      {'label': 'Balcony', 'icon': Icons.balcony_rounded},
      {'label': 'WASA Water', 'icon': Icons.water_drop_rounded},
    ];

    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Amenities & Facilities (সুযোগ সুবিধা)',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: amenities.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLandlordCard(Property property) {
    final landlordName = property.landlordName.trim().isNotEmpty ? property.landlordName.trim() : 'N/A';
    final landlordPhone = property.landlordPhoneMasked.trim().isNotEmpty ? property.landlordPhoneMasked.trim() : 'N/A';
    final hasVerifiedNid = property.landlordIsNidVerified;

    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          BariAvatar(
            name: landlordName,
            radius: 26,
            isVerified: hasVerifiedNid,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        landlordName,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasVerifiedNid) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 16),
                    ],
                  ],
                ),
                Text(
                  '${hasVerifiedNid ? "Verified Landlord" : "Unverified"} • $landlordPhone',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 4),
                if (property.landlordRating > 0)
                  BariRatingBar(rating: property.landlordRating, reviewCount: 8)
                else
                  Text(
                    'Rating: N/A',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(Property property) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.lightBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Schedule Visit Button
            Expanded(
              flex: 5,
              child: BariButton(
                label: 'Schedule Visit',
                variant: BariButtonVariant.outline,
                leadingIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                onPressed: () {
                  try {
                    context.pushNamed(RouteNames.visits);
                  } catch (_) {}
                },
              ),
            ),
            const SizedBox(width: 12),
            // Masked Chat Button
            Expanded(
              flex: 5,
              child: BariButton(
                label: 'Masked Chat',
                variant: BariButtonVariant.primary,
                leadingIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                onPressed: () {
                  try {
                    context.pushNamed(
                      RouteNames.chatRoom,
                      pathParameters: {'id': property.id},
                    );
                  } catch (_) {}
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
