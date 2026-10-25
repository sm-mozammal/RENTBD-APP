import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import 'package:rentbd_app/features/communication_ledger/data/datasources/chat_mock_datasource.dart';
import 'package:rentbd_app/features/communication_ledger/data/datasources/chat_remote_datasource.dart';
import 'package:rentbd_app/features/communication_ledger/data/datasources/ledger_mock_datasource.dart';
import 'package:rentbd_app/features/communication_ledger/data/datasources/ledger_remote_datasource.dart';
import 'package:rentbd_app/features/communication_ledger/data/repositories/chat_repository_impl.dart';
import 'package:rentbd_app/features/communication_ledger/data/repositories/ledger_repository_impl.dart';
import 'package:rentbd_app/features/location/data/datasources/insight_mock_datasource.dart';
import 'package:rentbd_app/features/location/data/datasources/insight_remote_datasource.dart';
import 'package:rentbd_app/features/location/data/repositories/insight_repository_impl.dart';
import 'package:rentbd_app/features/property/data/datasources/property_mock_datasource.dart';
import 'package:rentbd_app/features/property/data/datasources/property_remote_datasource.dart';
import 'package:rentbd_app/features/property/data/repositories/property_repository_impl.dart';
import 'package:rentbd_app/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:rentbd_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rentbd_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rentbd_app/features/auth/domain/entities/user_profile.dart';
import 'package:rentbd_app/features/visit/data/datasources/visit_mock_datasource.dart';
import 'package:rentbd_app/features/visit/data/datasources/visit_remote_datasource.dart';
import 'package:rentbd_app/features/visit/data/repositories/visit_repository_impl.dart';
import 'package:rentbd_app/features/visit/domain/entities/visit_booking.dart';

void main() {
  setUp(() {
    AppEnvironment.mockDelay = Duration.zero;
    AppEnvironment.useMockData = true;
  });

  group('Clean Architecture Zero-Rework Contract Verification', () {
    final dioClient = DioClient();

    test('PropertyRepository returns entities with AI & Move-In tools in mock mode', () async {
      final repo = PropertyRepositoryImpl(
        mockDataSource: PropertyMockDataSource(),
        remoteDataSource: PropertyRemoteDataSource(dioClient),
      );

      final list = await repo.getProperties();
      expect(list.isNotEmpty, true);

      final moveIn = await repo.calculateMoveIn(list.first.id);
      expect(moveIn.firstMonthRent > 0, true);
      expect(moveIn.totalEstimatedCashNeeded > 0, true);

      final fairRent = await repo.getFairRentMeter(list.first.id);
      expect(fairRent.verdict.isNotEmpty, true);

      final heatmap = await repo.getDemandSupplyHeatmap();
      expect(heatmap.isNotEmpty, true);
    });

    test('VisitRepository books visits and retrieves screening inbox seamlessly', () async {
      final repo = VisitRepositoryImpl(
        mockDataSource: VisitMockDataSource(),
        remoteDataSource: VisitRemoteDataSource(dioClient),
      );

      final booking = await repo.bookVisit(
        propertyId: 'prop-mirpur-01',
        scheduledDate: '2026-10-30',
        timeSlot: '3:00 PM - 4:00 PM',
        visitType: VisitType.inPerson,
      );

      expect(booking.id.isNotEmpty, true);
      expect(booking.status, VisitStatus.pending);

      final inbox = await repo.getLandlordScreeningInbox();
      expect(inbox.isNotEmpty, true);
      expect(inbox.first.tenant?.isNidVerified, true);
    });

    test('LedgerRepository creates contracts and bills with zero UI impact', () async {
      final repo = LedgerRepositoryImpl(
        mockDataSource: LedgerMockDataSource(),
        remoteDataSource: LedgerRemoteDataSource(dioClient),
      );

      final bills = await repo.getBills();
      expect(bills.isNotEmpty, true);

      final receipt = await repo.getReceipt(bills.first.id);
      expect(receipt.receiptNumber.isNotEmpty, true);
      expect(receipt.totalPaid > 0, true);
    });

    test('ChatRepository loads rooms, sends messages and generates Agora tokens', () async {
      final repo = ChatRepositoryImpl(
        mockDataSource: ChatMockDataSource(),
        remoteDataSource: ChatRemoteDataSource(dioClient),
      );

      final rooms = await repo.getRooms();
      expect(rooms.isNotEmpty, true);

      final messages = await repo.getMessages(rooms.first.id);
      expect(messages.isNotEmpty, true);

      final sent = await repo.sendMessage(rooms.first.id, 'Is the flat available?');
      expect(sent.message, 'Is the flat available?');

      final callToken = await repo.getCallToken(rooms.first.id);
      expect(callToken.rtcToken.isNotEmpty, true);
      expect(callToken.channelName.isNotEmpty, true);
    });

    test('InsightRepository provides area insights and resident reviews', () async {
      final repo = InsightRepositoryImpl(
        mockDataSource: InsightMockDataSource(),
        remoteDataSource: InsightRemoteDataSource(dioClient),
      );

      final insight = await repo.getAreaInsight('mirpur_10');
      expect(insight.area.isNotEmpty, true);
      expect(insight.waterloggingSummary, 'low');
      expect(insight.gasPressureAvg, 4.2);
      expect(insight.residentReviews.isNotEmpty, true);
    });

    test('AuthRepository authenticates, switches roles, and submits KYC seamlessly', () async {
      final repo = AuthRepositoryImpl(
        mockDataSource: AuthMockDataSource(),
        remoteDataSource: AuthRemoteDataSource(dioClient),
      );

      final otpSent = await repo.sendOtp('+8801712345678');
      expect(otpSent, true);

      final user = await repo.verifyOtp('+8801712345678', '123456', role: UserRole.tenant);
      expect(user.phoneNumber, '+8801712345678');
      expect(user.isTenant, true);

      final registered = await repo.register(
        fullName: 'New User',
        phoneNumber: '+8801912345678',
        email: 'new@example.com',
        password: 'password123',
        role: UserRole.landlord,
      );
      expect(registered.fullName, 'New User');
      expect(registered.isLandlord, true);

      final kycUser = await repo.submitKyc(
        nidNumber: '19901234567890123',
        presentAddress: 'Dhanmondi, Dhaka',
        emergencyContact: '+8801811223344',
      );
      expect(kycUser.isKycCompleted, true);

      final switched = await repo.switchRole(UserRole.landlord);
      expect(switched.isLandlord, true);
    });
  });
}
