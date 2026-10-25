import 'package:equatable/equatable.dart';

enum PropertyType { apartment, sublet, hostel, duplex }

enum TenantCategory { family, bachelorMale, bachelorFemale, any }

enum FairPriceStatus { greatDeal, fairPrice, overpriced }

enum WaterloggingRisk { none, mild, high }

enum GasSupplyType { lineGas, cylinder, none }

enum WaterQuality { excellent, adequate, irregular }

enum RoomType { bedroom, kitchen, washroom, balcony, exterior, livingRoom }

/// Admin moderation and review status for landlord property listings.
enum PropertyApprovalStatus {
  pendingReview, // Waiting for admin review & approval
  approved,      // Approved by admin and live
  rejected,      // Rejected by admin
}

/// Represents an image of a property with AI room classification and live GPS geo-tagging.
class PropertyImage extends Equatable {
  const PropertyImage({
    required this.id,
    required this.imageUrl,
    required this.roomType,
    this.isGeoTagged = true,
    this.capturedAt,
  });

  final String id;
  final String imageUrl;
  final RoomType roomType;
  final bool isGeoTagged;
  final DateTime? capturedAt;

  String get roomLabel {
    switch (roomType) {
      case RoomType.bedroom:
        return 'Bedroom';
      case RoomType.kitchen:
        return 'Kitchen';
      case RoomType.washroom:
        return 'Washroom';
      case RoomType.balcony:
        return 'Balcony';
      case RoomType.exterior:
        return 'Exterior / Road';
      case RoomType.livingRoom:
        return 'Living Room';
    }
  }

  @override
  List<Object?> get props => [id, imageUrl, roomType, isGeoTagged, capturedAt];
}

/// Pure Dart domain entity for Property listings.
class Property extends Equatable {
  const Property({
    required this.id,
    required this.landlordId,
    required this.landlordName,
    required this.landlordPhoneMasked,
    this.landlordIsNidVerified = false,
    this.landlordRating = 0.0,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.tenantCategory,
    required this.rentAmount,
    required this.securityDeposit,
    this.serviceCharge = 0.0,
    this.estimatedUtilities = 0.0,
    required this.bedrooms,
    required this.bathrooms,
    required this.balconies,
    required this.squareFeet,
    required this.floorLevel,
    this.totalFloors = 0,
    required this.latitude,
    required this.longitude,
    required this.areaNeighborhood,
    required this.fullAddress,
    required this.images,
    this.hasGeoTaggedPhotos = false,
    this.isAvailable = true,
    this.isOwnerVerified = false,
    this.approvalStatus = PropertyApprovalStatus.approved,
    required this.fairPriceStatus,
    this.fairPricePercentDiff = 0.0,
    this.areaAverageRent = 0.0,
    this.alleyWidthFeet = 0.0,
    this.gasSupply = GasSupplyType.none,
    this.waterloggingRisk = WaterloggingRisk.none,
    this.waterQuality = WaterQuality.adequate,
    this.nightSafetyRating = 0.0,
    this.isSaved = false,
  });

  final String id;
  final String landlordId;
  final String landlordName;
  final String landlordPhoneMasked;
  final bool landlordIsNidVerified;
  final double landlordRating;

  final String title;
  final String description;
  final PropertyType propertyType;
  final TenantCategory tenantCategory;
  final double rentAmount;
  final double securityDeposit;
  final double serviceCharge;
  final double estimatedUtilities;

  final int bedrooms;
  final int bathrooms;
  final int balconies;
  final int squareFeet;
  final int floorLevel;
  final int totalFloors;

  final double latitude;
  final double longitude;
  final String areaNeighborhood;
  final String fullAddress;

  final List<PropertyImage> images;
  final bool hasGeoTaggedPhotos;
  final bool isAvailable;
  final bool isOwnerVerified;
  final PropertyApprovalStatus approvalStatus;

  bool get isApproved => approvalStatus == PropertyApprovalStatus.approved;
  bool get isPendingReview => approvalStatus == PropertyApprovalStatus.pendingReview;
  bool get isRejected => approvalStatus == PropertyApprovalStatus.rejected;

  final FairPriceStatus fairPriceStatus;
  final double fairPricePercentDiff;
  final double areaAverageRent;

  final double alleyWidthFeet;
  final GasSupplyType gasSupply;
  final WaterloggingRisk waterloggingRisk;
  final WaterQuality waterQuality;
  final double nightSafetyRating;
  final bool isSaved;

  double get totalMonthlyRecurring => rentAmount + serviceCharge + estimatedUtilities;

  double get defaultUpfrontMoveInCost =>
      rentAmount + securityDeposit + serviceCharge + estimatedUtilities + 3000; // 3000 estimated moving transport

  String get tenantCategoryLabel {
    switch (tenantCategory) {
      case TenantCategory.family:
        return 'Family Only';
      case TenantCategory.bachelorMale:
        return 'Bachelor (Male)';
      case TenantCategory.bachelorFemale:
        return 'Bachelor (Female)';
      case TenantCategory.any:
        return 'Family / Bachelor';
    }
  }

  Property copyWith({
    String? id,
    String? landlordId,
    String? landlordName,
    String? landlordPhoneMasked,
    bool? landlordIsNidVerified,
    double? landlordRating,
    String? title,
    String? description,
    PropertyType? propertyType,
    TenantCategory? tenantCategory,
    double? rentAmount,
    double? securityDeposit,
    double? serviceCharge,
    double? estimatedUtilities,
    int? bedrooms,
    int? bathrooms,
    int? balconies,
    int? squareFeet,
    int? floorLevel,
    int? totalFloors,
    double? latitude,
    double? longitude,
    String? areaNeighborhood,
    String? fullAddress,
    List<PropertyImage>? images,
    bool? hasGeoTaggedPhotos,
    bool? isAvailable,
    bool? isOwnerVerified,
    PropertyApprovalStatus? approvalStatus,
    FairPriceStatus? fairPriceStatus,
    double? fairPricePercentDiff,
    double? areaAverageRent,
    double? alleyWidthFeet,
    GasSupplyType? gasSupply,
    WaterloggingRisk? waterloggingRisk,
    WaterQuality? waterQuality,
    double? nightSafetyRating,
    bool? isSaved,
  }) {
    return Property(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      landlordName: landlordName ?? this.landlordName,
      landlordPhoneMasked: landlordPhoneMasked ?? this.landlordPhoneMasked,
      landlordIsNidVerified: landlordIsNidVerified ?? this.landlordIsNidVerified,
      landlordRating: landlordRating ?? this.landlordRating,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      tenantCategory: tenantCategory ?? this.tenantCategory,
      rentAmount: rentAmount ?? this.rentAmount,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      estimatedUtilities: estimatedUtilities ?? this.estimatedUtilities,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      balconies: balconies ?? this.balconies,
      squareFeet: squareFeet ?? this.squareFeet,
      floorLevel: floorLevel ?? this.floorLevel,
      totalFloors: totalFloors ?? this.totalFloors,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaNeighborhood: areaNeighborhood ?? this.areaNeighborhood,
      fullAddress: fullAddress ?? this.fullAddress,
      images: images ?? this.images,
      hasGeoTaggedPhotos: hasGeoTaggedPhotos ?? this.hasGeoTaggedPhotos,
      isAvailable: isAvailable ?? this.isAvailable,
      isOwnerVerified: isOwnerVerified ?? this.isOwnerVerified,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      fairPriceStatus: fairPriceStatus ?? this.fairPriceStatus,
      fairPricePercentDiff: fairPricePercentDiff ?? this.fairPricePercentDiff,
      areaAverageRent: areaAverageRent ?? this.areaAverageRent,
      alleyWidthFeet: alleyWidthFeet ?? this.alleyWidthFeet,
      gasSupply: gasSupply ?? this.gasSupply,
      waterloggingRisk: waterloggingRisk ?? this.waterloggingRisk,
      waterQuality: waterQuality ?? this.waterQuality,
      nightSafetyRating: nightSafetyRating ?? this.nightSafetyRating,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        landlordId,
        landlordName,
        landlordPhoneMasked,
        landlordIsNidVerified,
        landlordRating,
        title,
        description,
        propertyType,
        tenantCategory,
        rentAmount,
        securityDeposit,
        serviceCharge,
        estimatedUtilities,
        bedrooms,
        bathrooms,
        balconies,
        squareFeet,
        floorLevel,
        totalFloors,
        latitude,
        longitude,
        areaNeighborhood,
        fullAddress,
        images,
        hasGeoTaggedPhotos,
        isAvailable,
        isOwnerVerified,
        approvalStatus,
        fairPriceStatus,
        fairPricePercentDiff,
        areaAverageRent,
        alleyWidthFeet,
        gasSupply,
        waterloggingRisk,
        waterQuality,
        nightSafetyRating,
        isSaved,
      ];
}
