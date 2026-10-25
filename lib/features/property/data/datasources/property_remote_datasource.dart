import 'dart:io';
import 'package:dio/dio.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import 'package:rentbd_app/core/network/drf_paginated_response.dart';
import '../../domain/entities/property_filter.dart';
import '../models/property_model.dart';
import '../models/property_operations_model.dart';
import 'property_datasource.dart';

/// Real remote data source interacting with Django REST Framework endpoints.
class PropertyRemoteDataSource implements PropertyDataSource {
  const PropertyRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<PropertyModel>> getProperties({
    PropertyFilter? filter,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (filter != null) {
        if (filter.area != null) queryParams['area'] = filter.area;
        if (filter.tenantCategory != null) {
          queryParams['tenant_category'] = filter.tenantCategory!.name.toUpperCase();
        }
        if (filter.minRent != null) queryParams['min_rent'] = filter.minRent;
        if (filter.maxRent != null) queryParams['max_rent'] = filter.maxRent;
        if (filter.bedrooms != null) queryParams['bedrooms'] = filter.bedrooms;
        if (filter.searchQuery != null) queryParams['search'] = filter.searchQuery;
      }

      final response = await _dioClient.get(
        '/properties/',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        final list = response.data as List<dynamic>;
        return list
            .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      final paginated = DrfPaginatedResponse<PropertyModel>.fromJson(
        response.data as Map<String, dynamic>,
        PropertyModel.fromJson,
      );

      return paginated.results;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch properties from DRF: $e');
    }
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    try {
      final response = await _dioClient.get('/properties/$id/');
      return PropertyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch property details: $e');
    }
  }

  @override
  Future<bool> toggleSaveProperty(String propertyId) async {
    try {
      final response = await _dioClient.post('/properties/$propertyId/save/');
      final data = response.data as Map<String, dynamic>;
      return data['is_saved'] as bool? ?? false;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to toggle save status: $e');
    }
  }

  @override
  Future<List<PropertyModel>> getSavedProperties() async {
    try {
      final response = await _dioClient.get('/properties/saved/');
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch saved properties: $e');
    }
  }

  @override
  Future<List<PropertyModel>> naturalLanguageSearch(String query) async {
    try {
      final response = await _dioClient.get(
        '/properties/ai-search/',
        queryParameters: {'q': query},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to perform AI natural search: $e');
    }
  }

  @override
  Future<PropertyModel> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final photos = (propertyData['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((p) => p.trim().isNotEmpty)
              .toList() ??
          [];

      final cleanData = Map<String, dynamic>.from(propertyData)..remove('photos');
      final response = await _dioClient.post('/properties/', data: cleanData);
      var model = PropertyModel.fromJson(response.data as Map<String, dynamic>);

      // Upload each photo to /properties/<id>/photos/
      if (photos.isNotEmpty && model.id.isNotEmpty) {
        final uploadedImages = <PropertyImageModel>[];
        for (var i = 0; i < photos.length; i++) {
          final photoPath = photos[i];
          try {
            final uploaded = await uploadPropertyPhoto(
              model.id,
              photoPath,
              tag: i == 0 ? 'LIVING' : 'BEDROOM',
              isCover: i == 0,
            );
            uploadedImages.add(uploaded);
          } catch (_) {
            // Keep going with remaining photos if one encounters an issue
          }
        }
        if (uploadedImages.isNotEmpty) {
          model = PropertyModel.fromEntity(
            model.toEntity().copyWith(
              images: uploadedImages.map((m) => m.toEntity()).toList(),
              hasGeoTaggedPhotos: true,
            ),
          );
        }
      }

      return model;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to create property: $e');
    }
  }

  @override
  Future<PropertyImageModel> uploadPropertyPhoto(
    String propertyId,
    String filePath, {
    String tag = 'LIVING',
    bool isCover = false,
  }) async {
    try {
      final cleanPath = filePath.replaceFirst('file://', '');
      final file = File(cleanPath);
      final fileName = cleanPath.split('/').last;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: fileName.isNotEmpty ? fileName : 'photo.jpg',
        ),
        'tag': tag,
        'is_cover': isCover,
      });

      final response = await _dioClient.post(
        '/properties/$propertyId/photos/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return PropertyImageModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to upload photo: $e');
    }
  }

  @override
  Future<bool> toggleVault(String propertyId) async {
    try {
      final response = await _dioClient.post('/properties/$propertyId/toggle-vault/');
      final data = response.data as Map<String, dynamic>? ?? {};
      return (data['is_vaulted'] ?? data['is_vault']) as bool? ?? false;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to toggle vault status: $e');
    }
  }

  @override
  Future<MoveInEstimateModel> calculateMoveIn(
    String propertyId, {
    bool includeTruck = true,
    bool includeLabour = true,
    String truckSize = 'medium',
    double distanceKm = 8,
  }) async {
    try {
      final response = await _dioClient.post(
        '/properties/calculate-move-in/',
        data: {
          'property_id': propertyId,
          'include_truck': includeTruck,
          'include_labour': includeLabour,
          'truck_size': truckSize,
          'distance_km': distanceKm,
        },
      );
      return MoveInEstimateModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to calculate move in costs: $e');
    }
  }

  @override
  Future<PropertyComparisonModel> compareProperties(List<String> propertyIds) async {
    try {
      final response = await _dioClient.post(
        '/properties/compare/',
        data: {'property_ids': propertyIds},
      );
      return PropertyComparisonModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to compare properties: $e');
    }
  }

  @override
  Future<List<PropertyModel>> drawSearch(List<Map<String, double>> polygon) async {
    try {
      final response = await _dioClient.post(
        '/properties/draw-search/',
        data: {'polygon': polygon},
      );
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to execute polygon draw search: $e');
    }
  }

  @override
  Future<CommuteEstimateModel> calculateCommute(
    String propertyId,
    String destinationArea,
    String commuteMode,
  ) async {
    try {
      final response = await _dioClient.post(
        '/properties/commute-calculator/',
        data: {
          'property_id': propertyId,
          'destination_area': destinationArea,
          'commute_mode': commuteMode,
        },
      );
      return CommuteEstimateModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to calculate commute: $e');
    }
  }

  @override
  Future<NearbyEssentialsModel> getNearbyEssentials(String propertyId) async {
    try {
      final response = await _dioClient.get('/properties/$propertyId/nearby-essentials/');
      return NearbyEssentialsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch nearby essentials: $e');
    }
  }

  @override
  Future<FairRentAnalysisModel> getFairRentMeter(String propertyId) async {
    try {
      final response = await _dioClient.get('/properties/$propertyId/fair-rent-meter/');
      return FairRentAnalysisModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch fair rent meter: $e');
    }
  }

  @override
  Future<RentAgreementModel> generateAgreement(Map<String, dynamic> agreementData) async {
    try {
      final response = await _dioClient.post(
        '/properties/ai/generate-agreement/',
        data: agreementData,
      );
      return RentAgreementModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to generate rent agreement: $e');
    }
  }

  @override
  Future<List<AreaHeatmapItemModel>> getDemandSupplyHeatmap() async {
    try {
      final response = await _dioClient.get('/properties/analytics/demand-supply-heatmap/');
      final list = (response.data is Map && response.data['heatmap'] != null)
          ? response.data['heatmap'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => AreaHeatmapItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch demand/supply heatmap: $e');
    }
  }

  @override
  Future<PropertyModel> updatePropertyStatus(String propertyId, String status) async {
    try {
      final response = await _dioClient.patch(
        '/admin/properties/$propertyId/status/',
        data: {'status': status},
      );
      return PropertyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to update property status: $e');
    }
  }
}

