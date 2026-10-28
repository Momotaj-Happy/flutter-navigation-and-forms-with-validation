import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_regform/screens/multi_step_wizard_screen.dart';

void main() {
  testWidgets('MultiStepWizardScreen renders steps and performs validation', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MultiStepWizardScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial Step 1 Personal Information
    expect(find.text('Personal Information'), findsWidgets);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Continue'), findsWidgets);

    // Tapping 'Continue' on Step 1 without input should trigger validation
    await tester.tap(find.text('Continue').first);
    await tester.pumpAndSettle();

    // Name is required error must appear
    expect(find.text('Name is required'), findsOneWidget);

    // Save Draft button exists and can be tapped
    expect(find.text('Save Draft'), findsWidgets);
    await tester.tap(find.text('Save Draft').first);
    await tester.pumpAndSettle();
  });
}
