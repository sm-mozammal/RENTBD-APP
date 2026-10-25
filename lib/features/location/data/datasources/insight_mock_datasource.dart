import 'package:rentbd_app/core/config/app_environment.dart';
import '../models/area_insight_model.dart';
import 'insight_datasource.dart';

class InsightMockDataSource implements InsightDataSource {
  final Map<String, AreaInsightModel> _insights = {
    'mirpur_10': const AreaInsightModel(
      area: 'Mirpur 10',
      waterloggingSummary: 'low',
      gasPressureAvg: 4.2,
      waterQualitySummary: 'drinkable_filtered',
      safetyRatingAvg: 4.5,
      totalReviews: 38,
      residentReviews: [
        ResidentReviewModel(
          reviewerName: 'Tariqul Islam',
          waterloggingRisk: 'low',
          gasPressureRating: 4,
          safetyRating: 5,
          reviewText: 'Road 14 has zero waterlogging even during monsoon rains. Titas gas is strong throughout the day.',
        ),
        ResidentReviewModel(
          reviewerName: 'Sadia Rahman',
          waterloggingRisk: 'none',
          gasPressureRating: 5,
          safetyRating: 4,
          reviewText: 'Quiet residential block near metro station. Very safe for women walking home at night.',
        ),
      ],
    ),
    'bashundhara_ra': const AreaInsightModel(
      area: 'Bashundhara R/A',
      waterloggingSummary: 'none',
      gasPressureAvg: 4.8,
      waterQualitySummary: 'drinkable_filtered',
      safetyRatingAvg: 4.9,
      totalReviews: 45,
      residentReviews: [
        ResidentReviewModel(
          reviewerName: 'Abrar Hossain',
          waterloggingRisk: 'none',
          gasPressureRating: 5,
          safetyRating: 5,
          reviewText: 'Block D is extremely clean and secure with private security gates. Cylinder gas widely available.',
        ),
      ],
    ),
  };

  @override
  Future<AreaInsightModel> getAreaInsight(String area) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final key = area.toLowerCase().replaceAll(' ', '_');
    return _insights[key] ??
        AreaInsightModel(
          area: area,
          waterloggingSummary: 'moderate',
          gasPressureAvg: 4.0,
          waterQualitySummary: 'adequate',
          safetyRatingAvg: 4.2,
          totalReviews: 12,
          residentReviews: const [
            ResidentReviewModel(
              reviewerName: 'Local Resident',
              waterloggingRisk: 'mild',
              gasPressureRating: 4,
              safetyRating: 4,
              reviewText: 'Good connectivity and decent water supply.',
            ),
          ],
        );
  }

  @override
  Future<ResidentReviewModel> submitInsight(Map<String, dynamic> reviewData) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return ResidentReviewModel(
      reviewerName: 'Current User',
      waterloggingRisk: reviewData['waterlogging_risk'] as String? ?? 'low',
      gasPressureRating: reviewData['gas_pressure_rating'] as int? ?? 4,
      safetyRating: reviewData['safety_rating'] as int? ?? 5,
      reviewText: reviewData['review_text'] as String? ?? '',
      createdAt: DateTime.now(),
    );
  }
}
