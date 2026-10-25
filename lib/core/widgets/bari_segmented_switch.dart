import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum TenantCategoryFilter { all, family, bachelor, sublet }

/// 1-Tap Dedicated Segmented Switch for Bachelor / Family / Sublet filter.
/// Featured prominently on the home screen and search filters.
class BariSegmentedSwitch extends StatelessWidget {
  const BariSegmentedSwitch({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TenantCategoryFilter selected;
  final ValueChanged<TenantCategoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightDivider,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 0.8),
      ),
      child: Row(
        children: [
          _buildItem(
            category: TenantCategoryFilter.all,
            title: 'All',
            icon: Icons.grid_view_rounded,
          ),
          _buildItem(
            category: TenantCategoryFilter.family,
            title: 'Family',
            icon: Icons.people_alt_rounded,
            activeColor: AppColors.family,
          ),
          _buildItem(
            category: TenantCategoryFilter.bachelor,
            title: 'Bachelor',
            icon: Icons.person_rounded,
            activeColor: AppColors.bachelor,
          ),
          _buildItem(
            category: TenantCategoryFilter.sublet,
            title: 'Sublet',
            icon: Icons.meeting_room_rounded,
            activeColor: AppColors.sublet,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required TenantCategoryFilter category,
    required String title,
    required IconData icon,
    Color activeColor = AppColors.primary,
  }) {
    final isSelected = selected == category;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? activeColor : AppColors.lightTextMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? activeColor : AppColors.lightTextSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
