import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/features/auth/data/models/user_profile_model.dart';
import 'package:rentbd_app/features/auth/domain/entities/user_profile.dart';

void main() {
  group('UserProfileModel DRF Serialization Tests', () {
    test('should parse DRF tenant_profile nested JSON correctly', () {
      final json = {
        'id': 'c1f73620-8bfa-48b2-b43e-f1cf6c2323a1',
        'phone_number': '+8801712345678',
        'full_name': 'Rahim Ahmed',
        'email': 'rahim@example.com',
        'role': 'tenant',
        'avatar': null,
        'avatar_url': 'https://example.com/avatar.jpg',
        'is_phone_verified': true,
        'tenant_profile': {
          'occupation': 'Software Engineer',
          'workplace': 'Brain Station 23',
          'nid_status': 'verified',
          'nid_number': '19922692019000123',
          'family_members_count': 3,
        },
        'landlord_profile': null,
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 'c1f73620-8bfa-48b2-b43e-f1cf6c2323a1');
      expect(model.phoneNumber, '+8801712345678');
      expect(model.fullName, 'Rahim Ahmed');
      expect(model.role, UserRole.tenant);
      expect(model.occupation, 'Software Engineer');
      expect(model.workplace, 'Brain Station 23');
      expect(model.nidNumber, '19922692019000123');
      expect(model.familySize, 3);
      expect(model.kycStatus, KycStatus.verified);
      expect(model.isNidVerified, true);
      expect(model.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should parse DRF landlord_profile nested JSON correctly', () {
      final json = {
        'id': 'a90f3411-9fa2-47e1-884c-3e61c304859a',
        'phone_number': '+8801812345678',
        'full_name': 'Kamal Hossain Chowdhury',
        'email': 'kamal@example.com',
        'role': 'landlord',
        'tenant_profile': null,
        'landlord_profile': {
          'total_properties': 5,
          'bkash_merchant_number': '01711000000',
        },
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 'a90f3411-9fa2-47e1-884c-3e61c304859a');
      expect(model.role, UserRole.landlord);
      expect(model.completedRentals, 5);
    });

    test('should map UserProfileModel to UserProfile domain entity', () {
      const model = UserProfileModel(
        id: 'user-001',
        phoneNumber: '+8801711223344',
        fullName: 'Sadia Islam',
        role: UserRole.tenant,
        email: 'sadia@gmail.com',
        occupation: 'Doctor',
        workplace: 'Dhaka Medical College',
        familySize: 2,
        nidNumber: '19951234567890123',
        isNidVerified: true,
        kycStatus: KycStatus.verified,
      );

      final entity = model.toEntity();

      expect(entity.id, 'user-001');
      expect(entity.phoneNumber, '+8801711223344');
      expect(entity.fullName, 'Sadia Islam');
      expect(entity.role, UserRole.tenant);
      expect(entity.isTenant, true);
      expect(entity.isLandlord, false);
      expect(entity.isKycCompleted, true);
      expect(entity.occupation, 'Doctor');
    });

    test('should serialize UserProfileModel back to DRF JSON format', () {
      const model = UserProfileModel(
        id: 'usr-123',
        phoneNumber: '+8801811223344',
        fullName: 'Rafiqul Islam',
        role: UserRole.landlord,
        email: 'rafiq@gmail.com',
        occupation: 'Business Owner',
        workplace: 'Gulshan 2',
        familySize: 4,
        nidNumber: '19801234567890123',
        isNidVerified: true,
        kycStatus: KycStatus.verified,
      );

      final json = model.toJson();

      expect(json['id'], 'usr-123');
      expect(json['phone_number'], '+8801811223344');
      expect(json['role'], 'landlord');
      expect(json['tenant_profile'], isA<Map<String, dynamic>>());
      expect(json['tenant_profile']['occupation'], 'Business Owner');
      expect(json['landlord_profile'], isA<Map<String, dynamic>>());
    });

    test('should safely parse DRF response when user field is an integer ID', () {
      final json = {
        'id': 105,
        'user': 42, // Integer ForeignKey from Django
        'phone_number': '01712345678',
        'full_name': 'Hasan Mahmud',
        'role': 'landlord',
        'is_nid_verified': true,
        'nid_number': '19852691234567890',
        'present_address': 'Dhanmondi 27, Dhaka',
        'emergency_contact': '01911223344',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, '105');
      expect(model.fullName, 'Hasan Mahmud');
      expect(model.role, UserRole.landlord);
      expect(model.isNidVerified, true);
      expect(model.kycStatus, KycStatus.verified);
      expect(model.toEntity().isKycCompleted, true);
      expect(model.presentAddress, 'Dhanmondi 27, Dhaka');
      expect(model.emergencyContact, '01911223344');
    });

    test('should parse DRF response wrapped in data wrapper with string booleans', () {
      final json = {
        'data': {
          'id': 'uuid-777',
          'phone_number': '01812345678',
          'full_name': 'Akbar Ali',
          'role': 'landlord',
          'is_verified': 'true',
          'kyc_status': 'completed',
          'nid_number': '1234567890',
        }
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 'uuid-777');
      expect(model.fullName, 'Akbar Ali');
      expect(model.role, UserRole.landlord);
      expect(model.isNidVerified, true);
      expect(model.kycStatus, KycStatus.verified);
      expect(model.toEntity().isKycCompleted, true);
    });

    test('should recognize verified status when 10-digit smart NID is present', () {
      final json = {
        'id': 'landlord-smart-nid',
        'phone_number': '01912345678',
        'full_name': 'Shamsul Huda',
        'role': 'landlord',
        'nid_number': '5951234567', // 10 digit Smart NID
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.nidNumber, '5951234567');
      expect(model.isNidVerified, true);
      expect(model.kycStatus, KycStatus.verified);
      expect(model.toEntity().isKycCompleted, true);
    });
  });
}
