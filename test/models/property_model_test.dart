import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/features/property/data/models/property_model.dart';
import 'package:rentbd_app/features/property/domain/entities/property.dart';

void main() {
  group('PropertyModel & GeoDjango DRF Compatibility', () {
    final Map<String, dynamic> sampleDrfJson = {
      'id': 'prop-dhaka-mirpur-1',
      'landlord_id': 'landlord-101',
      'landlord_name': 'Rafiqul Islam',
      'landlord_phone_masked': '+880 1712-***890',
      'landlord_is_nid_verified': true,
      'landlord_rating': 4.9,
      'title': 'Sunlit 3-Bed Family Apartment in Mirpur 10',
      'description': 'Modern flat with balcony, active line gas, and continuous WASA water.',
      'property_type': 'APARTMENT',
      'tenant_category': 'FAMILY',
      'rent_amount': 22000.0,
      'security_deposit': 44000.0,
      'service_charge': 3500.0,
      'estimated_utilities': 2200.0,
      'bedrooms': 3,
      'bathrooms': 2,
      'balconies': 2,
      'square_feet': 1250,
      'floor_level': 4,
      'total_floors': 7,
      'coordinates': {
        'type': 'Point',
        'coordinates': [90.3683, 23.8067], // [longitude, latitude] GeoDjango PostGIS format
      },
      'area_neighborhood': 'Mirpur 10',
      'full_address': 'House 42, Road 7, Block C, Mirpur 10, Dhaka',
      'images': [
        {
          'id': 'img-1',
          'image_url': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
          'room_type': 'LIVING_ROOM',
          'is_geo_tagged': true,
        },
      ],
      'has_geo_tagged_photos': true,
      'is_available': true,
      'is_owner_verified': true,
      'fair_price_status': 'GREAT_DEAL',
      'fair_price_percent_diff': -10.5,
      'area_average_rent': 24500.0,
      'alley_width_feet': 20.0,
      'gas_supply': 'LINE_GAS',
      'waterlogging_risk': 'NONE',
      'water_quality': 'EXCELLENT',
      'night_safety_rating': 4.6,
      'is_saved': false,
    };

    test('should parse DRF snake_case JSON and GeoJSON coordinates correctly', () {
      final model = PropertyModel.fromJson(sampleDrfJson);

      expect(model.id, equals('prop-dhaka-mirpur-1'));
      expect(model.landlordName, equals('Rafiqul Islam'));
      expect(model.rentAmount, equals(22000.0));
      expect(model.tenantCategory, equals(TenantCategory.family));
      expect(model.gasSupply, equals(GasSupplyType.lineGas));
      expect(model.fairPriceStatus, equals(FairPriceStatus.greatDeal));
      expect(model.latitude, closeTo(23.8067, 0.0001));
      expect(model.longitude, closeTo(90.3683, 0.0001));
      expect(model.images.length, equals(1));
      expect(model.images.first.roomType, equals(RoomType.livingRoom));
    });

    test('should map PropertyModel to domain entity seamlessly', () {
      final model = PropertyModel.fromJson(sampleDrfJson);
      final entity = model.toEntity();

      expect(entity.id, equals('prop-dhaka-mirpur-1'));
      expect(entity.areaNeighborhood, equals('Mirpur 10'));
      expect(entity.bedrooms, equals(3));
      expect(entity.fairPriceStatus, equals(FairPriceStatus.greatDeal));
      expect(entity.isOwnerVerified, isTrue);
    });

    test('should serialize back to DRF compatible JSON format', () {
      final model = PropertyModel.fromJson(sampleDrfJson);
      final json = model.toJson();

      expect(json['id'], equals('prop-dhaka-mirpur-1'));
      expect(json['rent_amount'], equals(22000.0));
      expect(json['coordinates']['type'], equals('Point'));
      expect(json['coordinates']['coordinates'], equals([90.3683, 23.8067]));
      expect(json['fair_price_status'], equals('GREAT_DEAL'));
    });

    test('should parse pending review and approved moderation statuses correctly', () {
      final pendingJson = Map<String, dynamic>.from(sampleDrfJson)
        ..['status'] = 'PENDING'
        ..['is_approved'] = false;
      final pendingModel = PropertyModel.fromJson(pendingJson);
      expect(pendingModel.approvalStatus, equals(PropertyApprovalStatus.pendingReview));
      expect(pendingModel.toEntity().isPendingReview, isTrue);
      expect(pendingModel.toEntity().isApproved, isFalse);

      final approvedJson = Map<String, dynamic>.from(sampleDrfJson)
        ..['status'] = 'ACTIVE'
        ..['is_approved'] = true;
      final approvedModel = PropertyModel.fromJson(approvedJson);
      expect(approvedModel.approvalStatus, equals(PropertyApprovalStatus.approved));
      expect(approvedModel.toEntity().isApproved, isTrue);
      expect(approvedModel.toEntity().isPendingReview, isFalse);
    });
  });
}
