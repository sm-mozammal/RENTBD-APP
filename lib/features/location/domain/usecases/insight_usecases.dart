import '../entities/area_insight.dart';
import '../repositories/insight_repository.dart';

class GetAreaInsightUseCase {
  const GetAreaInsightUseCase(this.repository);
  final InsightRepository repository;

  Future<AreaInsight> call(String area) => repository.getAreaInsight(area);
}

class SubmitAreaInsightUseCase {
  const SubmitAreaInsightUseCase(this.repository);
  final InsightRepository repository;

  Future<ResidentReview> call({
    required String area,
    required String waterloggingRisk,
    required int gasPressureRating,
    required String waterQuality,
    required int safetyRating,
    required String reviewText,
  }) {
    return repository.submitInsight(
      area: area,
      waterloggingRisk: waterloggingRisk,
      gasPressureRating: gasPressureRating,
      waterQuality: waterQuality,
      safetyRating: safetyRating,
      reviewText: reviewText,
    );
  }
}
