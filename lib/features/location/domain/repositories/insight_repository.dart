import '../entities/area_insight.dart';

abstract class InsightRepository {
  Future<AreaInsight> getAreaInsight(String area);
  Future<ResidentReview> submitInsight({
    required String area,
    required String waterloggingRisk,
    required int gasPressureRating,
    required String waterQuality,
    required int safetyRating,
    required String reviewText,
  });
}
