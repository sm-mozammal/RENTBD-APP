import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import '../../domain/entities/area_insight.dart';
import '../../domain/repositories/insight_repository.dart';
import '../datasources/insight_datasource.dart';

class InsightRepositoryImpl implements InsightRepository {
  InsightRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
  });

  final InsightDataSource mockDataSource;
  final InsightDataSource remoteDataSource;

  InsightDataSource get _activeDataSource =>
      AppEnvironment.useMockData ? mockDataSource : remoteDataSource;

  @override
  Future<AreaInsight> getAreaInsight(String area) async {
    try {
      final model = await _activeDataSource.getAreaInsight(area);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<ResidentReview> submitInsight({
    required String area,
    required String waterloggingRisk,
    required int gasPressureRating,
    required String waterQuality,
    required int safetyRating,
    required String reviewText,
  }) async {
    try {
      final model = await _activeDataSource.submitInsight({
        'area': area,
        'waterlogging_risk': waterloggingRisk,
        'gas_pressure_rating': gasPressureRating,
        'water_quality': waterQuality,
        'safety_rating': safetyRating,
        'review_text': reviewText,
      });
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
