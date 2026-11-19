import 'package:flutter_test/flutter_test.dart';
import 'package:carrent_smart_system/main.dart';

void main() {
  group('CarRent Issue #5 UI & BR-05 Role Tests', () {
    testWidgets('1. Renders Login screen with Owner and Runner role switcher',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CarRentApp());

      expect(find.text('CarRent'), findsOneWidget);
      expect(find.text('Fleet and bookings for Black Mamba Enterprise'),
          findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Runner'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets(
        '2. Owner login shows monthly revenue and Add Vehicle button (BR-05)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CarRentApp());

      // Tap Sign in as default Owner
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Verify Owner-exclusive elements are visible
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Monthly Revenue (Owner View)'), findsOneWidget);
      expect(find.text('RM 24,850.00'), findsOneWidget);
      expect(find.text('Add Vehicle'), findsOneWidget);
    });

    testWidgets(
        '3. Runner login hides revenue and Add Vehicle controls (BR-05)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CarRentApp());

      // Switch role to Runner before signing in
      await tester.tap(find.text('Runner'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Verify BR-05 restriction notice appears and Owner revenue is hidden
      expect(find.text('Runner Operations'), findsOneWidget);
      expect(find.text('Monthly Revenue (Owner View)'), findsNothing);
      expect(find.text('Add Vehicle'), findsNothing);
    });

    testWidgets('4. Navigates between Home, Fleet, and Booking Calendar tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CarRentApp());

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Navigate to Fleet tab
      await tester.tap(find.text('Fleet'));
      await tester.pumpAndSettle();
      expect(find.text('QAA 1111'), findsOneWidget);

      // Navigate to Calendar tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('New booking'), findsOneWidget);
    });
  });
}
