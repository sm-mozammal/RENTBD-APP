import '../../domain/entities/area_insight.dart';

class ResidentReviewModel {
  const ResidentReviewModel({
    required this.reviewerName,
    required this.waterloggingRisk,
    required this.gasPressureRating,
    required this.safetyRating,
    required this.reviewText,
    this.createdAt,
  });

  factory ResidentReviewModel.fromJson(Map<String, dynamic> json) {
    return ResidentReviewModel(
      reviewerName: json['reviewer_name'] as String? ?? 'Dhaka Resident',
      waterloggingRisk: json['waterlogging_risk'] as String? ?? 'low',
      gasPressureRating: json['gas_pressure_rating'] as int? ?? 4,
      safetyRating: json['safety_rating'] as int? ?? 4,
      reviewText: json['review_text'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String reviewerName;
  final String waterloggingRisk;
  final int gasPressureRating;
  final int safetyRating;
  final String reviewText;
  final DateTime? createdAt;

  ResidentReview toEntity() => ResidentReview(
        reviewerName: reviewerName,
        waterloggingRisk: waterloggingRisk,
        gasPressureRating: gasPressureRating,
        safetyRating: safetyRating,
        reviewText: reviewText,
        createdAt: createdAt,
      );
}

class AreaInsightModel {
  const AreaInsightModel({
    required this.area,
    required this.waterloggingSummary,
    required this.gasPressureAvg,
    required this.waterQualitySummary,
    required this.safetyRatingAvg,
    required this.totalReviews,
    this.residentReviews = const [],
  });

  factory AreaInsightModel.fromJson(Map<String, dynamic> json) {
    final list = json['resident_reviews'] as List<dynamic>? ?? [];
    return AreaInsightModel(
      area: json['area'] as String? ?? '',
      waterloggingSummary: json['waterlogging_summary'] as String? ?? 'low',
      gasPressureAvg: (json['gas_pressure_avg'] as num?)?.toDouble() ?? 4.0,
      waterQualitySummary:
          json['water_quality_summary'] as String? ?? 'drinkable_filtered',
      safetyRatingAvg: (json['safety_rating_avg'] as num?)?.toDouble() ?? 4.5,
      totalReviews: json['total_reviews'] as int? ?? 0,
      residentReviews: list
          .map((r) => ResidentReviewModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  final String area;
  final String waterloggingSummary;
  final double gasPressureAvg;
  final String waterQualitySummary;
  final double safetyRatingAvg;
  final int totalReviews;
  final List<ResidentReviewModel> residentReviews;

  AreaInsight toEntity() => AreaInsight(
        area: area,
        waterloggingSummary: waterloggingSummary,
        gasPressureAvg: gasPressureAvg,
        waterQualitySummary: waterQualitySummary,
        safetyRatingAvg: safetyRatingAvg,
        totalReviews: totalReviews,
        residentReviews: residentReviews.map((r) => r.toEntity()).toList(),
      );
}
