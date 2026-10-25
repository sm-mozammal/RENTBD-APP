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

/// Primary Discovery & Explore Home Screen for RentBD.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final List<String> _dhakaAreas = [
    'All Dhaka',
    'Mirpur 10',
    'Uttara Sector 4',
    'Gulshan 2',
    'Dhanmondi 27',
    'Bashundhara R/A',
    'Mohammadpur',
  ];

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const FetchPropertiesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNaturalSearchDialog() {
    final naturalController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Voice & Natural Language Search',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Supports English, Bangla & Banglish text/voice',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BariTextField(
                controller: naturalController,
                hintText: 'e.g. 2-bed flat near Mirpur 10 Metro within 16000 BDT',
                autofocus: true,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildPromptChip(
                    'Mirpur 10 Bachelor under 17k',
                    () => naturalController.text = 'Mirpur 10 Bachelor under 17000 BDT with balcony',
                  ),
                  _buildPromptChip(
                    'Uttara Family flat 3 bed',
                    () => naturalController.text = '3-bedroom flat in Uttara for family with line gas',
                  ),
                  _buildPromptChip(
                    'Dhanmondi female sublet',
                    () => naturalController.text = 'Dhanmondi sublet for female student',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BariButton(
                label: 'Search with AI',
                onPressed: () {
                  final query = naturalController.text.trim();
                  if (query.isNotEmpty) {
                    context.read<PropertyBloc>().add(VoiceNaturalSearchEvent(query));
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromptChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: BlocBuilder<PropertyBloc, PropertyState>(
          builder: (context, state) {
            final activeArea = state is PropertyLoaded ? state.activeArea : 'All Dhaka';
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dhakaAreas.contains(activeArea) ? activeArea : 'All Dhaka',
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
                items: _dhakaAreas.map((area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(area),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newArea) {
                  if (newArea != null) {
                    context.read<PropertyBloc>().add(AreaFilterChangedEvent(newArea));
                  }
                },
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Interactive Map Search',
            onPressed: () => context.pushNamed(RouteNames.mapSearch),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Alerts',
            onPressed: () => context.pushNamed(RouteNames.saved),
          ),
        ],
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          final activeCategory = state is PropertyLoaded
              ? state.activeCategory
              : TenantCategoryFilter.all;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PropertyBloc>().add(const FetchPropertiesEvent(isRefresh: true));
            },
            child: CustomScrollView(
              slivers: [
                // Search and Filters Sticky Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar with Natural Voice prompt button
                        Row(
                          children: [
                            Expanded(
                              child: BariTextField(
                                controller: _searchController,
                                hintText: 'Search by road, metro, area...',
                                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.lightTextMuted),
                                onChanged: (q) {
                                  context.read<PropertyBloc>().add(SearchQueryChangedEvent(q));
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Voice / AI button
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withAlpha(50)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.mic_rounded, color: AppColors.primary),
                                tooltip: 'AI Natural Language Search',
                                onPressed: _showNaturalSearchDialog,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dedicated 1-Tap Bachelor / Family / Sublet Switch
                        BariSegmentedSwitch(
                          selected: activeCategory,
                          onChanged: (cat) {
                            context.read<PropertyBloc>().add(FilterCategoryChangedEvent(cat));
                          },
                        ),
                        const SizedBox(height: 14),

                        // Natural search banner if active
                        if (state is PropertyLoaded && state.isNaturalSearchActive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'AI Filter: "${state.naturalSearchPrompt}"',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.read<PropertyBloc>().add(const FetchPropertiesEvent());
                                  },
                                  child: const Icon(Icons.close, size: 16, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Listing counter & comparison shortcut
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state is PropertyLoaded
                                  ? '${state.properties.length} Verified Properties'
                                  : 'Loading verified properties...',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                              label: const Text('Compare'),
                              onPressed: () => context.pushNamed(RouteNames.compare),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Feed List
                if (state is PropertyLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              BariShimmer(width: double.infinity, height: 180, borderRadius: 16),
                              SizedBox(height: 10),
                              BariShimmer(width: 220, height: 20),
                              SizedBox(height: 6),
                              BariShimmer(width: 140, height: 14),
                            ],
                          ),
                        ),
                        childCount: 3,
                      ),
                    ),
                  )
                else if (state is PropertyError)
                  SliverFillRemaining(
                    child: BariErrorState(
                      message: state.message,
                      onRetry: () => context.read<PropertyBloc>().add(const FetchPropertiesEvent()),
                    ),
                  )
                else if (state is PropertyLoaded) ...[
                  if (state.properties.isEmpty)
                    SliverFillRemaining(
                      child: BariEmptyState(
                        title: 'No properties found',
                        message: 'No available rentals match your selected filter in ${state.activeArea}.',
                        actionLabel: 'Reset Filters',
                        onAction: () {
                          _searchController.clear();
                          context.read<PropertyBloc>().add(const AreaFilterChangedEvent('All Dhaka'));
                          context.read<PropertyBloc>().add(const FilterCategoryChangedEvent(TenantCategoryFilter.all));
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = state.properties[index];
                            return PropertyCard(
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
                            );
                          },
                          childCount: state.properties.length,
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
}
