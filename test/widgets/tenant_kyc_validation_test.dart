import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/di/service_locator.dart';
import 'package:rentbd_app/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:rentbd_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rentbd_app/features/auth/domain/entities/user_profile.dart';
import 'package:rentbd_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rentbd_app/features/landlord/presentation/screens/property_vault_screen.dart';
import 'package:rentbd_app/features/landlord/presentation/screens/quick_post_screen.dart';
import 'package:rentbd_app/features/property/data/datasources/property_mock_datasource.dart';
import 'package:rentbd_app/features/property/data/repositories/property_repository_impl.dart';
import 'package:rentbd_app/features/property/domain/usecases/property_usecases.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_event.dart';
import 'package:rentbd_app/features/property/presentation/screens/home_screen.dart';
import 'package:rentbd_app/features/property/presentation/screens/property_detail_screen.dart';

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  group('Landlord-Only KYC Validation Rules', () {
    setUpAll(() async {
      AppEnvironment.useMockData = true;
      AppEnvironment.mockDelay = Duration.zero;
      await ServiceLocator.init();
    });

    (AuthBloc, PropertyBloc) createBlocs({bool isLandlord = false, bool isKycDone = false}) {
      final authMock = AuthMockDataSource();
      final authRepo = AuthRepositoryImpl(
        mockDataSource: authMock,
        remoteDataSource: authMock,
      );
      final authBloc = AuthBloc(
        sendOtpUseCase: SendOtpUseCase(authRepo),
        verifyOtpUseCase: VerifyOtpUseCase(authRepo),
        getProfileUseCase: GetProfileUseCase(authRepo),
        updateProfileUseCase: UpdateProfileUseCase(authRepo),
        switchRoleUseCase: SwitchRoleUseCase(authRepo),
        registerUseCase: RegisterUseCase(authRepo),
        changePasswordUseCase: ChangePasswordUseCase(authRepo),
        submitKycUseCase: SubmitKycUseCase(authRepo),
        loginWithPasswordUseCase: LoginWithPasswordUseCase(authRepo),
      )..add(const CheckAuthStatusEvent());

      if (isLandlord) {
        authBloc.add(const SwitchRoleRequestedEvent(newRole: UserRole.landlord));
        if (!isKycDone) {
          authBloc.add(UpdateProfileRequestedEvent(
            profile: AuthMockDataSource.defaultLandlord.toEntity().copyWith(
              isNidVerified: false,
              kycStatus: KycStatus.notSubmitted,
              nidNumber: '',
            ),
          ));
        }
      }
      if (isKycDone) {
        authBloc.add(const SubmitKycRequestedEvent(
          nidNumber: '19942691234567890',
          presentAddress: 'Road 5, Block C, Mirpur 10',
          emergencyContact: '01711223344',
        ));
      }

      final propMock = PropertyMockDataSource();
      final propRepo = PropertyRepositoryImpl(mockDataSource: propMock, remoteDataSource: propMock);
      final propertyBloc = PropertyBloc(
        getPropertiesUseCase: GetPropertiesUseCase(propRepo),
        getPropertyByIdUseCase: GetPropertyByIdUseCase(propRepo),
        toggleSavePropertyUseCase: ToggleSavePropertyUseCase(propRepo),
        getSavedPropertiesUseCase: GetSavedPropertiesUseCase(propRepo),
        naturalLanguageSearchUseCase: NaturalLanguageSearchUseCase(propRepo),
      )..add(const FetchPropertiesEvent());

      return (authBloc, propertyBloc);
    }

    testWidgets('HomeScreen allows tenants to browse without any KYC banner',
        (tester) async {
      final (authBloc, propertyBloc) = createBlocs();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<PropertyBloc>.value(value: propertyBloc),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tenants are not interrupted by KYC banner on HomeScreen
      expect(find.text('Mandatory Tenant KYC Required'), findsNothing);

      authBloc.close();
      propertyBloc.close();
    });

    testWidgets('PropertyDetailScreen allows tenant to tap Schedule Visit without KYC block',
        (tester) async {
      debugNetworkImageHttpClientProvider = () => _MockHttpClient();
      try {
        final (authBloc, propertyBloc) = createBlocs();

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<PropertyBloc>.value(value: propertyBloc),
            ],
            child: const MaterialApp(
              home: PropertyDetailScreen(
                propertyId: 'prop-mirpur-01',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // No tenant KYC banner
        expect(find.text('Mandatory Tenant KYC Required'), findsNothing);

        // Tap Schedule Visit button
        final scheduleVisitBtn = find.text('Schedule Visit');
        expect(scheduleVisitBtn, findsOneWidget);
        await tester.tap(scheduleVisitBtn);
        await tester.pumpAndSettle();

        // KYC dialog must NOT be triggered for tenants
        expect(find.text('Tenant KYC Required'), findsNothing);

        authBloc.close();
        propertyBloc.close();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });

    testWidgets('QuickPostScreen blocks unverified landlord from publishing listing',
        (tester) async {
      debugNetworkImageHttpClientProvider = () => _MockHttpClient();
      try {
        final (authBloc, _) = createBlocs(isLandlord: true, isKycDone: false);

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MaterialApp(
              home: QuickPostScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Landlord KYC Required Warning Card is visible at top
        expect(find.text('NID ভেরিফিকেশন (KYC) আবশ্যক'), findsOneWidget);

        // Tap Publish button
        final publishBtn = find.text('Publish Listing in 60s');
        expect(publishBtn, findsOneWidget);
        await tester.ensureVisible(publishBtn);
        await tester.tap(publishBtn);
        await tester.pumpAndSettle();

        // Dialog must be triggered blocking creation
        expect(find.text('NID Verification Required / KYC আবশ্যক'), findsOneWidget);
        expect(find.text('Verify NID Now (কেওয়াইসি করুন)'), findsOneWidget);

        authBloc.close();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });

    testWidgets('PropertyVaultScreen shows KYC pending banner and blocks re-listing when unverified',
        (tester) async {
      debugNetworkImageHttpClientProvider = () => _MockHttpClient();
      try {
        final (authBloc, _) = createBlocs(isLandlord: true, isKycDone: false);

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MaterialApp(
              home: PropertyVaultScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Warning card in Vault
        expect(find.text('NID ভেরিফিকেশন (KYC) পেন্ডিং'), findsOneWidget);

        // Tap Post New Property button
        final addBtn = find.text('Post New Property (ফ্ল্যাট যোগ করুন)');
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        // Dialog must be triggered blocking creation
        expect(find.text('NID Verification Required / KYC আবশ্যক'), findsOneWidget);

        authBloc.close();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });
  });
}
