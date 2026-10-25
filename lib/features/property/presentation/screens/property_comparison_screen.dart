import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_state.dart';

/// Side-by-side comparison matrix for 2 to 3 shortlisted properties.
class PropertyComparisonScreen extends StatefulWidget {
  const PropertyComparisonScreen({super.key});

  @override
  State<PropertyComparisonScreen> createState() => _PropertyComparisonScreenState();
}

class _PropertyComparisonScreenState extends State<PropertyComparisonScreen> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Comparison Matrix'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is! PropertyLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final allProperties = state.properties;
          if (_selectedIds.isEmpty && allProperties.length >= 2) {
            _selectedIds.add(allProperties[0].id);
            _selectedIds.add(allProperties[1].id);
          }

          final comparedList = allProperties.where((p) => _selectedIds.contains(p.id)).toList();

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection chip bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select 2 or 3 properties to compare:',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allProperties.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final p = allProperties[index];
                            final isSelected = _selectedIds.contains(p.id);
                            return FilterChip(
                              label: Text('${p.areaNeighborhood} (৳ ${p.rentAmount.toInt()})'),
                              selected: isSelected,
                              selectedColor: AppColors.primarySoft,
                              checkmarkColor: AppColors.primary,
                              labelStyle: AppTypography.labelSmall.copyWith(
                                color: isSelected ? AppColors.primaryDark : AppColors.lightTextPrimary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    if (_selectedIds.length < 3) {
                                      _selectedIds.add(p.id);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('You can compare up to 3 properties at a time.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (_selectedIds.length > 1) {
                                      _selectedIds.remove(p.id);
                                    }
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Comparison Matrix Table
                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row (Images & Titles)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetricLabelColumn('Property'),
                              ...comparedList.map((p) => _buildPropertyHeaderCol(p)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),

                          // Rent
                          _buildComparisonRow(
                            'Monthly Rent',
                            comparedList.map((p) => '৳ ${p.rentAmount.toInt()}/mo').toList(),
                            highlightIndex: 0,
                          ),

                          // Advance Deposit
                          _buildComparisonRow(
                            'Advance Deposit',
                            comparedList.map((p) => '৳ ${p.securityDeposit.toInt()}').toList(),
                          ),

                          // Area & Floor
                          _buildComparisonRow(
                            'Square Footage',
                            comparedList.map((p) => '${p.squareFeet} SqFt').toList(),
                          ),

                          // Bed & Bath
                          _buildComparisonRow(
                            'Bedrooms / Baths',
                            comparedList.map((p) => '${p.bedrooms} Beds / ${p.bathrooms} Baths').toList(),
                          ),

                          // Floor Level
                          _buildComparisonRow(
                            'Floor Level',
                            comparedList.map((p) => 'Level ${p.floorLevel} of ${p.totalFloors}').toList(),
                          ),

                          // Service Charge
                          _buildComparisonRow(
                            'Service Charge',
                            comparedList.map((p) => '৳ ${p.serviceCharge.toInt()}').toList(),
                          ),

                          // AI Fair Rent Rating
                          _buildComparisonRow(
                            'AI Price Meter',
                            comparedList.map((p) {
                              if (p.fairPriceStatus == FairPriceStatus.greatDeal) return 'Great Deal ⭐';
                              if (p.fairPriceStatus == FairPriceStatus.fairPrice) return 'Fair Market';
                              return 'Above Avg';
                            }).toList(),
                          ),

                          // Road / Alley Width
                          _buildComparisonRow(
                            'Front Road Width',
                            comparedList.map((p) => '${p.alleyWidthFeet.toInt()} ft (Truck accessible)').toList(),
                          ),

                          // Gas Supply
                          _buildComparisonRow(
                            'Gas Connection',
                            comparedList.map((p) => p.gasSupply == GasSupplyType.lineGas ? 'Line Gas' : 'Cylinder').toList(),
                          ),

                          // Waterlogging Risk
                          _buildComparisonRow(
                            'Monsoon Waterlogging',
                            comparedList.map((p) => p.waterloggingRisk == WaterloggingRisk.none ? 'Zero Risk' : 'Mild Risk').toList(),
                          ),

                          // Night Safety
                          _buildComparisonRow(
                            'Night Safety Rating',
                            comparedList.map((p) => '${p.nightSafetyRating} / 5.0').toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricLabelColumn(String title) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildPropertyHeaderCol(Property p) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BariImage(
            imageUrl: p.images.isNotEmpty ? p.images.first.imageUrl : '',
            width: 170,
            height: 100,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10),
            placeholderColor: AppColors.primarySoft,
          ),
          const SizedBox(height: 6),
          Text(
            p.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            p.areaNeighborhood,
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values, {int? highlightIndex}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lightDivider, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...values.map(
            (val) => Container(
              width: 170,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                val,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
