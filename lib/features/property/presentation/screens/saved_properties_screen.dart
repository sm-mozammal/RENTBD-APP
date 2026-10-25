import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';
import '../widgets/property_card.dart';

/// Screen for Wishlisted Properties and Saved Search Instant Alerts.
class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({super.key});

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  final List<String> _activeAlerts = [
    'Uttara Sector 4 • Under ৳ 30,000 • Family',
    'Mirpur 10 • Under ৳ 17,000 • Bachelor',
  ];

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const LoadSavedPropertiesEvent());
  }

  void _showAddAlertDialog() {
    final areaController = TextEditingController(text: 'Dhanmondi');
    final budgetController = TextEditingController(text: '20000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Instant Rental Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get real-time push notifications the moment a matching verified property goes live.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 16),
            BariTextField(controller: areaController, label: 'Neighborhood / Area', hintText: 'e.g. Mirpur, Uttara'),
            const SizedBox(height: 12),
            BariTextField(
              controller: budgetController,
              label: 'Max Budget (BDT ৳)',
              hintText: 'e.g. 15000',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          BariButton(
            label: 'Activate Alert',
            isFullWidth: false,
            height: 42,
            onPressed: () {
              final newAlert = '${areaController.text} • Under ৳ ${budgetController.text}';
              setState(() => _activeAlerts.add(newAlert));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Instant alert created for $newAlert'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & Instant Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded),
            tooltip: 'Add Alert',
            onPressed: _showAddAlertDialog,
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is! PropertyLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedList = state.savedProperties;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Instant Alerts Section
                BariCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.primarySoft,
                  borderColor: AppColors.primary.withAlpha(50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Instant Search Alerts',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _showAddAlertDialog,
                            child: const Text('+ New Alert'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._activeAlerts.map(
                        (alert) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withAlpha(40)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  alert,
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Saved Properties (${savedList.length})',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                if (savedList.isEmpty)
                  BariEmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No saved properties yet',
                    message: 'Tap the heart icon on any flat listing to save and compare later.',
                    actionLabel: 'Explore Dhaka Flats',
                    onAction: () => context.goNamed(RouteNames.home),
                  )
                else
                  ...savedList.map(
                    (property) => PropertyCard(
                      property: property,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.propertyDetail,
                          pathParameters: {'id': property.id},
                          extra: property,
                        );
                      },
                      onToggleSave: () {
                        context.read<PropertyBloc>().add(ToggleSaveEvent(property.id));
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
