import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medai/main.dart';
import 'package:medai/screens/patient_login_screen.dart';

void main() {
  Widget createTestWidget() {
    return const MediCareAiApp(initialScreen: PatientLoginScreen());
  }

  group('MediCare AI - Patient Login Screen Tests', () {
    testWidgets('renders all essential brand and form elements',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. MediCare AI brand and healthcare icon
      expect(find.text('MediCare'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Patient Portal'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // 2. Welcome back heading and instruction
      expect(find.text('Welcome back'), findsOneWidget);
      expect(
        find.textContaining('Sign in with your email address or mobile number'),
        findsOneWidget,
      );

      // 3. Inputs
      expect(find.byKey(const Key('login_identifier_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);

      // 4. Links and Buttons
      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('primary_login_button')), findsOneWidget);
      expect(find.byKey(const Key('create_account_link')), findsOneWidget);
      expect(
        find.byKey(const Key('back_to_role_selection_button')),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors when logging in with empty fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final loginBtn = find.byKey(const Key('primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter your email or phone number'),
        findsOneWidget,
      );
      expect(
        find.text('Please enter your password'),
        findsOneWidget,
      );
    });

    testWidgets('validates invalid email format and invalid password length',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid email and short password
      await tester.enterText(
        find.byKey(const Key('login_identifier_field')),
        'not-an-email@com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        '123',
      );

      final loginBtn = find.byKey(const Key('primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Please enter a valid email address (e.g. name@example.com)'),
        findsOneWidget,
      );
      expect(
        find.text('Password must be at least 6 characters long'),
        findsOneWidget,
      );
    });

    testWidgets('toggles password visibility with show/hide control',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final passwordFieldFinder =
          find.byKey(const Key('login_password_field'));
      final toggleFinder =
          find.byKey(const Key('toggle_password_visibility_button'));

      await tester.ensureVisible(toggleFinder);

      // Initially obscured
      TextField passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isTrue);

      // Tap show password
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isFalse);

      // Tap hide password
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('back navigation opens role selection dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final backBtn = find.byKey(const Key('back_to_role_selection_button'));
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.text('Select Portal Role'), findsOneWidget);
      expect(find.text('Patient Portal'), findsWidgets);
      expect(find.text('Doctor & Clinician'), findsOneWidget);
      expect(find.text('Caregiver & Family'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Stay on Patient Login'));
      await tester.pumpAndSettle();
      expect(find.text('Select Portal Role'), findsNothing);
    });

    testWidgets('forgot password link opens reset password sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final forgotBtn = find.byKey(const Key('forgot_password_button'));
      await tester.ensureVisible(forgotBtn);
      await tester.tap(forgotBtn);
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.byKey(const Key('recovery_input_field')), findsOneWidget);
      expect(find.byKey(const Key('send_recovery_button')), findsOneWidget);

      // Dismiss
      await tester.tap(find.text('Cancel and return to sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Reset your password'), findsNothing);
    });

    testWidgets('create account link opens new patient setup dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final createAccountLink = find.byKey(const Key('create_account_link'));
      await tester.ensureVisible(createAccountLink);
      await tester.tap(createAccountLink);
      await tester.pumpAndSettle();

      expect(find.text('New Patient Setup'), findsOneWidget);
      expect(find.text('Start Registration'), findsOneWidget);

      // Close
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('New Patient Setup'), findsNothing);
    });

    testWidgets('autofill demo chip and successful demo sign-in flow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap autofill demo chip
      final autofillChip = find.byKey(const Key('demo_autofill_chip'));
      await tester.ensureVisible(autofillChip);
      await tester.tap(autofillChip);
      await tester.pumpAndSettle();

      expect(
        find.text('sarah.jenkins@example.com'),
        findsOneWidget,
      );

      // Tap Log in button
      final loginBtn = find.byKey(const Key('primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump(); // Render loading state frame

      // Verify progress indicator is visible while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance simulated timer (900ms)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Verify success dialog and snackbar appeared
      expect(find.text('Sign-in successful! Welcome back.'), findsOneWidget);
      expect(find.text('Welcome back!'), findsWidgets);
      expect(
        find.text('You have securely signed in as:\nsarah.jenkins@example.com'),
        findsOneWidget,
      );
      expect(
        find.text('256-bit Encrypted Patient Session'),
        findsOneWidget,
      );

      // Tap continue to dismiss
      await tester.tap(find.byKey(const Key('continue_dashboard_button')));
      await tester.pumpAndSettle();
      expect(find.text('Continue to Health Portal (Demo)'), findsNothing);
    });
  });
}
