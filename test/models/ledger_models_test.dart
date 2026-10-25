import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/features/communication_ledger/data/models/rent_bill_model.dart';
import 'package:rentbd_app/features/communication_ledger/data/models/rent_receipt_model.dart';
import 'package:rentbd_app/features/communication_ledger/data/models/tenancy_contract_model.dart';

void main() {
  group('Ledger Models DRF JSON Serialization', () {
    test('should parse DRF rent bill JSON correctly', () {
      final json = {
        'id': 'bill-uuid-123',
        'billing_month': 'November 2026',
        'rent_amount': 25000,
        'electricity_bill': 1800,
        'gas_bill': 1080,
        'water_bill': 500,
        'service_charge': 3500,
        'total_amount': 31880,
        'status': 'unpaid',
        'due_date': '2026-11-10',
      };

      final model = RentBillModel.fromJson(json);

      expect(model.id, 'bill-uuid-123');
      expect(model.billingMonth, 'November 2026');
      expect(model.rentAmount, 25000.0);
      expect(model.electricityBill, 1800.0);
      expect(model.gasBill, 1080.0);
      expect(model.waterBill, 500.0);
      expect(model.serviceCharge, 3500.0);
      expect(model.totalAmount, 31880.0);
      expect(model.status, 'unpaid');

      final entity = model.toEntity();
      expect(entity.isPaid, false);
      expect(entity.totalAmount, 31880.0);
    });

    test('should parse DRF digital rent receipt JSON correctly', () {
      final json = {
        'receipt_number': 'REC-202611-4B92',
        'property_title': 'Modern 3-BHK Flat in Bashundhara R/A Block D',
        'flat_number': '4B',
        'tenant_name': 'Rahim Ahmed',
        'landlord_name': 'Kamal Hossain',
        'billing_month': 'November 2026',
        'itemized_breakdown': {
          'rent': 25000,
          'electricity': 1800,
          'gas': 1080,
          'water': 500,
          'service_charge': 3500,
        },
        'total_paid': 31880,
        'payment_method': 'bKash',
        'transaction_id': 'BK89239102',
        'paid_at': '2026-10-21T00:00:00Z',
        'digital_signature_hash': 'sha256:e3b0c442...',
      };

      final model = RentReceiptModel.fromJson(json);

      expect(model.receiptNumber, 'REC-202611-4B92');
      expect(model.totalPaid, 31880.0);
      expect(model.paymentMethod, 'bKash');
      expect(model.transactionId, 'BK89239102');
      expect(model.tenantName, 'Rahim Ahmed');
      expect(model.landlordName, 'Kamal Hossain');

      final entity = model.toEntity();
      expect(entity.receiptNumber, 'REC-202611-4B92');
      expect(entity.totalPaid, 31880.0);
    });

    test('should parse DRF tenancy contract JSON correctly', () {
      final json = {
        'id': 'contract-uuid-99',
        'property': '4b7e8d02-15d9-4cf5-992a-fa13de5518b2',
        'tenant_phone': '+8801712345678',
        'flat_number': '4B',
        'monthly_rent': 25000,
        'service_charge': 3500,
        'security_deposit': 50000,
        'contract_start_date': '2026-11-01',
        'contract_end_date': '2027-10-31',
        'is_active': true,
      };

      final model = TenancyContractModel.fromJson(json);

      expect(model.id, 'contract-uuid-99');
      expect(model.tenantPhone, '+8801712345678');
      expect(model.monthlyRent, 25000.0);
      expect(model.securityDeposit, 50000.0);
      expect(model.isActive, true);

      final entity = model.toEntity();
      expect(entity.id, 'contract-uuid-99');
      expect(entity.flatNumber, '4B');
    });
  });
}
