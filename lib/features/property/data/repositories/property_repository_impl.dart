import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/entities/property_operations.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_datasource.dart';

/// Clean Architecture Repository implementation for Properties.
/// Seamlessly switches between Mock and Remote datasources with zero UI changes.
class PropertyRepositoryImpl implements PropertyRepository {
  PropertyRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
  });

  final PropertyDataSource mockDataSource;
  final PropertyDataSource remoteDataSource;

  PropertyDataSource get _activeDataSource =>
      AppEnvironment.useMockData ? mockDataSource : remoteDataSource;

  @override
  Future<List<Property>> getProperties({
    PropertyFilter? filter,
    int page = 1,
  }) async {
    try {
      final models = await _activeDataSource.getProperties(filter: filter, page: page);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<Property> getPropertyById(String id) async {
    try {
      final model = await _activeDataSource.getPropertyById(id);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<bool> toggleSaveProperty(String propertyId) async {
    try {
      return await _activeDataSource.toggleSaveProperty(propertyId);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<Property>> getSavedProperties() async {
    try {
      final models = await _activeDataSource.getSavedProperties();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<Property>> naturalLanguageSearch(String query) async {
    try {
      final models = await _activeDataSource.naturalLanguageSearch(query);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<Property> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final model = await _activeDataSource.createProperty(propertyData);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<PropertyImage> uploadPropertyPhoto(
    String propertyId,
    String filePath, {
    String tag = 'LIVING',
    bool isCover = false,
  }) async {
    try {
      final model = await _activeDataSource.uploadPropertyPhoto(
        propertyId,
        filePath,
        tag: tag,
        isCover: isCover,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<bool> toggleVault(String propertyId) async {
    try {
      return await _activeDataSource.toggleVault(propertyId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<MoveInEstimate> calculateMoveIn(
    String propertyId, {
    bool includeTruck = true,
    bool includeLabour = true,
    String truckSize = 'medium',
    double distanceKm = 8,
  }) async {
    try {
      final model = await _activeDataSource.calculateMoveIn(
        propertyId,
        includeTruck: includeTruck,
        includeLabour: includeLabour,
        truckSize: truckSize,
        distanceKm: distanceKm,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<PropertyComparison> compareProperties(List<String> propertyIds) async {
    try {
      final model = await _activeDataSource.compareProperties(propertyIds);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<Property>> drawSearch(List<Map<String, double>> polygon) async {
    try {
      final models = await _activeDataSource.drawSearch(polygon);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<CommuteEstimate> calculateCommute(
    String propertyId,
    String destinationArea,
    String commuteMode,
  ) async {
    try {
      final model = await _activeDataSource.calculateCommute(
        propertyId,
        destinationArea,
        commuteMode,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<NearbyEssentials> getNearbyEssentials(String propertyId) async {
    try {
      final model = await _activeDataSource.getNearbyEssentials(propertyId);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<FairRentAnalysis> getFairRentMeter(String propertyId) async {
    try {
      final model = await _activeDataSource.getFairRentMeter(propertyId);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<RentAgreementResult> generateAgreement(Map<String, dynamic> agreementData) async {
    try {
      final model = await _activeDataSource.generateAgreement(agreementData);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<AreaHeatmapItem>> getDemandSupplyHeatmap() async {
    try {
      final models = await _activeDataSource.getDemandSupplyHeatmap();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<Property> updatePropertyStatus(String propertyId, String status) async {
    try {
      final model = await _activeDataSource.updatePropertyStatus(propertyId, status);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
