import 'package:equatable/equatable.dart';
import '../../../../core/widgets/bari_segmented_switch.dart';
import '../../domain/entities/property_filter.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class FetchPropertiesEvent extends PropertyEvent {
  const FetchPropertiesEvent({this.isRefresh = false});
  final bool isRefresh;

  @override
  List<Object?> get props => [isRefresh];
}

class FilterCategoryChangedEvent extends PropertyEvent {
  const FilterCategoryChangedEvent(this.category);
  final TenantCategoryFilter category;

  @override
  List<Object?> get props => [category];
}

class AreaFilterChangedEvent extends PropertyEvent {
  const AreaFilterChangedEvent(this.area);
  final String area;

  @override
  List<Object?> get props => [area];
}

class SearchQueryChangedEvent extends PropertyEvent {
  const SearchQueryChangedEvent(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class VoiceNaturalSearchEvent extends PropertyEvent {
  const VoiceNaturalSearchEvent(this.naturalQuery);
  final String naturalQuery;

  @override
  List<Object?> get props => [naturalQuery];
}

class ToggleSaveEvent extends PropertyEvent {
  const ToggleSaveEvent(this.propertyId);
  final String propertyId;

  @override
  List<Object?> get props => [propertyId];
}

class LoadSavedPropertiesEvent extends PropertyEvent {
  const LoadSavedPropertiesEvent();
}

class ApplyCustomFilterEvent extends PropertyEvent {
  const ApplyCustomFilterEvent(this.filter);
  final PropertyFilter filter;

  @override
  List<Object?> get props => [filter];
}
