import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/widgets/chucker_floating_button.dart';

void main() {
  group('ChuckerFloatingButton Widget Tests', () {
    tearDown(() {
      ChuckerFloatingButton.showFloatingButton = true;
    });

    testWidgets('renders child content and floating button when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChuckerFloatingButton(
            enabled: true,
            child: const Scaffold(
              body: Center(child: Text('RentBD Main Content')),
            ),
          ),
        ),
      );

      expect(find.text('RentBD Main Content'), findsOneWidget);
      expect(find.byKey(const Key('chucker_floating_debug_button')), findsOneWidget);
      expect(find.text('API'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_tethering_rounded), findsOneWidget);
    });

    testWidgets('does not render floating button when enabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChuckerFloatingButton(
            enabled: false,
            child: const Scaffold(
              body: Center(child: Text('Content Without Button')),
            ),
          ),
        ),
      );

      expect(find.text('Content Without Button'), findsOneWidget);
      expect(find.byKey(const Key('chucker_floating_debug_button')), findsNothing);
    });

    testWidgets('does not render floating button when global showFloatingButton is false', (tester) async {
      ChuckerFloatingButton.showFloatingButton = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: ChuckerFloatingButton(
            child: Scaffold(
              body: Center(child: Text('Content Hidden Global')),
            ),
          ),
        ),
      );

      expect(find.text('Content Hidden Global'), findsOneWidget);
      expect(find.byKey(const Key('chucker_floating_debug_button')), findsNothing);
    });

    testWidgets('tapping floating button invokes onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ChuckerFloatingButton(
            enabled: true,
            onTapOverride: () {
              tapped = true;
            },
            child: const Scaffold(
              body: Center(child: Text('Tap Target Screen')),
            ),
          ),
        ),
      );

      final buttonFinder = find.byKey(const Key('chucker_floating_debug_button'));
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('dragging floating button updates position and snaps to nearest edge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChuckerFloatingButton(
            enabled: true,
            child: const Scaffold(
              body: Center(child: Text('Drag Test Screen')),
            ),
          ),
        ),
      );

      final buttonFinder = find.byKey(const Key('chucker_floating_debug_button'));
      expect(buttonFinder, findsOneWidget);

      final initialTopLeft = tester.getTopLeft(buttonFinder);

      // Drag across towards the left side (past 400 midpoint of 800px screen)
      await tester.drag(buttonFinder, const Offset(-500, 50));
      await tester.pump();

      // Settle the snap animation
      await tester.pumpAndSettle();

      final endTopLeft = tester.getTopLeft(buttonFinder);

      // Verify it snapped to the left edge (x <= 20) and moved vertically
      expect(endTopLeft.dx, lessThan(initialTopLeft.dx));
      expect(endTopLeft.dx, closeTo(12.0, 5.0));
    });
  });
}
