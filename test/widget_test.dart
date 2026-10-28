import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_regform/main.dart';

void main() {
  testWidgets('App renders Home Screen and displays project buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('CSE 464 - Form Projects'), findsOneWidget);
    expect(find.text('Project 1: Single-Page Registration'), findsOneWidget);
    expect(find.text('Project 2: Multi-Step Form Wizard'), findsOneWidget);
  });
}
