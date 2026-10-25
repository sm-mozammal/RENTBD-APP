import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/di/service_locator.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rentbd_app/features/auth/presentation/screens/kyc_verification_screen.dart';

void main() {
  setUpAll(() {
    AppEnvironment.useMockData = true;
    AppEnvironment.mockDelay = Duration.zero;
    ServiceLocator.init();
  });

  Widget buildTestableWidget(Widget child, {Size surfaceSize = const Size(360, 800)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: child,
        ),
      ),
    );
  }

  group('KycVerificationScreen Camera & Layout Tests', () {
    testWidgets('Renders Step 1 with NID camera upload options and no overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const KycVerificationScreen()));
      await tester.pumpAndSettle();

      // Check header and step 1 elements
      expect(find.text('Landlord KYC Verification (NID)'), findsOneWidget);
      expect(find.text('Step 1: National Identity Card (NID)'), findsOneWidget);
      expect(find.text('National ID (NID) Number'), findsOneWidget);

      // Verify NID Front and Back photo cards are present
      expect(find.text('NID Front (সামনে)'), findsOneWidget);
      expect(find.text('NID Back (পেছনে)'), findsOneWidget);

      // Open camera labels
      expect(find.text('Open Camera'), findsWidgets);

      // Verify Next Step button
      expect(find.text('Next Step'), findsOneWidget);
    });

    testWidgets('Tapping NID Front opens bottom sheet with Camera & Gallery options',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const KycVerificationScreen()));
      await tester.pumpAndSettle();

      // Tap NID Front card
      await tester.tap(find.text('NID Front (সামনে)'));
      await tester.pumpAndSettle();

      // Verify bottom sheet appears
      expect(find.text('NID Front Photo (সামনের ছবি)'), findsOneWidget);
      expect(find.text('Open Camera (ক্যামেরা)'), findsOneWidget);
      expect(find.text('Choose from Gallery (গ্যালারি)'), findsOneWidget);
    });

    testWidgets('Step 2 displays live selfie capture area and camera button',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const KycVerificationScreen()));
      await tester.pumpAndSettle();

      // Switch to Step 2
      await tester.tap(find.text('2. Live Selfie'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2: Biometric Liveness Verification'), findsOneWidget);
      expect(find.text('Open Camera & Capture Selfie'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsWidgets);
    });

    testWidgets('Step 3 displays Submit KYC button without horizontal overflow on narrow screen',
        (tester) async {
      // Set narrow screen size (320px width - typical smallest Android screen)
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(
        const KycVerificationScreen(),
        surfaceSize: const Size(320, 600),
      ));
      await tester.pumpAndSettle();

      // Switch to Step 3
      await tester.tap(find.text('3. DMP Info'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3: Dhaka Address & Contact Declaration'), findsOneWidget);

      // Back and Submit KYC buttons
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Submit KYC'), findsOneWidget);

      // Verify no RenderFlex overflow exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Submitting KYC displays success SnackBar', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const KycVerificationScreen()));
      await tester.pumpAndSettle();

      // Go to Step 3
      await tester.tap(find.text('3. DMP Info'));
      await tester.pumpAndSettle();

      // Tap Submit KYC
      await tester.tap(find.text('Submit KYC'));
      await tester.pumpAndSettle();

      // Verify SnackBar appears with success message
      expect(find.text('KYC verification submitted successfully!'), findsOneWidget);
    });
  });
}
