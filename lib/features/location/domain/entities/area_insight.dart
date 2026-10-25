import 'package:equatable/equatable.dart';

class ResidentReview extends Equatable {
  const ResidentReview({
    required this.reviewerName,
    required this.waterloggingRisk,
    required this.gasPressureRating,
    required this.safetyRating,
    required this.reviewText,
    this.createdAt,
  });

  final String reviewerName;
  final String waterloggingRisk;
  final int gasPressureRating;
  final int safetyRating;
  final String reviewText;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        reviewerName,
        waterloggingRisk,
        gasPressureRating,
        safetyRating,
        reviewText,
        createdAt,
      ];
}

class AreaInsight extends Equatable {
  const AreaInsight({
    required this.area,
    required this.waterloggingSummary,
    required this.gasPressureAvg,
    required this.waterQualitySummary,
    required this.safetyRatingAvg,
    required this.totalReviews,
    this.residentReviews = const [],
  });

  final String area;
  final String waterloggingSummary;
  final double gasPressureAvg;
  final String waterQualitySummary;
  final double safetyRatingAvg;
  final int totalReviews;
  final List<ResidentReview> residentReviews;

  @override
  List<Object?> get props => [
        area,
        waterloggingSummary,
        gasPressureAvg,
        waterQualitySummary,
        safetyRatingAvg,
        totalReviews,
        residentReviews,
      ];
}
