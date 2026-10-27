import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medai/main.dart';
import 'package:medai/screens/doctor/doctor_login_screen.dart';
import 'package:medai/screens/doctor/patient_access_request_screen.dart';

void main() {
  Widget createDoctorLoginWidget() {
    return const MediCareAiApp(
      initialScreen: DoctorLoginScreen(),
    );
  }

  Widget createAccessRequestWidget() {
    return const MediCareAiApp(
      initialScreen: PatientAccessRequestScreen(),
    );
  }

  group('MediCare AI - Doctor Login Screen Tests', () {
    testWidgets('renders all essential doctor login elements',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDoctorLoginWidget());
      await tester.pumpAndSettle();

      // Brand & Heading
      expect(find.text('MediCare'), findsOneWidget);
      expect(find.text('Doctor / Clinician Portal'), findsOneWidget);
      expect(find.text('Doctor sign in'), findsOneWidget);
      expect(
        find.textContaining('hospital email or National Provider Identifier'),
        findsOneWidget,
      );

      // Inputs
      expect(find.byKey(const Key('doctor_identifier_field')), findsOneWidget);
      expect(find.byKey(const Key('doctor_password_field')), findsOneWidget);

      // Buttons & Links
      expect(find.byKey(const Key('doctor_primary_login_button')), findsOneWidget);
      expect(find.byKey(const Key('doctor_forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('doctor_back_to_roles_button')), findsOneWidget);
      expect(find.byKey(const Key('autofill_valid_doctor_chip')), findsOneWidget);
      expect(find.byKey(const Key('autofill_invalid_doctor_chip')), findsOneWidget);
    });

    testWidgets('validates empty inputs and toggles password visibility',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDoctorLoginWidget());
      await tester.pumpAndSettle();

      // Tap Log in with empty fields
      final loginBtn = find.byKey(const Key('doctor_primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter your professional email or NPI / Medical ID'),
        findsOneWidget,
      );
      expect(
        find.text('Please enter your clinical password'),
        findsOneWidget,
      );

      // Password visibility toggle
      final passwordFieldFinder =
          find.byKey(const Key('doctor_password_field'));
      final toggleFinder =
          find.byKey(const Key('doctor_toggle_password_button'));

      TextField passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isTrue);

      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFieldFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isFalse);
    });

    testWidgets('displays failed-login state when invalid credentials submitted',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDoctorLoginWidget());
      await tester.pumpAndSettle();

      // Tap "Autofill Invalid Doctor" chip
      await tester.tap(find.byKey(const Key('autofill_invalid_doctor_chip')));
      await tester.pumpAndSettle();

      expect(find.text('unregistered.doctor@clinic.net'), findsOneWidget);

      // Tap Log in
      final loginBtn = find.byKey(const Key('doctor_primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Verify clear failure error banner is displayed
      expect(find.byKey(const Key('doctor_login_error_banner')), findsOneWidget);
      expect(
        find.textContaining('Authentication failed: Provider credentials not found'),
        findsOneWidget,
      );
    });

    testWidgets(
        'successful demo login navigates to PatientAccessRequestScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDoctorLoginWidget());
      await tester.pumpAndSettle();

      // Tap "Autofill Valid Doctor" chip
      await tester.tap(find.byKey(const Key('autofill_valid_doctor_chip')));
      await tester.pumpAndSettle();

      expect(find.text('dr.vance@medicare.ai'), findsOneWidget);

      // Tap Log in
      final loginBtn = find.byKey(const Key('doctor_primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // Success notification and navigation to Patient Access Request Screen
      expect(
        find.text('Clinician verified. Opening Patient Access Request...'),
        findsOneWidget,
      );
      expect(find.text('Patient Access Request'), findsOneWidget);
      expect(find.text('Dr. Eleanor Vance, MD'), findsOneWidget);
    });
  });

  group('MediCare AI - Patient Access Request Screen Tests', () {
    testWidgets(
        'shows caregiver notice and prevents caregiver approval on patient behalf',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAccessRequestWidget());
      await tester.pumpAndSettle();

      // Sarah Jenkins has authorized caregiver Mark Jenkins
      expect(
        find.textContaining('Authorized Caregiver: Mark Jenkins'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('notify_caregiver_checkbox')), findsOneWidget);
      expect(
        find.textContaining(
            'Caregiver will be alerted of this request, but cannot approve it.'),
        findsOneWidget,
      );

      // Select Robert Chen (who has NOT authorized a caregiver)
      final patientDropdown = find.byKey(const Key('patient_selector_dropdown'));
      await tester.tap(patientDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Robert Chen').last);
      await tester.pumpAndSettle();

      expect(find.text('No Caregiver Authorized'), findsOneWidget);
      expect(
        find.textContaining(
            'This patient has not authorized caregiver sharing.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'pending and declined states keep patient medical information hidden',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAccessRequestWidget());
      await tester.pumpAndSettle();

      // Submit Access Request
      final submitBtn = find.byKey(const Key('submit_access_request_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Pending state is shown
      expect(find.text('Access Request Pending'), findsOneWidget);
      expect(find.byKey(const Key('simulate_approve_button')), findsOneWidget);
      expect(find.byKey(const Key('simulate_decline_button')), findsOneWidget);

      // Verify patient medical data is NOT displayed in pending state
      expect(find.text('Active Diagnoses & Conditions'), findsNothing);
      expect(find.text('Current Medications'), findsNothing);
      expect(find.text('Essential Hypertension (I10)'), findsNothing);

      // Simulate: Patient Declines Access
      await tester.tap(find.byKey(const Key('simulate_decline_button')));
      await tester.pumpAndSettle();

      // Declined state is shown
      expect(find.text('Access Request Declined'), findsOneWidget);
      expect(find.byKey(const Key('try_another_request_button')), findsOneWidget);

      // Verify medical data is STILL NOT displayed in declined state
      expect(find.text('Active Diagnoses & Conditions'), findsNothing);
      expect(find.text('Current Medications'), findsNothing);
      expect(find.text('Essential Hypertension (I10)'), findsNothing);
    });

    testWidgets(
        'approved state displays patient medical records and allows concluding session',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAccessRequestWidget());
      await tester.pumpAndSettle();

      // Submit Access Request
      final submitBtn = find.byKey(const Key('submit_access_request_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Simulate: Patient Approves Access
      await tester.tap(find.byKey(const Key('simulate_approve_button')));
      await tester.pumpAndSettle();

      // Approved state is active
      expect(find.text('Access Granted by Patient'), findsOneWidget);

      // Verify patient information is displayed NOW in approved state
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Recent Clinical Vitals'), findsOneWidget);
      expect(find.textContaining('BP: 128/82 mmHg'), findsOneWidget);
      expect(find.text('Active Diagnoses & Conditions'), findsOneWidget);
      expect(
        find.text('Essential Hypertension (I10)'),
        findsOneWidget,
      );
      expect(find.text('Current Medications'), findsOneWidget);
      expect(
        find.text('Metformin 500 mg - Twice daily with meals'),
        findsOneWidget,
      );

      // Let SnackBar dismiss
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Conclude Session and lock records
      final concludeBtn = find.byKey(const Key('conclude_session_button'));
      await tester.ensureVisible(concludeBtn);
      await tester.tap(concludeBtn);
      await tester.pumpAndSettle();

      // Returns to request form view
      expect(find.text('Select Patient for Request'), findsOneWidget);
      expect(find.text('Active Diagnoses & Conditions'), findsNothing);
    });
  });
}
