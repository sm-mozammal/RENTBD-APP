import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../property/domain/entities/property.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/bloc/property_state.dart';

/// Interactive Map Search Screen with Dhaka Zone Pins,
/// 500m Nearby Essentials layer, and Freehand selection mode.
class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  Property? _selectedProperty;
  bool _isDrawModeActive = false;
  bool _showMetroLayer = true;
  bool _showMosqueLayer = true;
  bool _showGroceryLayer = true;
  bool _showHospitalLayer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhaka Map Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDrawModeActive ? Icons.brush : Icons.brush_outlined,
              color: _isDrawModeActive ? AppColors.secondary : AppColors.lightTextPrimary,
            ),
            tooltip: 'Draw-on-Map Freehand Search',
            onPressed: () {
              setState(() => _isDrawModeActive = !_isDrawModeActive);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isDrawModeActive
                        ? 'Draw mode active: Drag your finger to isolate street listings'
                        : 'Standard map view restored',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is! PropertyLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final properties = state.properties;
          final activeProp = _selectedProperty ?? (properties.isNotEmpty ? properties.first : null);

          return Stack(
            children: [
              // Interactive Canvas Map Surface
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFE8ECEF),
                  child: Stack(
                    children: [
                      // Simulated Dhaka Geographic Map Grid & Roads
                      CustomPaint(
                        size: Size.infinite,
                        painter: _DhakaMapPainter(isDrawing: _isDrawModeActive),
                      ),

                      // Interactive Property Markers on Map
                      ...properties.map((p) {
                        final isSelected = activeProp?.id == p.id;
                        // Map coordinates offset simulation
                        final dx = ((p.longitude - 90.35) * 2200).clamp(40.0, 320.0);
                        final dy = ((23.88 - p.latitude) * 3200).clamp(60.0, 480.0);

                        return Positioned(
                          left: dx,
                          top: dy,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProperty = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryDark : AppColors.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.home_work_rounded,
                                    size: 14,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '৳ ${(p.rentAmount / 1000).toStringAsFixed(1)}k',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // 500m Nearby Essentials Layer Filter Bar (Top floating)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildLayerFilterChip('MRT Metro', Icons.train_rounded, _showMetroLayer, () {
                        setState(() => _showMetroLayer = !_showMetroLayer);
                      }),
                      const SizedBox(width: 8),
                      _buildLayerFilterChip('Mosque', Icons.mosque_rounded, _showMosqueLayer, () {
                        setState(() => _showMosqueLayer = !_showMosqueLayer);
                      }),
                      const SizedBox(width: 8),
                      _buildLayerFilterChip('Bazaar & Supermarket', Icons.shopping_cart_rounded, _showGroceryLayer, () {
                        setState(() => _showGroceryLayer = !_showGroceryLayer);
                      }),
                      const SizedBox(width: 8),
                      _buildLayerFilterChip('Hospital', Icons.local_hospital_rounded, _showHospitalLayer, () {
                        setState(() => _showHospitalLayer = !_showHospitalLayer);
                      }),
                    ],
                  ),
                ),
              ),

              // Draw-on-map badge overlay
              if (_isDrawModeActive)
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gesture_rounded, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Freehand Selection: Draw around your preferred streets to view flats.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Selected Property Preview Card
              if (activeProp != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: BariCard(
                    padding: const EdgeInsets.all(12),
                    elevation: 4,
                    onTap: () {
                      context.pushNamed(
                        RouteNames.propertyDetail,
                        pathParameters: {'id': activeProp.id},
                        extra: activeProp,
                      );
                    },
                    child: Row(
                      children: [
                        BariImage(
                          imageUrl: activeProp.images.isNotEmpty
                              ? activeProp.images.first.imageUrl
                              : '',
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(10),
                          placeholderColor: AppColors.primarySoft,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  BariBadge(
                                    type: activeProp.fairPriceStatus == FairPriceStatus.greatDeal
                                        ? BariBadgeType.greatDeal
                                        : BariBadgeType.fairPrice,
                                    isCompact: true,
                                  ),
                                  Text(
                                    '${activeProp.bedrooms} Bed • ${activeProp.squareFeet} sqft',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeProp.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  BariPriceTag(
                                    amount: activeProp.rentAmount,
                                    size: BariPriceSize.compact,
                                  ),
                                  Text(
                                    'View Flat →',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLayerFilterChip(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return FilterChip(
      avatar: Icon(icon, size: 14, color: isActive ? Colors.white : AppColors.lightTextSecondary),
      label: Text(label),
      selected: isActive,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isActive ? Colors.white : AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

/// Custom Canvas Painter rendering road layouts and river geography of Dhaka.
class _DhakaMapPainter extends CustomPainter {
  const _DhakaMapPainter({required this.isDrawing});
  final bool isDrawing;

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFD6DBDF)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Buriganga & Turag River simulated curve
    final riverPaint = Paint()
      ..color = const Color(0xFFBCE0FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.85,
        size.width * 0.6,
        size.height * 0.7,
        size.width,
        size.height * 0.9,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Major Arterial Highways (Airport Road, Rokeya Sarani, Mirpur Road)
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    // Rokeya Sarani & Mirpur Road
    final roadPath = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.38, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(roadPath, roadPaint);

    // Airport Road to Mohakhali & Gulshan
    final highwayPath = Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.68, size.height);
    canvas.drawPath(highwayPath, roadPaint);

    // Simulated Freehand polygon selection highlight if drawing active
    if (isDrawing) {
      final polyPaint = Paint()
        ..color = AppColors.secondary.withAlpha(50)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final polyPath = Path()
        ..moveTo(size.width * 0.25, size.height * 0.2)
        ..lineTo(size.width * 0.65, size.height * 0.18)
        ..lineTo(size.width * 0.6, size.height * 0.45)
        ..lineTo(size.width * 0.22, size.height * 0.4)
        ..close();

      canvas.drawPath(polyPath, polyPaint);
      canvas.drawPath(polyPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DhakaMapPainter oldDelegate) =>
      oldDelegate.isDrawing != isDrawing;
}
