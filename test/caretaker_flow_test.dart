import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medai/main.dart';
import 'package:medai/screens/caretaker/accept_invitation_screen.dart';
import 'package:medai/screens/caretaker/caretaker_dashboard_screen.dart';
import 'package:medai/screens/caretaker/caretaker_login_screen.dart';

void main() {
  Widget createCaretakerLoginWidget() {
    return const MediCareAiApp(
      initialScreen: CaretakerLoginScreen(),
    );
  }

  Widget createAcceptInvitationWidget() {
    return const MediCareAiApp(
      initialScreen: AcceptInvitationScreen(),
    );
  }

  Widget createCaretakerDashboardWidget() {
    return const MediCareAiApp(
      initialScreen: CaretakerDashboardScreen(
        caretakerName: 'Mark Jenkins',
        caretakerRelationship: 'Authorized Family Caregiver',
      ),
    );
  }

  group('MediCare AI - Caretaker Login Screen Tests', () {
    testWidgets('renders all essential caretaker login elements',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerLoginWidget());
      await tester.pumpAndSettle();

      // Brand & Heading
      expect(find.text('MediCare'), findsOneWidget);
      expect(find.text('Caretaker & Family Portal'), findsOneWidget);
      expect(find.text('Caretaker sign in'), findsOneWidget);
      expect(
        find.textContaining('Monitor medications, appointments, and care updates'),
        findsOneWidget,
      );

      // Inputs & Buttons
      expect(find.byKey(const Key('caretaker_identifier_field')), findsOneWidget);
      expect(find.byKey(const Key('caretaker_password_field')), findsOneWidget);
      expect(find.byKey(const Key('caretaker_primary_login_button')), findsOneWidget);
      expect(find.byKey(const Key('caretaker_forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('caretaker_back_to_roles_button')), findsOneWidget);
      expect(find.byKey(const Key('enter_invitation_code_button')), findsOneWidget);
      expect(find.byKey(const Key('autofill_valid_caretaker_chip')), findsOneWidget);
      expect(find.byKey(const Key('autofill_invalid_caretaker_chip')), findsOneWidget);
    });

    testWidgets('validates empty inputs and toggles password visibility',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerLoginWidget());
      await tester.pumpAndSettle();

      // Tap Sign in with empty fields
      final loginBtn = find.byKey(const Key('caretaker_primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter your registered email or phone'),
        findsOneWidget,
      );
      expect(
        find.text('Please enter your password'),
        findsOneWidget,
      );

      // Password visibility toggle
      final passwordFieldFinder =
          find.byKey(const Key('caretaker_password_field'));
      final toggleFinder =
          find.byKey(const Key('caretaker_toggle_password_button'));

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

      await tester.pumpWidget(createCaretakerLoginWidget());
      await tester.pumpAndSettle();

      // Tap "Autofill Invalid Caretaker" chip
      final invalidChip =
          find.byKey(const Key('autofill_invalid_caretaker_chip'));
      await tester.ensureVisible(invalidChip);
      await tester.tap(invalidChip);
      await tester.pumpAndSettle();

      expect(find.text('unregistered@care.net'), findsOneWidget);

      // Tap Sign In
      final loginBtn = find.byKey(const Key('caretaker_primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify failure error banner is displayed
      expect(find.byKey(const Key('caretaker_login_error_banner')), findsOneWidget);
      expect(
        find.textContaining('Authentication failed: Unregistered caregiver account'),
        findsOneWidget,
      );
    });

    testWidgets('successful demo login navigates to CaretakerDashboardScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerLoginWidget());
      await tester.pumpAndSettle();

      // Tap "Autofill Valid Caretaker" chip
      final validChip =
          find.byKey(const Key('autofill_valid_caretaker_chip'));
      await tester.ensureVisible(validChip);
      await tester.tap(validChip);
      await tester.pumpAndSettle();

      expect(find.text('mark.jenkins@familycare.org'), findsOneWidget);

      // Tap Sign In
      final loginBtn = find.byKey(const Key('caretaker_primary_login_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify navigation to Caretaker Dashboard
      expect(find.text('Caretaker Portal'), findsOneWidget);
      expect(find.text('Mark Jenkins'), findsOneWidget);
      expect(find.text('Authorized Family Caregiver'), findsOneWidget);
    });
  });

  group('MediCare AI - Accept Invitation Screen Tests', () {
    testWidgets('displays patient consent mandate and handles invalid code',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAcceptInvitationWidget());
      await tester.pumpAndSettle();

      // Verify consent mandate banner
      expect(find.text('Patient Consent Mandate'), findsOneWidget);
      expect(
        find.textContaining('A caregiver cannot approve access on a patient\'s behalf.'),
        findsOneWidget,
      );

      // Tap Invalid code chip
      await tester.tap(find.byKey(const Key('chip_code_invalid')));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Shows invalid card
      expect(find.byKey(const Key('invitation_invalid_card')), findsOneWidget);
      expect(find.text('Invalid Invitation Code'), findsOneWidget);

      // Reset
      await tester.tap(find.byKey(const Key('try_again_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('invitation_code_field')), findsOneWidget);
    });

    testWidgets(
        'pending code shows consent shield and transitions to accepted upon simulated patient approval',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAcceptInvitationWidget());
      await tester.pumpAndSettle();

      // Tap Pending code chip (CARE-5921)
      await tester.tap(find.byKey(const Key('chip_code_pending')));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify pending card and privacy shield
      expect(find.byKey(const Key('invitation_pending_card')), findsOneWidget);
      expect(find.text('Link Invitation Submitted'), findsOneWidget);
      expect(
        find.textContaining('Waiting for Robert Chen to approve your caretaker access'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Privacy Shield: Health records, prescriptions, and upcoming appointments are obscured'),
        findsOneWidget,
      );

      // Simulate: Patient Approves Access
      await tester.tap(find.byKey(const Key('simulate_patient_approval_button')));
      await tester.pumpAndSettle();

      // Accepted card is active
      expect(find.byKey(const Key('invitation_accepted_card')), findsOneWidget);
      expect(find.text('Caregiver Access Granted'), findsOneWidget);
      expect(find.byKey(const Key('open_caretaker_dashboard_button')), findsOneWidget);
    });
  });

  group('MediCare AI - Caretaker Dashboard Tests', () {
    testWidgets('renders approved patient dashboard with all key sections',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerDashboardWidget());
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Caretaker Portal'), findsOneWidget);
      expect(find.text('Mark Jenkins'), findsOneWidget);

      // Linked Family Members selector
      expect(find.text('Linked Family Members'), findsOneWidget);
      expect(find.text('Sarah Jenkins (Mother)'), findsOneWidget);

      // 1. Missed-Dose Alert Banner
      expect(find.byKey(const Key('caretaker_missed_dose_card')), findsOneWidget);
      expect(find.text('Missed Medication Alert'), findsOneWidget);
      expect(find.textContaining('missed scheduled dose of Lisinopril'), findsOneWidget);

      // 2. Today's Dose Status Summary
      expect(find.text("Sarah Jenkins's Doses Today"), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);

      // 3. Next Dose Card
      expect(find.text('Next Scheduled Dose'), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('08:00 PM'), findsOneWidget);

      // 4. Upcoming Appointments Card
      expect(find.textContaining('Upcoming Appointments'), findsOneWidget);
      expect(find.text('Dr. Eleanor Vance, MD'), findsOneWidget);
      expect(find.textContaining('Wednesday, Oct 28'), findsOneWidget);

      // 5. Refill Reminders Card
      expect(find.text('Prescription Refill Reminders'), findsOneWidget);
      expect(find.text('Atorvastatin 20 mg'), findsOneWidget);
      expect(find.textContaining('4 pills remaining'), findsOneWidget);

      // 6. View-Only Disclaimer
      expect(
        find.textContaining('Caregivers cannot create, prescribe, or edit medications.'),
        findsOneWidget,
      );
    });

    testWidgets('interactively acknowledges and completes missed-dose follow up',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerDashboardWidget());
      await tester.pumpAndSettle();

      // Tap "Review Alert & Follow Up"
      final reviewBtn = find.byKey(const Key('review_missed_dose_button'));
      await tester.ensureVisible(reviewBtn);
      await tester.tap(reviewBtn);
      await tester.pumpAndSettle();

      // Sheet opens
      expect(find.text('Missed-Dose Alert Details'), findsOneWidget);
      expect(find.byKey(const Key('acknowledge_alert_button')), findsOneWidget);
      expect(find.byKey(const Key('contact_patient_button')), findsOneWidget);
      expect(find.byKey(const Key('mark_follow_up_complete_button')), findsOneWidget);

      // Action 1: Acknowledge alert
      await tester.tap(find.byKey(const Key('acknowledge_alert_button')));
      await tester.pumpAndSettle();
      expect(find.text('Alert Acknowledged'), findsOneWidget);

      // Action 2: Contact patient
      await tester.tap(find.byKey(const Key('contact_patient_button')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Contact Sarah Jenkins'), findsOneWidget);
      await tester.tap(find.text('Send Reminder SMS'));
      await tester.pumpAndSettle();

      // Action 3: Mark follow-up complete
      await tester.tap(find.byKey(const Key('mark_follow_up_complete_button')));
      await tester.pumpAndSettle();

      // Sheet closes, alert banner is resolved
      expect(find.byKey(const Key('caretaker_missed_dose_card')), findsNothing);
    });

    testWidgets('respects consent: pending and revoked links obscure medical records',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerDashboardWidget());
      await tester.pumpAndSettle();

      // Switch to Pending Patient: Robert Chen
      final robertChip = find.byKey(const Key('patient_chip_patient_robert'));
      await tester.ensureVisible(robertChip);
      await tester.tap(robertChip);
      await tester.pumpAndSettle();

      // Medical records are obscured; pending consent card is shown
      expect(find.byKey(const Key('caretaker_pending_shield_card')), findsOneWidget);
      expect(find.text('Access Pending Patient Approval'), findsOneWidget);
      expect(find.text('Next Scheduled Dose'), findsNothing);
      expect(find.textContaining('Upcoming Appointments'), findsNothing);

      // Switch to Revoked Patient: Arthur Miller
      final arthurChip = find.byKey(const Key('patient_chip_patient_arthur'));
      await tester.ensureVisible(arthurChip);
      await tester.tap(arthurChip);
      await tester.pumpAndSettle();

      // Medical records are obscured; revoked consent card is shown
      expect(find.byKey(const Key('caretaker_revoked_shield_card')), findsOneWidget);
      expect(find.text('Access Revoked by Patient'), findsOneWidget);
      expect(find.text('Next Scheduled Dose'), findsNothing);
      expect(find.textContaining('Upcoming Appointments'), findsNothing);
    });

    testWidgets('opens notification settings and saves alert preferences',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createCaretakerDashboardWidget());
      await tester.pumpAndSettle();

      // Tap Notification Settings button (bell icon)
      final notifBtn =
          find.byKey(const Key('caretaker_notification_settings_button'));
      await tester.tap(notifBtn);
      await tester.pumpAndSettle();

      // Sheet opens
      expect(find.text('Caretaker Notification Settings'), findsOneWidget);
      expect(find.byKey(const Key('toggle_missed_doses_switch')), findsOneWidget);
      expect(find.byKey(const Key('toggle_appointments_switch')), findsOneWidget);
      expect(find.byKey(const Key('toggle_refills_switch')), findsOneWidget);

      // Tap Save
      await tester.tap(find.byKey(const Key('save_notification_settings_button')));
      await tester.pumpAndSettle();

      expect(find.text('Notification preferences saved.'), findsOneWidget);
    });
  });
}
