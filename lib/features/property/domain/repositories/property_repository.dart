import '../entities/property.dart';
import '../entities/property_filter.dart';
import '../entities/property_operations.dart';

/// Abstract repository contract for property retrieval and interaction.
abstract class PropertyRepository {
  /// Fetch list of properties matching optional [filter] and [page]
  Future<List<Property>> getProperties({PropertyFilter? filter, int page = 1});

  /// Fetch single property detail by [id]
  Future<Property> getPropertyById(String id);

  /// Toggle wishlist/save status for [propertyId]
  Future<bool> toggleSaveProperty(String propertyId);

  /// Fetch all properties currently saved by user
  Future<List<Property>> getSavedProperties();

  /// Natural language / Voice search query (Bangla, Banglish, English)
  Future<List<Property>> naturalLanguageSearch(String query);

  /// Landlord Quick Post listing
  Future<Property> createProperty(Map<String, dynamic> propertyData);

  /// Upload a photo for a property (supports EXIF extraction and cover setting)
  Future<PropertyImage> uploadPropertyPhoto(
    String propertyId,
    String filePath, {
    String tag = 'LIVING',
    bool isCover = false,
  });

  /// Toggle vacancy / vault status
  Future<bool> toggleVault(String propertyId);

  /// Move-in upfront cash calculation
  Future<MoveInEstimate> calculateMoveIn(
    String propertyId, {
    bool includeTruck = true,
    bool includeLabour = true,
    String truckSize = 'medium',
    double distanceKm = 8,
  });

  /// Side-by-side comparison of 2-3 properties
  Future<PropertyComparison> compareProperties(List<String> propertyIds);

  /// Freehand polygon draw-on-map search
  Future<List<Property>> drawSearch(List<Map<String, double>> polygon);

  /// Commute and Metro travel time estimation
  Future<CommuteEstimate> calculateCommute(
    String propertyId,
    String destinationArea,
    String commuteMode,
  );

  /// 500m walkability essentials
  Future<NearbyEssentials> getNearbyEssentials(String propertyId);

  /// AI Fair Rent Valuation
  Future<FairRentAnalysis> getFairRentMeter(String propertyId);

  /// Tenancy Agreement Generator
  Future<RentAgreementResult> generateAgreement(Map<String, dynamic> agreementData);

  /// Neighborhood Demand vs Supply Heatmap
  Future<List<AreaHeatmapItem>> getDemandSupplyHeatmap();

  /// Update property moderation status (e.g. 'active', 'rejected', 'pending')
  Future<Property> updatePropertyStatus(String propertyId, String status);
}
