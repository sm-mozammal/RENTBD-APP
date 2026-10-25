import '../../domain/entities/property_operations.dart';
import 'property_model.dart';

class MoveInEstimateModel {
  const MoveInEstimateModel({
    required this.firstMonthRent,
    required this.securityDeposit,
    required this.serviceCharge,
    required this.movingTruckCost,
    required this.labourCost,
    required this.totalEstimatedCashNeeded,
    this.currency = 'BDT',
    this.breakdownNotes = '',
  });

  factory MoveInEstimateModel.fromJson(Map<String, dynamic> json) {
    return MoveInEstimateModel(
      firstMonthRent: (json['first_month_rent'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (json['service_charge'] as num?)?.toDouble() ?? 0.0,
      movingTruckCost: (json['moving_truck_cost'] as num?)?.toDouble() ?? 0.0,
      labourCost: (json['labour_cost'] as num?)?.toDouble() ?? 0.0,
      totalEstimatedCashNeeded:
          (json['total_estimated_cash_needed'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BDT',
      breakdownNotes: json['breakdown_notes'] as String? ?? '',
    );
  }

  final double firstMonthRent;
  final double securityDeposit;
  final double serviceCharge;
  final double movingTruckCost;
  final double labourCost;
  final double totalEstimatedCashNeeded;
  final String currency;
  final String breakdownNotes;

  Map<String, dynamic> toJson() => {
        'first_month_rent': firstMonthRent,
        'security_deposit': securityDeposit,
        'service_charge': serviceCharge,
        'moving_truck_cost': movingTruckCost,
        'labour_cost': labourCost,
        'total_estimated_cash_needed': totalEstimatedCashNeeded,
        'currency': currency,
        'breakdown_notes': breakdownNotes,
      };

  MoveInEstimate toEntity() => MoveInEstimate(
        firstMonthRent: firstMonthRent,
        securityDeposit: securityDeposit,
        serviceCharge: serviceCharge,
        movingTruckCost: movingTruckCost,
        labourCost: labourCost,
        totalEstimatedCashNeeded: totalEstimatedCashNeeded,
        currency: currency,
        breakdownNotes: breakdownNotes,
      );
}

class PropertyComparisonModel {
  const PropertyComparisonModel({
    required this.properties,
    required this.rentDifference,
    required this.cheaperPropertyId,
    this.gasComparison = const {},
    this.generatorComparison = const {},
  });

  factory PropertyComparisonModel.fromJson(Map<String, dynamic> json) {
    final rawProps = json['properties'] as List<dynamic>? ?? [];
    final matrix = json['comparison_matrix'] as Map<String, dynamic>? ?? {};

    return PropertyComparisonModel(
      properties: rawProps
          .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      rentDifference: (matrix['rent_difference'] as num?)?.toDouble() ?? 0.0,
      cheaperPropertyId: matrix['cheaper_property_id'] as String? ?? '',
      gasComparison: matrix['gas_comparison'] as Map<String, dynamic>? ?? {},
      generatorComparison:
          matrix['generator_comparison'] as Map<String, dynamic>? ?? {},
    );
  }

  final List<PropertyModel> properties;
  final double rentDifference;
  final String cheaperPropertyId;
  final Map<String, dynamic> gasComparison;
  final Map<String, dynamic> generatorComparison;

  PropertyComparison toEntity() => PropertyComparison(
        properties: properties.map((p) => p.toEntity()).toList(),
        rentDifference: rentDifference,
        cheaperPropertyId: cheaperPropertyId,
        gasComparison: gasComparison,
        generatorComparison: generatorComparison,
      );
}

class CommuteEstimateModel {
  const CommuteEstimateModel({
    required this.commuteTimeMinutes,
    required this.mode,
    required this.nearestStation,
    required this.stationDistanceMeters,
    required this.trafficDelayPeakHoursMinutes,
  });

  factory CommuteEstimateModel.fromJson(Map<String, dynamic> json) {
    return CommuteEstimateModel(
      commuteTimeMinutes: json['commute_time_minutes'] as int? ?? 0,
      mode: json['mode'] as String? ?? 'metro',
      nearestStation: json['nearest_station'] as String? ?? '',
      stationDistanceMeters: json['station_distance_meters'] as int? ?? 0,
      trafficDelayPeakHoursMinutes:
          json['traffic_delay_peak_hours_minutes'] as int? ?? 0,
    );
  }

  final int commuteTimeMinutes;
  final String mode;
  final String nearestStation;
  final int stationDistanceMeters;
  final int trafficDelayPeakHoursMinutes;

  CommuteEstimate toEntity() => CommuteEstimate(
        commuteTimeMinutes: commuteTimeMinutes,
        mode: mode,
        nearestStation: nearestStation,
        stationDistanceMeters: stationDistanceMeters,
        trafficDelayPeakHoursMinutes: trafficDelayPeakHoursMinutes,
      );
}

class NearbyEssentialsModel {
  const NearbyEssentialsModel({
    this.metroStations = const [],
    this.busStops = const [],
    this.mosques = const [],
    this.bazaars = const [],
    this.hospitals = const [],
    this.pharmacies = const [],
  });

  factory NearbyEssentialsModel.fromJson(Map<String, dynamic> json) {
    List<NearbyPlace> parsePlaces(dynamic list) {
      if (list is! List) return [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return NearbyPlace(
          name: map['name'] as String? ?? '',
          distanceMeters: map['distance_meters'] as int? ?? 0,
        );
      }).toList();
    }

    return NearbyEssentialsModel(
      metroStations: parsePlaces(json['metro_stations']),
      busStops: parsePlaces(json['bus_stops']),
      mosques: parsePlaces(json['mosques']),
      bazaars: parsePlaces(json['bazaars']),
      hospitals: parsePlaces(json['hospitals']),
      pharmacies: parsePlaces(json['pharmacies']),
    );
  }

  final List<NearbyPlace> metroStations;
  final List<NearbyPlace> busStops;
  final List<NearbyPlace> mosques;
  final List<NearbyPlace> bazaars;
  final List<NearbyPlace> hospitals;
  final List<NearbyPlace> pharmacies;

  NearbyEssentials toEntity() => NearbyEssentials(
        metroStations: metroStations,
        busStops: busStops,
        mosques: mosques,
        bazaars: bazaars,
        hospitals: hospitals,
        pharmacies: pharmacies,
      );
}

class RentAgreementModel {
  const RentAgreementModel({
    required this.agreementTitle,
    required this.fullLegalMarkdown,
    this.generatedAt,
    this.success = true,
  });

  factory RentAgreementModel.fromJson(Map<String, dynamic> json) {
    return RentAgreementModel(
      success: json['success'] as bool? ?? true,
      agreementTitle: json['agreement_title'] as String? ??
          'Residential Tenancy Agreement (বাড়ি ভাড়া চুক্তিপত্র)',
      fullLegalMarkdown: json['full_legal_markdown'] as String? ?? '',
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String)
          : null,
    );
  }

  final bool success;
  final String agreementTitle;
  final String fullLegalMarkdown;
  final DateTime? generatedAt;

  RentAgreementResult toEntity() => RentAgreementResult(
        agreementTitle: agreementTitle,
        fullLegalMarkdown: fullLegalMarkdown,
        generatedAt: generatedAt,
        success: success,
      );
}

class FairRentAnalysisModel {
  const FairRentAnalysisModel({
    required this.propertyId,
    required this.currentRent,
    required this.areaAverageRent,
    required this.verdict,
    required this.percentageDifference,
    required this.ratingScore,
    required this.insight,
  });

  factory FairRentAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FairRentAnalysisModel(
      propertyId: json['property_id'] as String? ?? '',
      currentRent: (json['current_rent'] as num?)?.toDouble() ?? 0.0,
      areaAverageRent: (json['area_average_rent'] as num?)?.toDouble() ?? 0.0,
      verdict: json['verdict'] as String? ?? 'Fair Price',
      percentageDifference:
          (json['percentage_difference'] as num?)?.toDouble() ?? 0.0,
      ratingScore: (json['rating_score'] as num?)?.toDouble() ?? 4.0,
      insight: json['insight'] as String? ?? '',
    );
  }

  final String propertyId;
  final double currentRent;
  final double areaAverageRent;
  final String verdict;
  final double percentageDifference;
  final double ratingScore;
  final String insight;

  FairRentAnalysis toEntity() => FairRentAnalysis(
        propertyId: propertyId,
        currentRent: currentRent,
        areaAverageRent: areaAverageRent,
        verdict: verdict,
        percentageDifference: percentageDifference,
        ratingScore: ratingScore,
        insight: insight,
      );
}

class AreaHeatmapItemModel {
  const AreaHeatmapItemModel({
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.searchDemandIndex,
    required this.activeListingsCount,
    required this.pressureRatio,
    required this.marketState,
  });

  factory AreaHeatmapItemModel.fromJson(Map<String, dynamic> json) {
    return AreaHeatmapItemModel(
      area: json['area'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 90.4125,
      searchDemandIndex: json['search_demand_index'] as int? ?? 50,
      activeListingsCount: json['active_listings_count'] as int? ?? 0,
      pressureRatio: (json['pressure_ratio'] as num?)?.toDouble() ?? 1.0,
      marketState: json['market_state'] as String? ?? 'Balanced',
    );
  }

  final String area;
  final double latitude;
  final double longitude;
  final int searchDemandIndex;
  final int activeListingsCount;
  final double pressureRatio;
  final String marketState;

  AreaHeatmapItem toEntity() => AreaHeatmapItem(
        area: area,
        latitude: latitude,
        longitude: longitude,
        searchDemandIndex: searchDemandIndex,
        activeListingsCount: activeListingsCount,
        pressureRatio: pressureRatio,
        marketState: marketState,
      );
}
