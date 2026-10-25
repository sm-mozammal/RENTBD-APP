import '../models/area_insight_model.dart';

abstract class InsightDataSource {
  Future<AreaInsightModel> getAreaInsight(String area);
  Future<ResidentReviewModel> submitInsight(Map<String, dynamic> reviewData);
}
