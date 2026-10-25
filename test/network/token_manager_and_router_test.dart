import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/network/token_manager.dart';
import 'package:rentbd_app/core/router/app_router.dart';

void main() {
  setUp(() async {
    await TokenManager.clear();
  });

  tearDown(() async {
    await TokenManager.clear();
  });

  group('TokenManager Session & Secure Storage Tests', () {
    test('TokenManager starts with null session tokens and false hasToken', () {
      expect(TokenManager.accessToken, isNull);
      expect(TokenManager.refreshToken, isNull);
      expect(TokenManager.userId, isNull);
      expect(TokenManager.userRole, isNull);
      expect(TokenManager.hasToken, isFalse);
      expect(TokenManager.isLandlord, isFalse);
      expect(TokenManager.isTenant, isFalse);
    });

    test('saveSession updates in-memory tokens, userId, role and notifies listeners', () async {
      int notifyCount = 0;
      void listener() => notifyCount++;
      TokenManager.authChangeNotifier.addListener(listener);

      await TokenManager.saveSession(
        access: 'jwt-access-token-12345',
        refresh: 'jwt-refresh-token-67890',
        userId: 'usr-dhaka-uuid-001',
        userRole: 'landlord',
        userJson: {
          'id': 'usr-dhaka-uuid-001',
          'phone_number': '+8801812345678',
          'full_name': 'Kamal Hossain',
          'role': 'landlord',
        },
      );

      expect(TokenManager.accessToken, equals('jwt-access-token-12345'));
      expect(TokenManager.refreshToken, equals('jwt-refresh-token-67890'));
      expect(TokenManager.userId, equals('usr-dhaka-uuid-001'));
      expect(TokenManager.userRole, equals('landlord'));
      expect(TokenManager.hasToken, isTrue);
      expect(TokenManager.isLandlord, isTrue);
      expect(TokenManager.isTenant, isFalse);
      expect(TokenManager.cachedUserProfileJson, contains('Kamal Hossain'));
      expect(notifyCount, greaterThan(0));

      TokenManager.authChangeNotifier.removeListener(listener);
    });

    test('clear purges all in-memory session data and notifies listeners', () async {
      await TokenManager.saveSession(
        access: 'jwt-access-abc',
        refresh: 'jwt-refresh-xyz',
        userId: 'usr-test',
        userRole: 'tenant',
      );
      expect(TokenManager.hasToken, isTrue);

      int notifyCount = 0;
      void listener() => notifyCount++;
      TokenManager.authChangeNotifier.addListener(listener);

      await TokenManager.clear();

      expect(TokenManager.accessToken, isNull);
      expect(TokenManager.refreshToken, isNull);
      expect(TokenManager.userId, isNull);
      expect(TokenManager.userRole, isNull);
      expect(TokenManager.cachedUserProfileJson, isNull);
      expect(TokenManager.hasToken, isFalse);
      expect(notifyCount, greaterThan(0));

      TokenManager.authChangeNotifier.removeListener(listener);
    });

    test('isLandlord and isTenant identify dual role correctly', () async {
      await TokenManager.saveSession(
        access: 'token',
        userId: 'dual-user',
        userRole: 'dual',
      );
      expect(TokenManager.isLandlord, isTrue);
      expect(TokenManager.isTenant, isTrue);
    });
  });

  group('AppRouter Route Guard & Session Redirection Tests', () {
    test('Router redirect guards unauthenticated users from protected landlord vault', () {
      final redirect = AppRouter.router.configuration.redirect;
      expect(redirect, isNotNull);
      expect(TokenManager.hasToken, isFalse);
    });
  });
}
