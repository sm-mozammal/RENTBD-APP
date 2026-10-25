import '../../domain/entities/property_filter.dart';
import '../models/property_model.dart';
import '../models/property_operations_model.dart';

/// Abstract DataSource contract for property fetching, posting, and AI features.
abstract class PropertyDataSource {
  Future<List<PropertyModel>> getProperties({PropertyFilter? filter, int page = 1});
  Future<PropertyModel> getPropertyById(String id);
  Future<bool> toggleSaveProperty(String propertyId);
  Future<List<PropertyModel>> getSavedProperties();
  Future<List<PropertyModel>> naturalLanguageSearch(String query);

  Future<PropertyModel> createProperty(Map<String, dynamic> propertyData);
  Future<PropertyImageModel> uploadPropertyPhoto(
    String propertyId,
    String filePath, {
    String tag = 'LIVING',
    bool isCover = false,
  });
  Future<bool> toggleVault(String propertyId);
  Future<MoveInEstimateModel> calculateMoveIn(
    String propertyId, {
    bool includeTruck = true,
    bool includeLabour = true,
    String truckSize = 'medium',
    double distanceKm = 8,
  });
  Future<PropertyComparisonModel> compareProperties(List<String> propertyIds);
  Future<List<PropertyModel>> drawSearch(List<Map<String, double>> polygon);
  Future<CommuteEstimateModel> calculateCommute(
    String propertyId,
    String destinationArea,
    String commuteMode,
  );
  Future<NearbyEssentialsModel> getNearbyEssentials(String propertyId);
  Future<FairRentAnalysisModel> getFairRentMeter(String propertyId);
  Future<RentAgreementModel> generateAgreement(Map<String, dynamic> agreementData);
  Future<List<AreaHeatmapItemModel>> getDemandSupplyHeatmap();
  Future<PropertyModel> updatePropertyStatus(String propertyId, String status);
}
