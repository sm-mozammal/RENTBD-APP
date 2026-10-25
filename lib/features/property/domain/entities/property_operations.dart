import 'package:equatable/equatable.dart';
import 'property.dart';

/// Upfront cash estimation for moving into a property.
class MoveInEstimate extends Equatable {
  const MoveInEstimate({
    required this.firstMonthRent,
    required this.securityDeposit,
    required this.serviceCharge,
    required this.movingTruckCost,
    required this.labourCost,
    required this.totalEstimatedCashNeeded,
    this.currency = 'BDT',
    this.breakdownNotes = '',
  });

  final double firstMonthRent;
  final double securityDeposit;
  final double serviceCharge;
  final double movingTruckCost;
  final double labourCost;
  final double totalEstimatedCashNeeded;
  final String currency;
  final String breakdownNotes;

  @override
  List<Object?> get props => [
        firstMonthRent,
        securityDeposit,
        serviceCharge,
        movingTruckCost,
        labourCost,
        totalEstimatedCashNeeded,
        currency,
        breakdownNotes,
      ];
}

/// Comparison result comparing 2-3 properties side-by-side.
class PropertyComparison extends Equatable {
  const PropertyComparison({
    required this.properties,
    required this.rentDifference,
    required this.cheaperPropertyId,
    this.gasComparison = const {},
    this.generatorComparison = const {},
  });

  final List<Property> properties;
  final double rentDifference;
  final String cheaperPropertyId;
  final Map<String, dynamic> gasComparison;
  final Map<String, dynamic> generatorComparison;

  @override
  List<Object?> get props => [
        properties,
        rentDifference,
        cheaperPropertyId,
        gasComparison,
        generatorComparison,
      ];
}

/// Commute calculation result for transit to commercial hubs.
class CommuteEstimate extends Equatable {
  const CommuteEstimate({
    required this.commuteTimeMinutes,
    required this.mode,
    required this.nearestStation,
    required this.stationDistanceMeters,
    required this.trafficDelayPeakHoursMinutes,
  });

  final int commuteTimeMinutes;
  final String mode;
  final String nearestStation;
  final int stationDistanceMeters;
  final int trafficDelayPeakHoursMinutes;

  @override
  List<Object?> get props => [
        commuteTimeMinutes,
        mode,
        nearestStation,
        stationDistanceMeters,
        trafficDelayPeakHoursMinutes,
      ];
}

/// Point of interest in 500m walkability zone.
class NearbyPlace extends Equatable {
  const NearbyPlace({
    required this.name,
    required this.distanceMeters,
  });

  final String name;
  final int distanceMeters;

  @override
  List<Object?> get props => [name, distanceMeters];
}

/// 500m walkability nearby essentials layer.
class NearbyEssentials extends Equatable {
  const NearbyEssentials({
    this.metroStations = const [],
    this.busStops = const [],
    this.mosques = const [],
    this.bazaars = const [],
    this.hospitals = const [],
    this.pharmacies = const [],
  });

  final List<NearbyPlace> metroStations;
  final List<NearbyPlace> busStops;
  final List<NearbyPlace> mosques;
  final List<NearbyPlace> bazaars;
  final List<NearbyPlace> hospitals;
  final List<NearbyPlace> pharmacies;

  @override
  List<Object?> get props => [
        metroStations,
        busStops,
        mosques,
        bazaars,
        hospitals,
        pharmacies,
      ];
}

/// AI generated Bangladeshi legal rent agreement.
class RentAgreementResult extends Equatable {
  const RentAgreementResult({
    required this.agreementTitle,
    required this.fullLegalMarkdown,
    this.generatedAt,
    this.success = true,
  });

  final bool success;
  final String agreementTitle;
  final String fullLegalMarkdown;
  final DateTime? generatedAt;

  @override
  List<Object?> get props => [
        success,
        agreementTitle,
        fullLegalMarkdown,
        generatedAt,
      ];
}

/// AI Fair Rent Meter analysis.
class FairRentAnalysis extends Equatable {
  const FairRentAnalysis({
    required this.propertyId,
    required this.currentRent,
    required this.areaAverageRent,
    required this.verdict,
    required this.percentageDifference,
    required this.ratingScore,
    required this.insight,
  });

  final String propertyId;
  final double currentRent;
  final double areaAverageRent;
  final String verdict;
  final double percentageDifference;
  final double ratingScore;
  final String insight;

  @override
  List<Object?> get props => [
        propertyId,
        currentRent,
        areaAverageRent,
        verdict,
        percentageDifference,
        ratingScore,
        insight,
      ];
}

/// Demand vs. Supply Neighborhood Heatmap point.
class AreaHeatmapItem extends Equatable {
  const AreaHeatmapItem({
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.searchDemandIndex,
    required this.activeListingsCount,
    required this.pressureRatio,
    required this.marketState,
  });

  final String area;
  final double latitude;
  final double longitude;
  final int searchDemandIndex;
  final int activeListingsCount;
  final double pressureRatio;
  final String marketState;

  @override
  List<Object?> get props => [
        area,
        latitude,
        longitude,
        searchDemandIndex,
        activeListingsCount,
        pressureRatio,
        marketState,
      ];
}
