import 'package:equatable/equatable.dart';
import 'property.dart';

/// Filter query parameters for search and feeds.
class PropertyFilter extends Equatable {
  const PropertyFilter({
    this.area,
    this.tenantCategory,
    this.propertyType,
    this.minRent,
    this.maxRent,
    this.bedrooms,
    this.hasGeoTaggedOnly = false,
    this.isGreatDealOnly = false,
    this.searchQuery,
  });

  final String? area;
  final TenantCategory? tenantCategory;
  final PropertyType? propertyType;
  final double? minRent;
  final double? maxRent;
  final int? bedrooms;
  final bool hasGeoTaggedOnly;
  final bool isGreatDealOnly;
  final String? searchQuery;

  PropertyFilter copyWith({
    String? area,
    TenantCategory? tenantCategory,
    PropertyType? propertyType,
    double? minRent,
    double? maxRent,
    int? bedrooms,
    bool? hasGeoTaggedOnly,
    bool? isGreatDealOnly,
    String? searchQuery,
    bool clearArea = false,
    bool clearCategory = false,
  }) {
    return PropertyFilter(
      area: clearArea ? null : (area ?? this.area),
      tenantCategory: clearCategory ? null : (tenantCategory ?? this.tenantCategory),
      propertyType: propertyType ?? this.propertyType,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      bedrooms: bedrooms ?? this.bedrooms,
      hasGeoTaggedOnly: hasGeoTaggedOnly ?? this.hasGeoTaggedOnly,
      isGreatDealOnly: isGreatDealOnly ?? this.isGreatDealOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        area,
        tenantCategory,
        propertyType,
        minRent,
        maxRent,
        bedrooms,
        hasGeoTaggedOnly,
        isGreatDealOnly,
        searchQuery,
      ];
}
