import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/di/service_locator.dart';
import 'package:rentbd_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rentbd_app/features/auth/presentation/screens/login_otp_screen.dart';
import 'package:rentbd_app/features/auth/presentation/screens/register_screen.dart';

void main() {
  setUpAll(() {
    AppEnvironment.useMockData = true;
    AppEnvironment.mockDelay = Duration.zero;
    ServiceLocator.init();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => sl<AuthBloc>(),
        child: child,
      ),
    );
  }

  group('Auth Screens UI & UX Verification', () {
    testWidgets('LoginOtpScreen renders brand header, role switcher, and inputs',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginOtpScreen()));
      await tester.pumpAndSettle();

      // Brand elements
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('BD'), findsOneWidget);

      // Role selector
      expect(find.text('ভাড়াটিয়া (Tenant)'), findsOneWidget);
      expect(find.text('বাড়িওয়ালা (Owner)'), findsOneWidget);

      // Auth modes
      expect(find.text('Mobile OTP'), findsOneWidget);
      expect(find.text('Password Login'), findsOneWidget);

      // Phone input & CTA
      expect(find.text('+880'), findsOneWidget);
      expect(find.text('Login with OTP: 123456 (লগইন করুন)'), findsOneWidget);
      expect(find.text('Create Account (রেজিস্ট্রেশন)'), findsOneWidget);
    });

    testWidgets('LoginOtpScreen toggles to Landlord role and updates text',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginOtpScreen()));
      await tester.pumpAndSettle();

      // Tap Landlord role
      await tester.tap(find.text('বাড়িওয়ালা (Owner)'));
      await tester.pumpAndSettle();

      expect(find.text('বাড়িওয়ালা ড্যাশবোর্ড ও ডিজিটাল ভল্ট'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders role cards, inputs and password strength meter',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Header & Title
      expect(find.text('নতুন অ্যাকাউন্ট তৈরি করুন'), findsOneWidget);
      expect(find.text('Join RentBD Today'), findsOneWidget);

      // Role cards
      expect(find.text('ভাড়াটিয়া (Tenant)'), findsOneWidget);
      expect(find.text('বাড়িওয়ালা (Owner)'), findsOneWidget);

      // Form fields
      expect(find.text('Full Name (পূর্ণ নাম)'), findsOneWidget);
      expect(find.text('Mobile Number (মোবাইল নম্বর)'), findsOneWidget);
      expect(find.text('Password (পাসওয়ার্ড)'), findsOneWidget);
      expect(find.text('Confirm Password (পাসওয়ার্ড নিশ্চিত করুন)'), findsOneWidget);

      // DMP compliance notice
      expect(
        find.textContaining('ঢাকা মেট্রোপলিটন পুলিশ নিরাপত্তা বিধি'),
        findsOneWidget,
      );

      // CTA button
      expect(
        find.text('Register as Tenant & Proceed (রেজিস্ট্রেশন)'),
        findsOneWidget,
      );
    });

    testWidgets('RegisterScreen switches to Landlord role and adapts button label',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Tap Landlord card
      await tester.tap(find.text('বাড়িওয়ালা (Owner)'));
      await tester.pumpAndSettle();

      // CTA button changes to Landlord vault registration
      expect(
        find.text('Register as Landlord & Enter Vault'),
        findsOneWidget,
      );
    });
  });
}
