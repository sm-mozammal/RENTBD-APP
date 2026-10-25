import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';

/// Office / University Commute Calculator.
/// Calculates peak-hour travel time, traffic delays, and transit modes across Dhaka.
class CommuteCalculatorScreen extends StatefulWidget {
  const CommuteCalculatorScreen({super.key});

  @override
  State<CommuteCalculatorScreen> createState() => _CommuteCalculatorScreenState();
}

class _CommuteCalculatorScreenState extends State<CommuteCalculatorScreen> {
  String _origin = 'Mirpur 10 Metro Gate 2';
  String _destination = 'Kawran Bazar Media & Office Hub';

  final List<String> _origins = [
    'Mirpur 10 Metro Gate 2',
    'Uttara Sector 4',
    'Dhanmondi 27',
    'Bashundhara R/A Block C',
    'Mohammadpur Tajmahal Road',
  ];

  final List<String> _destinations = [
    'Kawran Bazar Media & Office Hub',
    'Motijheel Commercial Area',
    'Gulshan 1 Circle',
    'Mohakhali Wireless / TB Gate',
    'DU / BUET Nilkhet Campus',
    'NSU / IUB Bashundhara Campus',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commute Time Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Commute Input Card
            BariCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Commute Route',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  // Origin
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _origin,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Residence (Starting Flat)',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _origins
                              .map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _origin = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Destination
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _destination,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Office / University Destination',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _destinations
                              .map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _destination = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Transit Modes & Peak-Hour Traffic',
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // MRT Metro Line 6 option
            _buildTransitCard(
              mode: 'Dhaka Metro Rail (MRT Line 6)',
              icon: Icons.train_rounded,
              color: AppColors.primary,
              duration: '16 Mins',
              trafficDelay: '0 min traffic delay (Guaranteed)',
              costEstimate: '৳ 35 / trip',
              isFastest: true,
            ),
            const SizedBox(height: 12),

            // Bus / Public Transport option
            _buildTransitCard(
              mode: 'City Bus (Bikolpo / Al-Makkah)',
              icon: Icons.directions_bus_rounded,
              color: AppColors.secondary,
              duration: '55 - 75 Mins',
              trafficDelay: '+30 min peak traffic jam at Bijoy Sarani',
              costEstimate: '৳ 25 / trip',
            ),
            const SizedBox(height: 12),

            // Ride Sharing / Private Car
            _buildTransitCard(
              mode: 'Car / Uber / CNG Auto-rickshaw',
              icon: Icons.directions_car_rounded,
              color: AppColors.info,
              duration: '42 - 60 Mins',
              trafficDelay: '+22 min delay during 8:30 AM - 10:00 AM',
              costEstimate: '৳ 280 / trip',
            ),
            const SizedBox(height: 24),

            // Pro-tip card
            BariCard(
              backgroundColor: AppColors.primarySoft,
              borderColor: AppColors.primary.withAlpha(50),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Living near Mirpur 10 Metro saves you approximately 48 hours of Dhaka road gridlock and ৳ 6,500 every month!',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitCard({
    required String mode,
    required IconData icon,
    required Color color,
    required String duration,
    required String trafficDelay,
    required String costEstimate,
    bool isFastest = false,
  }) {
    return BariCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    mode,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (isFastest)
                const BariBadge(
                  type: BariBadgeType.custom,
                  customLabel: 'Fastest ⚡',
                  customColor: AppColors.primary,
                  customBgColor: AppColors.primarySoft,
                  isCompact: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration,
                    style: AppTypography.headlineLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    trafficDelay,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
              Text(
                costEstimate,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
