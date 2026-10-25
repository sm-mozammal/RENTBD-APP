import 'package:equatable/equatable.dart';
import '../../../../core/widgets/bari_segmented_switch.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/property_filter.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {
  const PropertyInitial();
}

class PropertyLoading extends PropertyState {
  const PropertyLoading();
}

class PropertyLoaded extends PropertyState {
  const PropertyLoaded({
    required this.properties,
    this.savedProperties = const [],
    this.activeCategory = TenantCategoryFilter.all,
    this.activeArea = 'All Dhaka',
    this.filter = const PropertyFilter(),
    this.isNaturalSearchActive = false,
    this.naturalSearchPrompt,
  });

  final List<Property> properties;
  final List<Property> savedProperties;
  final TenantCategoryFilter activeCategory;
  final String activeArea;
  final PropertyFilter filter;
  final bool isNaturalSearchActive;
  final String? naturalSearchPrompt;

  PropertyLoaded copyWith({
    List<Property>? properties,
    List<Property>? savedProperties,
    TenantCategoryFilter? activeCategory,
    String? activeArea,
    PropertyFilter? filter,
    bool? isNaturalSearchActive,
    String? naturalSearchPrompt,
  }) {
    return PropertyLoaded(
      properties: properties ?? this.properties,
      savedProperties: savedProperties ?? this.savedProperties,
      activeCategory: activeCategory ?? this.activeCategory,
      activeArea: activeArea ?? this.activeArea,
      filter: filter ?? this.filter,
      isNaturalSearchActive: isNaturalSearchActive ?? this.isNaturalSearchActive,
      naturalSearchPrompt: naturalSearchPrompt ?? this.naturalSearchPrompt,
    );
  }

  @override
  List<Object?> get props => [
        properties,
        savedProperties,
        activeCategory,
        activeArea,
        filter,
        isNaturalSearchActive,
        naturalSearchPrompt,
      ];
}

class PropertyError extends PropertyState {
  const PropertyError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
