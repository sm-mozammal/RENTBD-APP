import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/widgets/bari_badge.dart';
import 'package:rentbd_app/core/widgets/bari_button.dart';
import 'package:rentbd_app/core/widgets/bari_price_tag.dart';
import 'package:rentbd_app/core/widgets/bari_segmented_switch.dart';

void main() {
  group('RentBD Core Reusable UI Component Tests', () {
    testWidgets('BariButton displays label and responds to taps', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BariButton(
              label: 'Explore Flats',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Explore Flats'), findsOneWidget);
      await tester.tap(find.text('Explore Flats'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('BariButton displays spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BariButton(
              label: 'Proceed',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Proceed'), findsNothing);
    });

    testWidgets('BariSegmentedSwitch renders segments and triggers callback', (tester) async {
      TenantCategoryFilter selected = TenantCategoryFilter.all;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BariSegmentedSwitch(
              selected: selected,
              onChanged: (newFilter) {
                selected = newFilter;
              },
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Bachelor'), findsOneWidget);
      expect(find.text('Family'), findsOneWidget);
      expect(find.text('Sublet'), findsOneWidget);

      await tester.tap(find.text('Bachelor'));
      await tester.pump();

      expect(selected, equals(TenantCategoryFilter.bachelor));
    });

    testWidgets('BariPriceTag formats BDT currency correctly with symbol', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BariPriceTag(
              amount: 25000,
              period: '/mo',
            ),
          ),
        ),
      );

      expect(find.textContaining('৳'), findsOneWidget);
      expect(find.textContaining('25,000'), findsOneWidget);
      expect(find.text('/mo'), findsOneWidget);
    });

    testWidgets('BariBadge renders verified badge with check icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BariBadge(
              type: BariBadgeType.nidVerified,
            ),
          ),
        ),
      );

      expect(find.text('NID Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
    });
  });
}
