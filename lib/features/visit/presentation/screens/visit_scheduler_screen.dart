import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';

enum VisitType { inPerson, liveVideo }

class _BookedSlot {
  _BookedSlot({
    required this.id,
    required this.propertyTitle,
    required this.area,
    required this.date,
    required this.time,
    required this.type,
    required this.landlordName,
  });

  final String id;
  final String propertyTitle;
  final String area;
  final String date;
  final String time;
  final VisitType type;
  final String landlordName;
}

/// Visit Scheduler & Live Video Tour booking manager.
class VisitSchedulerScreen extends StatefulWidget {
  const VisitSchedulerScreen({super.key});

  @override
  State<VisitSchedulerScreen> createState() => _VisitSchedulerScreenState();
}

class _VisitSchedulerScreenState extends State<VisitSchedulerScreen> {
  VisitType _selectedType = VisitType.liveVideo;
  String _selectedDate = 'Tomorrow, Oct 21';
  String _selectedTimeSlot = '4:30 PM - 5:00 PM';

  final List<String> _dates = [
    'Today, Oct 20',
    'Tomorrow, Oct 21',
    'Thursday, Oct 22',
    'Friday, Oct 23',
    'Saturday, Oct 24',
  ];

  final List<String> _timeSlots = [
    '10:30 AM - 11:00 AM',
    '2:00 PM - 2:30 PM',
    '4:30 PM - 5:00 PM',
    '6:30 PM - 7:00 PM',
  ];

  final List<_BookedSlot> _myBookings = [
    _BookedSlot(
      id: 'b-01',
      propertyTitle: '2-Bed Modern Flat near Mirpur 10 Metro',
      area: 'Block C, Mirpur 10, Dhaka',
      date: 'Tomorrow, Oct 21',
      time: '4:30 PM - 5:00 PM',
      type: VisitType.liveVideo,
      landlordName: 'Engr. Farhan Kabir',
    ),
  ];

  void _onBookVisit() {
    setState(() {
      _myBookings.insert(
        0,
        _BookedSlot(
          id: 'b-${DateTime.now().millisecondsSinceEpoch}',
          propertyTitle: 'Spacious 3-Bed Family Apartment',
          area: 'Sector 4, Uttara, Dhaka',
          date: _selectedDate,
          time: _selectedTimeSlot,
          type: _selectedType,
          landlordName: 'Dr. Shahriar Rahman',
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedType == VisitType.liveVideo
              ? 'Live Video Tour requested! Landlord notified via push.'
              : 'In-person viewing appointment confirmed!',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit & Video Tour Scheduler'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Tour Type Selector
            BariCard(
              padding: const EdgeInsets.all(6),
              backgroundColor: AppColors.lightDivider,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeToggle(
                      type: VisitType.liveVideo,
                      title: 'Live Video Tour 📹',
                      subtitle: 'Remote walkthrough before physical visit',
                    ),
                  ),
                  Expanded(
                    child: _buildTypeToggle(
                      type: VisitType.inPerson,
                      title: 'In-Person Viewing 🚶',
                      subtitle: 'Physical inspection at building',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date selector
            Text(
              'Select Date',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final d = _dates[index];
                  final isSelected = _selectedDate == d;
                  return ChoiceChip(
                    label: Text(d),
                    selected: isSelected,
                    selectedColor: AppColors.primarySoft,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.primaryDark : AppColors.lightTextPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() => _selectedDate = d),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Time slot selector
            Text(
              'Select Time Slot',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: AppColors.primarySoft,
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.primaryDark : AppColors.lightTextPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            BariButton(
              label: _selectedType == VisitType.liveVideo
                  ? 'Request Live Video Tour Slot'
                  : 'Confirm In-Person Viewing Slot',
              leadingIcon: Icon(
                _selectedType == VisitType.liveVideo ? Icons.videocam_rounded : Icons.calendar_month_rounded,
                color: Colors.white,
              ),
              onPressed: _onBookVisit,
            ),
            const SizedBox(height: 32),

            // Booked tours history
            Text(
              'Upcoming Scheduled Visits',
              style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            if (_myBookings.isEmpty)
              const BariEmptyState(
                title: 'No visits scheduled',
                message: 'Book a video tour to preview flats without leaving home.',
              )
            else
              ..._myBookings.map((booking) {
                final isVideo = booking.type == VisitType.liveVideo;
                return BariCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BariBadge(
                            type: BariBadgeType.custom,
                            customLabel: isVideo ? 'Live Video Tour' : 'In-Person Visit',
                            customIcon: isVideo ? Icons.videocam : Icons.location_on,
                            customColor: isVideo ? AppColors.bachelor : AppColors.primary,
                            customBgColor: isVideo ? AppColors.bachelorSoft : AppColors.primarySoft,
                            isCompact: true,
                          ),
                          Text(
                            'Confirmed ✓',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.propertyTitle,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        booking.area,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.date} • ${booking.time}',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (isVideo) ...[
                        const SizedBox(height: 12),
                        BariButton(
                          label: 'Join Video Room (Demo)',
                          height: 38,
                          leadingIcon: const Icon(Icons.videocam_rounded, size: 16, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening encrypted live video stream with landlord...'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required VisitType type,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.lightTextSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
