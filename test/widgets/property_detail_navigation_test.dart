import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/di/service_locator.dart';
import 'package:rentbd_app/features/property/domain/entities/property.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentbd_app/features/property/presentation/bloc/property_event.dart';
import 'package:rentbd_app/features/property/presentation/screens/property_detail_screen.dart';
import 'package:rentbd_app/features/property/presentation/widgets/property_card.dart';

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
  int get contentLength => kTransparentImage.length;

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
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = _TestHttpOverrides();
    AppEnvironment.useMockData = true;
    AppEnvironment.mockDelay = Duration.zero;
    await ServiceLocator.init();
  });

  const testProperty = Property(
    id: 'prop-test-01',
    landlordId: 'landlord-1',
    landlordName: 'Alim Hossain',
    landlordPhoneMasked: '01712***789',
    title: 'Modern 3-Bed Family Flat in Mirpur 10',
    description: 'Well-ventilated flat with line gas, lift and generator backup.',
    propertyType: PropertyType.apartment,
    tenantCategory: TenantCategory.family,
    rentAmount: 26000,
    securityDeposit: 52000,
    serviceCharge: 3500,
    estimatedUtilities: 2000,
    bedrooms: 3,
    bathrooms: 2,
    balconies: 2,
    squareFeet: 1250,
    floorLevel: 4,
    totalFloors: 7,
    latitude: 23.8071,
    longitude: 90.3686,
    areaNeighborhood: 'Mirpur 10',
    fullAddress: 'Road 5, Block B, Mirpur 10, Dhaka',
    images: [
      PropertyImage(
        id: 'img-1',
        imageUrl: 'https://example.com/test1.jpg',
        roomType: RoomType.livingRoom,
      ),
      PropertyImage(
        id: 'img-2',
        imageUrl: 'https://example.com/test2.jpg',
        roomType: RoomType.bedroom,
      ),
    ],
    fairPriceStatus: FairPriceStatus.greatDeal,
    fairPricePercentDiff: -6.5,
    areaAverageRent: 28000,
    alleyWidthFeet: 20.0,
    gasSupply: GasSupplyType.lineGas,
    waterloggingRisk: WaterloggingRisk.none,
    waterQuality: WaterQuality.excellent,
    nightSafetyRating: 4.6,
  );

  testWidgets('PropertyCard onTap triggers navigation callback', (tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyCard(
            property: testProperty,
            onTap: () => wasTapped = true,
            onToggleSave: () {},
          ),
        ),
      ),
    );

    expect(find.text('Modern 3-Bed Family Flat in Mirpur 10'), findsOneWidget);
    await tester.tap(find.byType(PropertyCard));
    await tester.pumpAndSettle();

    expect(wasTapped, isTrue);
  });

  testWidgets('PropertyDetailScreen displays rich property details and action buttons', (tester) async {
    await tester.pumpWidget(
      BlocProvider<PropertyBloc>(
        create: (_) => sl<PropertyBloc>()..add(const FetchPropertiesEvent()),
        child: const MaterialApp(
          home: PropertyDetailScreen(
            propertyId: 'prop-test-01',
            initialProperty: testProperty,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Address
    expect(find.text('Modern 3-Bed Family Flat in Mirpur 10'), findsOneWidget);
    expect(find.text('Road 5, Block B, Mirpur 10, Dhaka'), findsOneWidget);

    // Verify Key Specs
    expect(find.text('3 Beds'), findsOneWidget);
    expect(find.text('2 Baths'), findsOneWidget);
    expect(find.text('1250 SqFt'), findsOneWidget);

    // Verify AI Fair Rent Meter
    expect(find.text('AI Fair Rent Meter'), findsOneWidget);
    expect(find.text('Great Deal (AI Verified)'), findsOneWidget);

    // Verify Amenities
    expect(find.text('Line Gas'), findsWidgets);
    expect(find.text('Elevator / Lift'), findsOneWidget);

    // Verify Floating Action Buttons
    expect(find.text('Schedule Visit'), findsOneWidget);
    expect(find.text('Masked Chat'), findsOneWidget);
  });
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}
