import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_state.dart';

/// Interactive Move-in Cost Estimator Screen.
class MoveInCalculatorScreen extends StatefulWidget {
  const MoveInCalculatorScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<MoveInCalculatorScreen> createState() => _MoveInCalculatorScreenState();
}

class _MoveInCalculatorScreenState extends State<MoveInCalculatorScreen> {
  int _advanceMonths = 2;
  double _serviceCharge = 3000;
  double _utilities = 2000;
  double _movingTruckCost = 3500;
  double _paintingCleaning = 1500;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        if (state is! PropertyLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final property = state.properties.firstWhere(
          (p) => p.id == widget.propertyId,
          orElse: () => state.properties.first,
        );

        final baseRent = property.rentAmount;
        final totalAdvance = baseRent * _advanceMonths;
        final totalUpfront = baseRent + totalAdvance + _serviceCharge + _utilities + _movingTruckCost + _paintingCleaning;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Move-in Cost Calculator'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Upfront Cash Required',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                        const SizedBox(height: 6),
                        BariPriceTag(
                          amount: totalUpfront,
                          showPeriod: false,
                          color: Colors.white,
                          size: BariPriceSize.hero,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Calculated for ${property.title}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withAlpha(200),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Customize Parameters',
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // Advance Deposit Months
                  BariCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Security Deposit (Advance)',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '$_advanceMonths Month${_advanceMonths > 1 ? "s" : ""}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _advanceMonths.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _advanceMonths = val.toInt()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 Mo (৳ ${baseRent.toInt()})', style: AppTypography.labelSmall),
                            Text('2 Mo (৳ ${(baseRent * 2).toInt()})', style: AppTypography.labelSmall),
                            Text('3 Mo', style: AppTypography.labelSmall),
                            Text('4 Mo', style: AppTypography.labelSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Service charge slider
                  BariCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Building Service Charge',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '৳ ${_serviceCharge.toInt()}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _serviceCharge,
                          min: 1000,
                          max: 8000,
                          divisions: 14,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _serviceCharge = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Utilities slider
                  BariCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Utilities (WASA/Gas/Power)',
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '৳ ${_utilities.toInt()}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _utilities,
                          min: 1000,
                          max: 6000,
                          divisions: 10,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _utilities = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Moving Costs & Painting Touch-up
                  BariCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Moving Truck & Helpers',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '৳ ${_movingTruckCost.toInt()}',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Slider(
                          value: _movingTruckCost,
                          min: 1500,
                          max: 8000,
                          divisions: 13,
                          activeColor: AppColors.secondary,
                          onChanged: (val) => setState(() => _movingTruckCost = val),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Initial Cleaning & Minor Touchups',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '৳ ${_paintingCleaning.toInt()}',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Slider(
                          value: _paintingCleaning,
                          min: 500,
                          max: 5000,
                          divisions: 9,
                          activeColor: AppColors.secondary,
                          onChanged: (val) => setState(() => _paintingCleaning = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  BariButton(
                    label: 'Save Breakdown & Schedule Visit',
                    leadingIcon: const Icon(Icons.bookmark_add_rounded, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cost estimate saved to your rental plan!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      context.pushNamed(RouteNames.visits);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
