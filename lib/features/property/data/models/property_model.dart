import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rentbd_app/core/config/app_environment.dart';
import '../../domain/entities/property.dart';

class PropertyImageModel {
  const PropertyImageModel({
    required this.id,
    required this.imageUrl,
    required this.roomType,
    this.isGeoTagged = true,
    this.capturedAt,
  });

  static String normalizeImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String url = raw.trim();

    if (url.startsWith('/media/') || url.startsWith('/static/')) {
      final base = AppEnvironment.baseUrl.replaceAll('/api/v1', '');
      url = '$base$url';
    }

    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          if (url.contains('127.0.0.1:8000')) {
            url = url.replaceAll('127.0.0.1:8000', '10.0.2.2:8000');
          } else if (url.contains('localhost:8000')) {
            url = url.replaceAll('localhost:8000', '10.0.2.2:8000');
          }
        }
      } catch (_) {}
    }
    return url;
  }

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    RoomType parseRoom(String? typeStr) {
      switch (typeStr?.toUpperCase()) {
        case 'BEDROOM':
          return RoomType.bedroom;
        case 'KITCHEN':
          return RoomType.kitchen;
        case 'WASHROOM':
        case 'BATHROOM':
          return RoomType.washroom;
        case 'BALCONY':
          return RoomType.balcony;
        case 'EXTERIOR':
        case 'BUILDING_EXTERIOR':
          return RoomType.exterior;
        default:
          return RoomType.livingRoom;
      }
    }

    final rawUrl = json['image_url'] as String? ?? json['image'] as String? ?? '';
    final imageUrl = normalizeImageUrl(rawUrl);

    return PropertyImageModel(
      id: json['id'] as String? ?? '',
      imageUrl: imageUrl,
      roomType: parseRoom(json['room_type'] as String? ?? json['tag'] as String? ?? json['category'] as String?),
      isGeoTagged: json['is_geo_tagged'] as bool? ?? json['has_exif_gps'] as bool? ?? json['is_verified_geotag'] as bool? ?? true,
      capturedAt: json['captured_at'] != null
          ? DateTime.tryParse(json['captured_at'] as String)
          : null,
    );
  }

  factory PropertyImageModel.fromEntity(PropertyImage entity) {
    return PropertyImageModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      roomType: entity.roomType,
      isGeoTagged: entity.isGeoTagged,
      capturedAt: entity.capturedAt,
    );
  }

  final String id;
  final String imageUrl;
  final RoomType roomType;
  final bool isGeoTagged;
  final DateTime? capturedAt;

  Map<String, dynamic> toJson() {
    String serializeRoom(RoomType r) {
      switch (r) {
        case RoomType.bedroom:
          return 'BEDROOM';
        case RoomType.kitchen:
          return 'KITCHEN';
        case RoomType.washroom:
          return 'WASHROOM';
        case RoomType.balcony:
          return 'BALCONY';
        case RoomType.exterior:
          return 'EXTERIOR';
        case RoomType.livingRoom:
          return 'LIVING_ROOM';
      }
    }

    return {
      'id': id,
      'image_url': imageUrl,
      'room_type': serializeRoom(roomType),
      'is_geo_tagged': isGeoTagged,
      'captured_at': capturedAt?.toIso8601String(),
    };
  }

  PropertyImage toEntity() {
    return PropertyImage(
      id: id,
      imageUrl: imageUrl,
      roomType: roomType,
      isGeoTagged: isGeoTagged,
      capturedAt: capturedAt,
    );
  }
}

/// Django REST Framework DTO for Property.
/// Maps DRF snake_case JSON keys and GeoDjango Point structures.
class PropertyModel {
  const PropertyModel({
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

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    PropertyType parsePropType(String? str) {
      switch (str?.toUpperCase()) {
        case 'SUBLET':
          return PropertyType.sublet;
        case 'HOSTEL':
          return PropertyType.hostel;
        case 'DUPLEX':
          return PropertyType.duplex;
        case 'APARTMENT':
        default:
          return PropertyType.apartment;
      }
    }

    TenantCategory parseCategory(String? str) {
      switch (str?.toUpperCase()) {
        case 'BACHELOR_MALE':
          return TenantCategory.bachelorMale;
        case 'BACHELOR_FEMALE':
          return TenantCategory.bachelorFemale;
        case 'FAMILY':
          return TenantCategory.family;
        case 'ANY':
        default:
          return TenantCategory.any;
      }
    }

    FairPriceStatus parsePriceStatus(String? str) {
      switch (str?.toUpperCase()) {
        case 'GREAT_DEAL':
          return FairPriceStatus.greatDeal;
        case 'OVERPRICED':
          return FairPriceStatus.overpriced;
        case 'FAIR_PRICE':
        default:
          return FairPriceStatus.fairPrice;
      }
    }

    GasSupplyType parseGas(String? str) {
      switch (str?.toUpperCase()) {
        case 'CYLINDER':
          return GasSupplyType.cylinder;
        case 'LINE_GAS':
          return GasSupplyType.lineGas;
        case 'NONE':
        default:
          return GasSupplyType.none;
      }
    }

    WaterloggingRisk parseWaterlogging(String? str) {
      switch (str?.toUpperCase()) {
        case 'MILD':
          return WaterloggingRisk.mild;
        case 'HIGH':
          return WaterloggingRisk.high;
        case 'NONE':
        default:
          return WaterloggingRisk.none;
      }
    }

    WaterQuality parseWater(String? str) {
      switch (str?.toUpperCase()) {
        case 'EXCELLENT':
          return WaterQuality.excellent;
        case 'IRREGULAR':
          return WaterQuality.irregular;
        case 'ADEQUATE':
        default:
          return WaterQuality.adequate;
      }
    }

    double parseDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    int parseInt(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    bool? parseBool(dynamic val) {
      if (val == null) return null;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) {
        final lower = val.toLowerCase().trim();
        return lower == 'true' || lower == '1' || lower == 'verified' || lower == 'approved';
      }
      return null;
    }

    // Parse coordinates from PostGIS GeoJSON Point if provided
    double lat = parseDouble(json['latitude'], 23.8103);
    double lng = parseDouble(json['longitude'], 90.4125);
    final geoMap = (json['geo_location'] is Map<String, dynamic>
            ? json['geo_location']
            : json['coordinates'] is Map<String, dynamic>
                ? json['coordinates']
                : null) as Map<String, dynamic>?;

    if (geoMap != null) {
      final coords = geoMap['coordinates'] as List<dynamic>?;
      if (coords != null && coords.length >= 2) {
        lng = parseDouble(coords[0], 90.4125);
        lat = parseDouble(coords[1], 23.8103);
      }
    }

    final landlordObj = json['landlord'] is Map<String, dynamic>
        ? json['landlord'] as Map<String, dynamic>
        : null;

    final String landlordId = json['landlord_id'] as String? ??
        landlordObj?['id'] as String? ??
        '';
    final String landlordName = json['landlord_name'] as String? ??
        landlordObj?['full_name'] as String? ??
        landlordObj?['name'] as String? ??
        '';
    final String landlordPhone = json['landlord_phone_masked'] as String? ??
        landlordObj?['phone_number'] as String? ??
        landlordObj?['phone'] as String? ??
        '';
    final bool landlordNid = parseBool(json['landlord_is_nid_verified']) ??
        parseBool(landlordObj?['is_nid_verified']) ??
        parseBool(json['is_nid_verified']) ??
        false;

    final double rent = parseDouble(json['rent_amount'] ?? json['rent'], 0.0);
    final int sqft = parseInt(json['square_feet'] ?? json['size_sqft'], 0);
    final String area = json['area_neighborhood'] as String? ??
        json['area'] as String? ??
        '';
    final String address = json['full_address'] as String? ??
        json['address'] as String? ??
        '';

    final rawImages = (json['images'] as List<dynamic>?) ??
        (json['photos'] as List<dynamic>?) ??
        [];

    final List<PropertyImageModel> parsedImages = rawImages.map((img) {
      if (img is Map<String, dynamic>) {
        return PropertyImageModel.fromJson(img);
      } else if (img is String) {
        return PropertyImageModel(
          id: 'photo-${img.hashCode}',
          imageUrl: img,
          roomType: RoomType.livingRoom,
          isGeoTagged: false,
        );
      }
      return PropertyImageModel(
        id: 'photo-unknown',
        imageUrl: img.toString(),
        roomType: RoomType.livingRoom,
        isGeoTagged: false,
      );
    }).toList();

    if (parsedImages.isEmpty && json['primary_photo'] != null) {
      parsedImages.add(PropertyImageModel(
        id: 'primary',
        imageUrl: json['primary_photo'] as String,
        roomType: RoomType.livingRoom,
        isGeoTagged: false,
      ));
    }

    final isVaulted = json['is_vaulted'] as bool? ?? json['is_vault'] as bool? ?? false;
    final isAvailable = json['is_available'] as bool? ?? !isVaulted;

    return PropertyModel(
      id: json['id'] as String? ?? '',
      landlordId: landlordId,
      landlordName: landlordName,
      landlordPhoneMasked: landlordPhone,
      landlordIsNidVerified: landlordNid,
      landlordRating: parseDouble(json['landlord_rating'] ?? landlordObj?['rating'], 0.0),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyType: parsePropType(json['property_type'] as String?),
      tenantCategory: parseCategory(json['tenant_category'] as String?),
      rentAmount: rent,
      securityDeposit: parseDouble(json['security_deposit'], 0.0),
      serviceCharge: parseDouble(json['service_charge'], 0.0),
      estimatedUtilities: parseDouble(json['estimated_utilities'], 0.0),
      bedrooms: parseInt(json['bedrooms'], 0),
      bathrooms: parseInt(json['bathrooms'], 0),
      balconies: parseInt(json['balconies'], 0),
      squareFeet: sqft,
      floorLevel: parseInt(json['floor_level'], 0),
      totalFloors: parseInt(json['total_floors'], 0),
      latitude: lat,
      longitude: lng,
      areaNeighborhood: area,
      fullAddress: address,
      images: parsedImages,
      hasGeoTaggedPhotos: parseBool(json['has_geo_tagged_photos']) ?? false,
      isAvailable: isAvailable,
      isOwnerVerified: parseBool(json['is_owner_verified']) ??
          parseBool(json['is_verified']) ??
          false,
      approvalStatus: () {
        final rawStatus = (json['status'] ?? json['moderation_status'] ?? json['approval_status'])
            ?.toString()
            .toUpperCase()
            .trim();
        if (rawStatus == 'PENDING' || rawStatus == 'UNDER_REVIEW' || rawStatus == 'IN_REVIEW' || rawStatus == 'REVIEW') {
          return PropertyApprovalStatus.pendingReview;
        }
        if (rawStatus == 'REJECTED' || rawStatus == 'DECLINED' || rawStatus == 'BANNED') {
          return PropertyApprovalStatus.rejected;
        }
        if (parseBool(json['is_approved']) == false) {
          return PropertyApprovalStatus.pendingReview;
        }
        if (parseBool(json['is_approved']) == true ||
            rawStatus == 'APPROVED' ||
            rawStatus == 'ACTIVE' ||
            rawStatus == 'PUBLISHED') {
          return PropertyApprovalStatus.approved;
        }
        if (parseBool(json['is_verified']) == true ||
            parseBool(json['is_owner_verified']) == true) {
          return PropertyApprovalStatus.approved;
        }
        return PropertyApprovalStatus.approved;
      }(),
      fairPriceStatus: parsePriceStatus(json['fair_price_status'] as String?),
      fairPricePercentDiff: parseDouble(json['fair_price_percent_diff'], 0.0),
      areaAverageRent: parseDouble(json['area_average_rent'], 0.0),
      alleyWidthFeet: parseDouble(json['alley_width_feet'] ?? json['road_width_ft'], 0.0),
      gasSupply: parseGas(json['gas_supply'] as String? ??
          (json['has_line_gas'] == true
              ? 'LINE_GAS'
              : (json['has_gas_cylinder'] == true
                  ? 'CYLINDER'
                  : (json['has_gas'] == true ? 'LINE_GAS' : 'NONE')))),
      waterloggingRisk: parseWaterlogging(json['waterlogging_risk'] as String?),
      waterQuality: parseWater(json['water_quality'] as String?),
      nightSafetyRating: parseDouble(json['night_safety_rating'], 0.0),
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }

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

  final List<PropertyImageModel> images;
  final bool hasGeoTaggedPhotos;
  final bool isAvailable;
  final bool isOwnerVerified;
  final PropertyApprovalStatus approvalStatus;

  final FairPriceStatus fairPriceStatus;
  final double fairPricePercentDiff;
  final double areaAverageRent;

  final double alleyWidthFeet;
  final GasSupplyType gasSupply;
  final WaterloggingRisk waterloggingRisk;
  final WaterQuality waterQuality;
  final double nightSafetyRating;
  final bool isSaved;

  Map<String, dynamic> toJson() {
    String serializeProp(PropertyType p) => p.name.toUpperCase();
    String serializeCategory(TenantCategory c) {
      switch (c) {
        case TenantCategory.bachelorMale:
          return 'BACHELOR_MALE';
        case TenantCategory.bachelorFemale:
          return 'BACHELOR_FEMALE';
        case TenantCategory.family:
          return 'FAMILY';
        case TenantCategory.any:
          return 'ANY';
      }
    }

    String serializePriceStatus(FairPriceStatus s) {
      switch (s) {
        case FairPriceStatus.greatDeal:
          return 'GREAT_DEAL';
        case FairPriceStatus.overpriced:
          return 'OVERPRICED';
        case FairPriceStatus.fairPrice:
          return 'FAIR_PRICE';
      }
    }

    return {
      'id': id,
      'landlord_id': landlordId,
      'landlord_name': landlordName,
      'landlord_phone_masked': landlordPhoneMasked,
      'landlord_is_nid_verified': landlordIsNidVerified,
      'landlord_rating': landlordRating,
      'title': title,
      'description': description,
      'property_type': serializeProp(propertyType),
      'tenant_category': serializeCategory(tenantCategory),
      'rent_amount': rentAmount,
      'security_deposit': securityDeposit,
      'service_charge': serviceCharge,
      'estimated_utilities': estimatedUtilities,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'balconies': balconies,
      'square_feet': squareFeet,
      'floor_level': floorLevel,
      'total_floors': totalFloors,
      'latitude': latitude,
      'longitude': longitude,
      'geo_location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'coordinates': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'area_neighborhood': areaNeighborhood,
      'full_address': fullAddress,
      'images': images.map((i) => i.toJson()).toList(),
      'has_geo_tagged_photos': hasGeoTaggedPhotos,
      'is_available': isAvailable,
      'is_owner_verified': isOwnerVerified,
      'approval_status': approvalStatus == PropertyApprovalStatus.approved
          ? 'APPROVED'
          : (approvalStatus == PropertyApprovalStatus.rejected ? 'REJECTED' : 'PENDING'),
      'status': approvalStatus == PropertyApprovalStatus.approved ? 'ACTIVE' : 'PENDING',
      'is_approved': approvalStatus == PropertyApprovalStatus.approved,
      'fair_price_status': serializePriceStatus(fairPriceStatus),
      'fair_price_percent_diff': fairPricePercentDiff,
      'area_average_rent': areaAverageRent,
      'alley_width_feet': alleyWidthFeet,
      'gas_supply': gasSupply.name.toUpperCase(),
      'waterlogging_risk': waterloggingRisk.name.toUpperCase(),
      'water_quality': waterQuality.name.toUpperCase(),
      'night_safety_rating': nightSafetyRating,
      'is_saved': isSaved,
    };
  }

  Property toEntity() {
    return Property(
      id: id,
      landlordId: landlordId,
      landlordName: landlordName,
      landlordPhoneMasked: landlordPhoneMasked,
      landlordIsNidVerified: landlordIsNidVerified,
      landlordRating: landlordRating,
      title: title,
      description: description,
      propertyType: propertyType,
      tenantCategory: tenantCategory,
      rentAmount: rentAmount,
      securityDeposit: securityDeposit,
      serviceCharge: serviceCharge,
      estimatedUtilities: estimatedUtilities,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      balconies: balconies,
      squareFeet: squareFeet,
      floorLevel: floorLevel,
      totalFloors: totalFloors,
      latitude: latitude,
      longitude: longitude,
      areaNeighborhood: areaNeighborhood,
      fullAddress: fullAddress,
      images: images.map((i) => i.toEntity()).toList(),
      hasGeoTaggedPhotos: hasGeoTaggedPhotos,
      isAvailable: isAvailable,
      isOwnerVerified: isOwnerVerified,
      approvalStatus: approvalStatus,
      fairPriceStatus: fairPriceStatus,
      fairPricePercentDiff: fairPricePercentDiff,
      areaAverageRent: areaAverageRent,
      alleyWidthFeet: alleyWidthFeet,
      gasSupply: gasSupply,
      waterloggingRisk: waterloggingRisk,
      waterQuality: waterQuality,
      nightSafetyRating: nightSafetyRating,
      isSaved: isSaved,
    );
  }

  factory PropertyModel.fromEntity(Property entity) {
    return PropertyModel(
      id: entity.id,
      landlordId: entity.landlordId,
      landlordName: entity.landlordName,
      landlordPhoneMasked: entity.landlordPhoneMasked,
      landlordIsNidVerified: entity.landlordIsNidVerified,
      landlordRating: entity.landlordRating,
      title: entity.title,
      description: entity.description,
      propertyType: entity.propertyType,
      tenantCategory: entity.tenantCategory,
      rentAmount: entity.rentAmount,
      securityDeposit: entity.securityDeposit,
      serviceCharge: entity.serviceCharge,
      estimatedUtilities: entity.estimatedUtilities,
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      balconies: entity.balconies,
      squareFeet: entity.squareFeet,
      floorLevel: entity.floorLevel,
      totalFloors: entity.totalFloors,
      latitude: entity.latitude,
      longitude: entity.longitude,
      areaNeighborhood: entity.areaNeighborhood,
      fullAddress: entity.fullAddress,
      images: entity.images.map((i) => PropertyImageModel.fromEntity(i)).toList(),
      hasGeoTaggedPhotos: entity.hasGeoTaggedPhotos,
      isAvailable: entity.isAvailable,
      isOwnerVerified: entity.isOwnerVerified,
      approvalStatus: entity.approvalStatus,
      fairPriceStatus: entity.fairPriceStatus,
      fairPricePercentDiff: entity.fairPricePercentDiff,
      areaAverageRent: entity.areaAverageRent,
      alleyWidthFeet: entity.alleyWidthFeet,
      gasSupply: entity.gasSupply,
      waterloggingRisk: entity.waterloggingRisk,
      waterQuality: entity.waterQuality,
      nightSafetyRating: entity.nightSafetyRating,
      isSaved: entity.isSaved,
    );
  }
}
