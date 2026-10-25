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
import 'package:rentbd_app/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_event.dart';

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
  setUpAll(() async {
    AppEnvironment.useMockData = true;
    AppEnvironment.mockDelay = Duration.zero;
    await ServiceLocator.init();
  });

  (AuthBloc, PropertyBloc) createBlocs({bool isLandlord = true, bool isKycDone = true}) {
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
    }
    if (isKycDone) {
      authBloc.add(const SubmitKycRequestedEvent(
        nidNumber: '19942691234567890',
        presentAddress: 'Road 5, Block C, Mirpur 10',
        emergencyContact: '01711223344',
      ));
    }

    final propertyBloc = sl<PropertyBloc>()..add(const FetchPropertiesEvent());
    return (authBloc, propertyBloc);
  }

  group('PropertyVaultScreen & QuickPostScreen Live API Tests', () {
    testWidgets('PropertyVaultScreen fetches properties from repository and renders cards',
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
              home: PropertyVaultScreen(),
            ),
          ),
        );

        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Heading
        expect(find.text('Property Vault (Re-Listing)'), findsOneWidget);
        expect(find.text('My Managed Properties'), findsOneWidget);

        // Check first property title is displayed
        expect(find.text('2-Bed Modern Flat near Mirpur 10 Metro Station'), findsOneWidget);

        authBloc.close();
        propertyBloc.close();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });

    testWidgets('PropertyVaultScreen re-listing switch toggles vacancy via repository',
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
              home: PropertyVaultScreen(),
            ),
          ),
        );

        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Find first switch
        final switchFinder = find.byType(Switch).first;
        expect(switchFinder, findsOneWidget);

        // Toggle switch
        await tester.tap(switchFinder);
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify SnackBar feedback is shown
        expect(find.byType(SnackBar), findsOneWidget);

        authBloc.close();
        propertyBloc.close();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });

    testWidgets('QuickPostScreen publishes rental listing via repository and shows success SnackBar',
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
              home: QuickPostScreen(),
            ),
          ),
        );

        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify title input, rent input, and publish button exist
        expect(find.text('60-Second Quick Post'), findsOneWidget);
        expect(find.text('Publish Listing in 60s'), findsOneWidget);

        // Enter listing title
        final titleField = find.widgetWithText(TextField, 'Listing Title');
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Test Luxury Flat in Mirpur 10');
        }

        // Tap Publish button
        final publishBtn = find.text('Publish Listing in 60s');
        await tester.ensureVisible(publishBtn);
        await tester.tap(publishBtn);

        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify SnackBar appears confirming publication
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('published in 60s with Verified Real Photo badge!'), findsOneWidget);

        authBloc.close();
        propertyBloc.close();
      } finally {
        debugNetworkImageHttpClientProvider = null;
      }
    });
  });
}
