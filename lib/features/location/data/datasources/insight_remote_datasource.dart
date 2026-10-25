import 'package:dio/dio.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import '../models/area_insight_model.dart';
import 'insight_datasource.dart';

class InsightRemoteDataSource implements InsightDataSource {
  const InsightRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<AreaInsightModel> getAreaInsight(String area) async {
    try {
      final response = await _dioClient.get(
        '/insights/area/',
        queryParameters: {'area': area},
      );
      return AreaInsightModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch area insight: $e');
    }
  }

  @override
  Future<ResidentReviewModel> submitInsight(Map<String, dynamic> reviewData) async {
    try {
      final response = await _dioClient.post('/insights/submit/', data: reviewData);
      return ResidentReviewModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to submit area insight review: $e');
    }
  }
}
