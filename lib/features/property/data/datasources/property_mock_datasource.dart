import 'package:rentbd_app/core/config/app_environment.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/entities/property_operations.dart';
import '../models/property_model.dart';
import '../models/property_operations_model.dart';
import 'property_datasource.dart';

/// Rich Mock DataSource providing realistic Dhaka property listings.
class PropertyMockDataSource implements PropertyDataSource {
  final List<PropertyModel> _properties = [
    // 1. Mirpur 10 - Bachelor Male
    PropertyModel(
      id: 'prop-mirpur-01',
      landlordId: 'usr-landlord-01',
      landlordName: 'Engr. Farhan Kabir',
      landlordPhoneMasked: '+880 17•• ••••23',
      landlordIsNidVerified: true,
      landlordRating: 4.9,
      title: '2-Bed Modern Flat near Mirpur 10 Metro Station',
      description:
          'South-facing apartment with immense natural ventilation and two spacious balconies. Located just a 3-minute walk from Mirpur 10 Metro Gate 2. Bachelor-friendly with 24/7 building security and separate sub-meter electricity.',
      propertyType: PropertyType.apartment,
      tenantCategory: TenantCategory.bachelorMale,
      rentAmount: 16500.0,
      securityDeposit: 33000.0,
      serviceCharge: 2500.0,
      estimatedUtilities: 1800.0,
      bedrooms: 2,
      bathrooms: 2,
      balconies: 2,
      squareFeet: 920,
      floorLevel: 4,
      totalFloors: 7,
      latitude: 23.8069,
      longitude: 90.3686,
      areaNeighborhood: 'Mirpur 10',
      fullAddress: 'Road 14, Block C, Mirpur 10, Dhaka',
      images: const [
        PropertyImageModel(
          id: 'img-m1',
          imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          roomType: RoomType.livingRoom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-m2',
          imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800',
          roomType: RoomType.bedroom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-m3',
          imageUrl: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=800',
          roomType: RoomType.kitchen,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-m4',
          imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
          roomType: RoomType.washroom,
          isGeoTagged: true,
        ),
      ],
      hasGeoTaggedPhotos: true,
      isAvailable: true,
      isOwnerVerified: true,
      fairPriceStatus: FairPriceStatus.greatDeal,
      fairPricePercentDiff: -8.5,
      areaAverageRent: 18000.0,
      alleyWidthFeet: 22.0,
      gasSupply: GasSupplyType.lineGas,
      waterloggingRisk: WaterloggingRisk.none,
      waterQuality: WaterQuality.excellent,
      nightSafetyRating: 4.8,
      isSaved: false,
    ),

    // 2. Uttara Sector 4 - Family
    PropertyModel(
      id: 'prop-uttara-02',
      landlordId: 'usr-landlord-02',
      landlordName: 'Dr. Shahriar Rahman',
      landlordPhoneMasked: '+880 18•• ••••88',
      landlordIsNidVerified: true,
      landlordRating: 4.8,
      title: 'Spacious 3-Bed Family Apartment overlooking Park',
      description:
          'Ideal family home in quiet residential Sector 4 Uttara. Double lift, standby full generator backup, CCTV surveillance, dedicated car parking slot on ground floor, and active Titas line gas connection.',
      propertyType: PropertyType.apartment,
      tenantCategory: TenantCategory.family,
      rentAmount: 28000.0,
      securityDeposit: 56000.0,
      serviceCharge: 4000.0,
      estimatedUtilities: 2500.0,
      bedrooms: 3,
      bathrooms: 3,
      balconies: 3,
      squareFeet: 1450,
      floorLevel: 5,
      totalFloors: 9,
      latitude: 23.8681,
      longitude: 90.3982,
      areaNeighborhood: 'Uttara Sector 4',
      fullAddress: 'Road 7, Sector 4, Uttara, Dhaka',
      images: const [
        PropertyImageModel(
          id: 'img-u1',
          imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
          roomType: RoomType.livingRoom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-u2',
          imageUrl: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
          roomType: RoomType.bedroom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-u3',
          imageUrl: 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800',
          roomType: RoomType.kitchen,
          isGeoTagged: true,
        ),
      ],
      hasGeoTaggedPhotos: true,
      isAvailable: true,
      isOwnerVerified: true,
      fairPriceStatus: FairPriceStatus.fairPrice,
      fairPricePercentDiff: 1.2,
      areaAverageRent: 27500.0,
      alleyWidthFeet: 30.0,
      gasSupply: GasSupplyType.lineGas,
      waterloggingRisk: WaterloggingRisk.none,
      waterQuality: WaterQuality.excellent,
      nightSafetyRating: 4.9,
      isSaved: true,
    ),

    // 3. Gulshan 2 - Executive Luxury Flat
    PropertyModel(
      id: 'prop-gulshan-03',
      landlordId: 'usr-landlord-03',
      landlordName: 'Begum Nusrat Jahan',
      landlordPhoneMasked: '+880 19•• ••••11',
      landlordIsNidVerified: true,
      landlordRating: 5.0,
      title: 'Luxury 3-Bed Lake View Residence with Gym & Pool',
      description:
          'Prestigious Gulshan 2 diplomatic enclave. Fully imported Spanish tile finishes, central AC conduits, German fittings, 2 assigned basement parking bays, and 24-hour armed security guard post.',
      propertyType: PropertyType.apartment,
      tenantCategory: TenantCategory.family,
      rentAmount: 75000.0,
      securityDeposit: 150000.0,
      serviceCharge: 10000.0,
      estimatedUtilities: 6000.0,
      bedrooms: 3,
      bathrooms: 4,
      balconies: 3,
      squareFeet: 2200,
      floorLevel: 6,
      totalFloors: 12,
      latitude: 23.7925,
      longitude: 90.4167,
      areaNeighborhood: 'Gulshan 2',
      fullAddress: 'Road 54, Gulshan 2, Dhaka',
      images: const [
        PropertyImageModel(
          id: 'img-g1',
          imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
          roomType: RoomType.livingRoom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-g2',
          imageUrl: 'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?w=800',
          roomType: RoomType.bedroom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-g3',
          imageUrl: 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800',
          roomType: RoomType.kitchen,
          isGeoTagged: true,
        ),
      ],
      hasGeoTaggedPhotos: true,
      isAvailable: true,
      isOwnerVerified: true,
      fairPriceStatus: FairPriceStatus.greatDeal,
      fairPricePercentDiff: -12.0,
      areaAverageRent: 85000.0,
      alleyWidthFeet: 40.0,
      gasSupply: GasSupplyType.lineGas,
      waterloggingRisk: WaterloggingRisk.none,
      waterQuality: WaterQuality.excellent,
      nightSafetyRating: 5.0,
      isSaved: false,
    ),

    // 4. Dhanmondi 27 - Sublet Female
    PropertyModel(
      id: 'prop-dhanmondi-04',
      landlordId: 'usr-landlord-04',
      landlordName: 'Sabrina Mostafa',
      landlordPhoneMasked: '+880 16•• ••••45',
      landlordIsNidVerified: true,
      landlordRating: 4.7,
      title: 'Master Bed Sublet with Attached Bath & Balcony',
      description:
          'Peaceful master bedroom sublet in a polite family apartment. Exclusively for female university student or professional banker. Includes high-speed Wi-Fi, refrigerator share, and maid service.',
      propertyType: PropertyType.sublet,
      tenantCategory: TenantCategory.bachelorFemale,
      rentAmount: 8500.0,
      securityDeposit: 8500.0,
      serviceCharge: 1200.0,
      estimatedUtilities: 800.0,
      bedrooms: 1,
      bathrooms: 1,
      balconies: 1,
      squareFeet: 280,
      floorLevel: 3,
      totalFloors: 6,
      latitude: 23.7533,
      longitude: 90.3769,
      areaNeighborhood: 'Dhanmondi 27',
      fullAddress: 'Road 27 (Old), Dhanmondi, Dhaka',
      images: const [
        PropertyImageModel(
          id: 'img-d1',
          imageUrl: 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800',
          roomType: RoomType.bedroom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-d2',
          imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
          roomType: RoomType.washroom,
          isGeoTagged: true,
        ),
      ],
      hasGeoTaggedPhotos: true,
      isAvailable: true,
      isOwnerVerified: true,
      fairPriceStatus: FairPriceStatus.fairPrice,
      fairPricePercentDiff: 0.0,
      areaAverageRent: 8500.0,
      alleyWidthFeet: 20.0,
      gasSupply: GasSupplyType.lineGas,
      waterloggingRisk: WaterloggingRisk.mild,
      waterQuality: WaterQuality.adequate,
      nightSafetyRating: 4.6,
      isSaved: false,
    ),

    // 5. Bashundhara R/A Block C - Bachelor Male
    PropertyModel(
      id: 'prop-bashundhara-05',
      landlordId: 'usr-landlord-05',
      landlordName: 'Ashfaqur Rahman',
      landlordPhoneMasked: '+880 17•• ••••56',
      landlordIsNidVerified: true,
      landlordRating: 4.6,
      title: '2-Bed Bachelor Friendly Flat beside NSU Campus',
      description:
          'Directly inside Bashundhara R/A Block C. Ideal for 3-4 university students. Wide roads, bike parking, generator, and continuous WASA water supply. No restrictive night curfew.',
      propertyType: PropertyType.apartment,
      tenantCategory: TenantCategory.bachelorMale,
      rentAmount: 22000.0,
      securityDeposit: 44000.0,
      serviceCharge: 3000.0,
      estimatedUtilities: 2200.0,
      bedrooms: 2,
      bathrooms: 2,
      balconies: 2,
      squareFeet: 1050,
      floorLevel: 2,
      totalFloors: 6,
      latitude: 23.8162,
      longitude: 90.4262,
      areaNeighborhood: 'Bashundhara R/A',
      fullAddress: 'Road 5, Block C, Bashundhara R/A, Dhaka',
      images: const [
        PropertyImageModel(
          id: 'img-b1',
          imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
          roomType: RoomType.livingRoom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-b2',
          imageUrl: 'https://images.unsplash.com/photo-1540518614846-7ede433c4b4d?w=800',
          roomType: RoomType.bedroom,
          isGeoTagged: true,
        ),
      ],
      hasGeoTaggedPhotos: true,
      isAvailable: true,
      isOwnerVerified: true,
      fairPriceStatus: FairPriceStatus.fairPrice,
      fairPricePercentDiff: -2.1,
      areaAverageRent: 22500.0,
      alleyWidthFeet: 25.0,
      gasSupply: GasSupplyType.cylinder,
      waterloggingRisk: WaterloggingRisk.none,
      waterQuality: WaterQuality.excellent,
      nightSafetyRating: 4.9,
      isSaved: false,
    ),

    // 6. Mohammadpur Tajmahal Road - Family
    PropertyModel(
      id: 'prop-mohammadpur-06',
      landlordId: 'usr-landlord-06',
      landlordName: 'Hazi Moinuddin Ahmed',
      landlordPhoneMasked: '+880 18•• ••••33',
      landlordIsNidVerified: true,
      landlordRating: 4.5,
      title: 'South Facing 2-Bed Family Home on Tajmahal Road',
      description:
          'Located near Town Hall market. Active pipeline gas, high water pressure throughout the year, and peaceful family building environment with elevator service.',
      propertyType: PropertyType.apartment,
      tenantCategory: TenantCategory.family,
      rentAmount: 19500.0,
      securityDeposit: 39000.0,
      serviceCharge: 2800.0,
      estimatedUtilities: 1800.0,
      bedrooms: 2,
      bathrooms: 2,
      balconies: 2,
      squareFeet: 980,
      floorLevel: 4,
      totalFloors: 7,
      latitude: 23.7661,
      longitude: 90.3587,
      areaNeighborhood: 'Mohammadpur',
      fullAddress: 'Tajmahal Road, Mohammadpur, Dhaka',
      images: const [
        PropertyImageModel(
          id: 'img-mp1',
          imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
          roomType: RoomType.livingRoom,
          isGeoTagged: true,
        ),
        PropertyImageModel(
          id: 'img-mp2',
          imageUrl: 'https://images.unsplash.com/photo-1540518614846-7ede433c4b4d?w=800',
          roomType: RoomType.bedroom,
          isGeoTagged: true,
        ),
      ],
      hasGeoTaggedPhotos: true,
      isAvailable: true,
      isOwnerVerified: true,
      fairPriceStatus: FairPriceStatus.fairPrice,
      fairPricePercentDiff: 0.5,
      areaAverageRent: 19400.0,
      alleyWidthFeet: 20.0,
      gasSupply: GasSupplyType.lineGas,
      waterloggingRisk: WaterloggingRisk.none,
      waterQuality: WaterQuality.adequate,
      nightSafetyRating: 4.4,
      isSaved: false,
    ),
  ];

  @override
  Future<List<PropertyModel>> getProperties({
    PropertyFilter? filter,
    int page = 1,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);

    var result = List<PropertyModel>.from(_properties);

    if (filter != null) {
      if (filter.area != null && filter.area!.isNotEmpty && filter.area != 'All Dhaka') {
        result = result
            .where((p) => p.areaNeighborhood.toLowerCase().contains(filter.area!.toLowerCase()))
            .toList();
      }

      if (filter.tenantCategory != null && filter.tenantCategory != TenantCategory.any) {
        result = result.where((p) {
          if (filter.tenantCategory == TenantCategory.family) {
            return p.tenantCategory == TenantCategory.family || p.tenantCategory == TenantCategory.any;
          }
          if (filter.tenantCategory == TenantCategory.bachelorMale ||
              filter.tenantCategory == TenantCategory.bachelorFemale) {
            return p.tenantCategory == TenantCategory.bachelorMale ||
                p.tenantCategory == TenantCategory.bachelorFemale ||
                p.tenantCategory == TenantCategory.any;
          }
          return p.tenantCategory == filter.tenantCategory;
        }).toList();
      }

      if (filter.propertyType != null) {
        result = result.where((p) => p.propertyType == filter.propertyType).toList();
      }

      if (filter.minRent != null) {
        result = result.where((p) => p.rentAmount >= filter.minRent!).toList();
      }

      if (filter.maxRent != null) {
        result = result.where((p) => p.rentAmount <= filter.maxRent!).toList();
      }

      if (filter.bedrooms != null) {
        result = result.where((p) => p.bedrooms >= filter.bedrooms!).toList();
      }

      if (filter.hasGeoTaggedOnly) {
        result = result.where((p) => p.hasGeoTaggedPhotos).toList();
      }

      if (filter.isGreatDealOnly) {
        result = result.where((p) => p.fairPriceStatus == FairPriceStatus.greatDeal).toList();
      }

      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final query = filter.searchQuery!.trim().toLowerCase();
        result = result.where((p) {
          return p.title.toLowerCase().contains(query) ||
              p.areaNeighborhood.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query);
        }).toList();
      }
    }

    return result;
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final match = _properties.firstWhere(
      (p) => p.id == id,
      orElse: () => throw ServerException(message: 'Property with ID "$id" not found'),
    );
    return match;
  }

  @override
  Future<bool> toggleSaveProperty(String propertyId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      final current = _properties[idx];
      _properties[idx] = PropertyModel(
        id: current.id,
        landlordId: current.landlordId,
        landlordName: current.landlordName,
        landlordPhoneMasked: current.landlordPhoneMasked,
        landlordIsNidVerified: current.landlordIsNidVerified,
        landlordRating: current.landlordRating,
        title: current.title,
        description: current.description,
        propertyType: current.propertyType,
        tenantCategory: current.tenantCategory,
        rentAmount: current.rentAmount,
        securityDeposit: current.securityDeposit,
        serviceCharge: current.serviceCharge,
        estimatedUtilities: current.estimatedUtilities,
        bedrooms: current.bedrooms,
        bathrooms: current.bathrooms,
        balconies: current.balconies,
        squareFeet: current.squareFeet,
        floorLevel: current.floorLevel,
        totalFloors: current.totalFloors,
        latitude: current.latitude,
        longitude: current.longitude,
        areaNeighborhood: current.areaNeighborhood,
        fullAddress: current.fullAddress,
        images: current.images,
        hasGeoTaggedPhotos: current.hasGeoTaggedPhotos,
        isAvailable: current.isAvailable,
        isOwnerVerified: current.isOwnerVerified,
        fairPriceStatus: current.fairPriceStatus,
        fairPricePercentDiff: current.fairPricePercentDiff,
        areaAverageRent: current.areaAverageRent,
        alleyWidthFeet: current.alleyWidthFeet,
        gasSupply: current.gasSupply,
        waterloggingRisk: current.waterloggingRisk,
        waterQuality: current.waterQuality,
        nightSafetyRating: current.nightSafetyRating,
        isSaved: !current.isSaved,
      );
      return _properties[idx].isSaved;
    }
    return false;
  }

  @override
  Future<List<PropertyModel>> getSavedProperties() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return _properties.where((p) => p.isSaved).toList();
  }

  @override
  Future<List<PropertyModel>> naturalLanguageSearch(String query) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final q = query.toLowerCase();

    // AI rule parsing logic for natural voice/text searches in Bangla/Banglish/English
    return _properties.where((p) {
      if (q.contains('bachelor') || q.contains('ব্যাচেলর')) {
        if (p.tenantCategory == TenantCategory.family) return false;
      }
      if (q.contains('family') || q.contains('ফ্যামিলি')) {
        if (p.tenantCategory == TenantCategory.bachelorMale) return false;
      }
      if (q.contains('sublet') || q.contains('সাবলেট')) {
        if (p.propertyType != PropertyType.sublet) return false;
      }
      if (q.contains('mirpur') || q.contains('মিরপুর')) {
        if (!p.areaNeighborhood.toLowerCase().contains('mirpur')) return false;
      }
      if (q.contains('uttara') || q.contains('উত্তরা')) {
        if (!p.areaNeighborhood.toLowerCase().contains('uttara')) return false;
      }
      if (q.contains('dhanmondi') || q.contains('ধানমন্ডি')) {
        if (!p.areaNeighborhood.toLowerCase().contains('dhanmondi')) return false;
      }
      if (q.contains('gulshan') || q.contains('গুলশান')) {
        if (!p.areaNeighborhood.toLowerCase().contains('gulshan')) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<PropertyModel> createProperty(Map<String, dynamic> propertyData) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final newProp = PropertyModel(
      id: 'prop-new-${DateTime.now().millisecondsSinceEpoch}',
      landlordId: 'usr-landlord-curr',
      landlordName: 'Current User',
      landlordPhoneMasked: '+880 18•• ••••88',
      title: propertyData['title'] as String? ?? 'Newly Added Flat',
      description: propertyData['description'] as String? ?? '',
      propertyType: PropertyType.apartment,
      tenantCategory: TenantCategory.family,
      rentAmount: (propertyData['rent_amount'] as num?)?.toDouble() ??
          (propertyData['rent'] as num?)?.toDouble() ??
          25000.0,
      securityDeposit: (propertyData['security_deposit'] as num?)?.toDouble() ?? 50000.0,
      serviceCharge: (propertyData['service_charge'] as num?)?.toDouble() ?? 3500.0,
      estimatedUtilities: 2500.0,
      bedrooms: propertyData['bedrooms'] as int? ?? 3,
      bathrooms: propertyData['bathrooms'] as int? ?? 2,
      balconies: propertyData['balconies'] as int? ?? 1,
      squareFeet: propertyData['square_feet'] as int? ?? propertyData['size_sqft'] as int? ?? 1200,
      floorLevel: propertyData['floor_level'] as int? ?? 4,
      totalFloors: propertyData['total_floors'] as int? ?? 7,
      latitude: (propertyData['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (propertyData['longitude'] as num?)?.toDouble() ?? 90.4125,
      areaNeighborhood: propertyData['area_neighborhood'] as String? ?? propertyData['area'] as String? ?? 'Mirpur 10',
      fullAddress: propertyData['full_address'] as String? ?? propertyData['address'] as String? ?? 'Dhaka, Bangladesh',
      images: (propertyData['photos'] is List && (propertyData['photos'] as List).isNotEmpty)
          ? (propertyData['photos'] as List)
              .map((p) => PropertyImageModel(
                    id: 'img-${DateTime.now().millisecondsSinceEpoch}-${p.hashCode}',
                    imageUrl: p.toString(),
                    roomType: RoomType.livingRoom,
                  ))
              .toList()
          : const [
              PropertyImageModel(
                id: 'new-img-1',
                imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
                roomType: RoomType.livingRoom,
              ),
            ],
      fairPriceStatus: FairPriceStatus.fairPrice,
      isAvailable: false,
      approvalStatus: PropertyApprovalStatus.pendingReview,
      isOwnerVerified: false,
    );
    _properties.insert(0, newProp);
    return newProp;
  }

  @override
  Future<PropertyImageModel> uploadPropertyPhoto(
    String propertyId,
    String filePath, {
    String tag = 'LIVING',
    bool isCover = false,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    RoomType room = RoomType.livingRoom;
    switch (tag.toUpperCase()) {
      case 'BEDROOM':
        room = RoomType.bedroom;
        break;
      case 'KITCHEN':
        room = RoomType.kitchen;
        break;
      case 'WASHROOM':
      case 'BATHROOM':
        room = RoomType.washroom;
        break;
      case 'BALCONY':
        room = RoomType.balcony;
        break;
      case 'EXTERIOR':
        room = RoomType.exterior;
        break;
    }

    final newImg = PropertyImageModel(
      id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: filePath,
      roomType: room,
      isGeoTagged: true,
      capturedAt: DateTime.now(),
    );

    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      final current = _properties[idx];
      final updated = List<PropertyImageModel>.from(current.images)..add(newImg);
      _properties[idx] = PropertyModel.fromEntity(
        current.toEntity().copyWith(
          images: updated.map((m) => m.toEntity()).toList(),
          hasGeoTaggedPhotos: true,
        ),
      );
    }
    return newImg;
  }

  @override
  Future<bool> toggleVault(String propertyId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      final current = _properties[idx];
      _properties[idx] = PropertyModel.fromEntity(
        current.toEntity().copyWith(
          isAvailable: !current.isAvailable,
        ),
      );
      return !_properties[idx].isAvailable;
    }
    return false;
  }

  @override
  Future<PropertyModel> updatePropertyStatus(String propertyId, String status) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      final current = _properties[idx];
      final isApproved = status.toLowerCase() == 'active' || status.toLowerCase() == 'approved';
      final isRejected = status.toLowerCase() == 'rejected';
      final newStatus = isApproved
          ? PropertyApprovalStatus.approved
          : isRejected
              ? PropertyApprovalStatus.rejected
              : PropertyApprovalStatus.pendingReview;

      final updated = PropertyModel.fromEntity(
        current.toEntity().copyWith(
          approvalStatus: newStatus,
          isOwnerVerified: isApproved ? true : current.isOwnerVerified,
          isAvailable: isApproved ? true : false,
        ),
      );
      _properties[idx] = updated;
      return updated;
    }
    throw ServerException(message: 'Property not found in mock store');
  }

  @override
  Future<MoveInEstimateModel> calculateMoveIn(
    String propertyId, {
    bool includeTruck = true,
    bool includeLabour = true,
    String truckSize = 'medium',
    double distanceKm = 8,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final prop = _properties.firstWhere(
      (p) => p.id == propertyId,
      orElse: () => _properties.first,
    );
    final double truckCost = includeTruck ? (truckSize == 'large' ? 5000.0 : 3500.0) : 0.0;
    final double labourCost = includeLabour ? 2000.0 : 0.0;
    final double total = prop.rentAmount + prop.securityDeposit + prop.serviceCharge + truckCost + labourCost;

    return MoveInEstimateModel(
      firstMonthRent: prop.rentAmount,
      securityDeposit: prop.securityDeposit,
      serviceCharge: prop.serviceCharge,
      movingTruckCost: truckCost,
      labourCost: labourCost,
      totalEstimatedCashNeeded: total,
      currency: 'BDT',
      breakdownNotes: 'Estimated based on intra-Dhaka standard moving rates.',
    );
  }

  @override
  Future<PropertyComparisonModel> compareProperties(List<String> propertyIds) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final selected = _properties.where((p) => propertyIds.contains(p.id)).toList();
    if (selected.isEmpty) {
      selected.addAll(_properties.take(2));
    }
    final diff = selected.length >= 2 ? (selected[0].rentAmount - selected[1].rentAmount).abs() : 0.0;
    final cheaper = (selected.length >= 2 && selected[1].rentAmount < selected[0].rentAmount)
        ? selected[1].id
        : selected.first.id;

    return PropertyComparisonModel(
      properties: selected,
      rentDifference: diff,
      cheaperPropertyId: cheaper,
      gasComparison: {'has_gas_count': selected.where((p) => p.gasSupply == GasSupplyType.lineGas).length},
      generatorComparison: {'generator_backup': 'Available in selected properties'},
    );
  }

  @override
  Future<List<PropertyModel>> drawSearch(List<Map<String, double>> polygon) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return _properties.take(4).toList();
  }

  @override
  Future<CommuteEstimateModel> calculateCommute(
    String propertyId,
    String destinationArea,
    String commuteMode,
  ) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return CommuteEstimateModel(
      commuteTimeMinutes: commuteMode == 'metro' ? 28 : 45,
      mode: commuteMode,
      nearestStation: 'Mirpur 10 Metro Station',
      stationDistanceMeters: 450,
      trafficDelayPeakHoursMinutes: commuteMode == 'metro' ? 5 : 20,
    );
  }

  @override
  Future<NearbyEssentialsModel> getNearbyEssentials(String propertyId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return const NearbyEssentialsModel(
      metroStations: [NearbyPlace(name: 'Mirpur 10 Metro Station', distanceMeters: 320)],
      busStops: [NearbyPlace(name: 'Golchokkor Bus Stand', distanceMeters: 180)],
      mosques: [NearbyPlace(name: 'Baitul Falah Jame Masjid', distanceMeters: 120)],
      bazaars: [NearbyPlace(name: 'Mirpur 10 Kacha Bazaar', distanceMeters: 450)],
      hospitals: [NearbyPlace(name: 'Al Helal Hospital', distanceMeters: 600)],
      pharmacies: [NearbyPlace(name: 'Lazz Pharma', distanceMeters: 200)],
    );
  }

  @override
  Future<FairRentAnalysisModel> getFairRentMeter(String propertyId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final prop = _properties.firstWhere(
      (p) => p.id == propertyId,
      orElse: () => _properties.first,
    );
    final avg = prop.areaAverageRent;
    final diff = ((prop.rentAmount - avg) / avg) * 100;
    final verdict = diff < -5 ? 'Great Deal' : (diff > 5 ? 'Overpriced' : 'Fair Price');

    return FairRentAnalysisModel(
      propertyId: prop.id,
      currentRent: prop.rentAmount,
      areaAverageRent: avg,
      verdict: verdict,
      percentageDifference: diff,
      ratingScore: 4.5,
      insight: 'This flat is priced at median rate for ${prop.areaNeighborhood}.',
    );
  }

  @override
  Future<RentAgreementModel> generateAgreement(Map<String, dynamic> agreementData) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final landlordName = agreementData['landlord_name'] ?? 'Kamal Hossain';
    final tenantName = agreementData['tenant_name'] ?? 'Rahim Ahmed';
    final rent = agreementData['monthly_rent'] ?? 25000;
    final deposit = agreementData['security_deposit'] ?? 50000;

    return RentAgreementModel(
      agreementTitle: 'Residential Tenancy Agreement (বাড়ি ভাড়া চুক্তিপত্র)',
      fullLegalMarkdown: '''# গণপ্রজাতন্ত্রী বাংলাদেশ
## বাড়ি ভাড়া চুক্তিপত্র

**১ম পক্ষ (মালিক):** $landlordName  
**২য় পক্ষ (ভাড়াটিয়া):** $tenantName  

১. মাসিক বাড়ি ভাড়া ৳$rent নির্ধারণ করা হইল।  
২. জামানত বাবদ ৳$deposit ১ম পক্ষকে প্রদান করা হইল।  
৩. উভয় পক্ষ গণপ্রজাতন্ত্রী বাংলাদেশের বাড়ি ভাড়া নিয়ন্ত্রণ আইনের ধারা মানিয়া চলিতে বাধ্য থাকিবেন।  
''',
      generatedAt: DateTime.now(),
      success: true,
    );
  }

  @override
  Future<List<AreaHeatmapItemModel>> getDemandSupplyHeatmap() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return const [
      AreaHeatmapItemModel(
        area: 'Mirpur 10',
        latitude: 23.8069,
        longitude: 90.3687,
        searchDemandIndex: 88,
        activeListingsCount: 14,
        pressureRatio: 6.28,
        marketState: 'High Tenant Demand',
      ),
      AreaHeatmapItemModel(
        area: 'Bashundhara R/A',
        latitude: 23.8151,
        longitude: 90.4255,
        searchDemandIndex: 95,
        activeListingsCount: 22,
        pressureRatio: 4.31,
        marketState: 'Balanced',
      ),
      AreaHeatmapItemModel(
        area: 'Uttara Sector 11',
        latitude: 23.8759,
        longitude: 90.3795,
        searchDemandIndex: 78,
        activeListingsCount: 18,
        pressureRatio: 4.33,
        marketState: 'Balanced',
      ),
      AreaHeatmapItemModel(
        area: 'Dhanmondi',
        latitude: 23.7461,
        longitude: 90.3742,
        searchDemandIndex: 92,
        activeListingsCount: 8,
        pressureRatio: 11.5,
        marketState: 'High Tenant Demand',
      ),
    ];
  }
}

