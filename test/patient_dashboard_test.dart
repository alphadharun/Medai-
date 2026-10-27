import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medai/main.dart';
import 'package:medai/screens/patient_dashboard_screen.dart';

void main() {
  Widget createDashboardWidget() {
    return const MediCareAiApp(
      initialScreen: PatientDashboardScreen(),
    );
  }

  group('MediCare AI - Patient Home Dashboard Tests', () {
    testWidgets('renders all seven sections on the Home dashboard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_profile_button')), findsOneWidget);
      expect(find.byKey(const Key('dashboard_notifications_button')),
          findsOneWidget);

      // 2. Today's Medication Summary
      expect(find.text("Today's Medication Summary"), findsOneWidget);
      expect(find.byKey(const Key('summary_taken_tile')), findsOneWidget);
      expect(find.byKey(const Key('summary_remaining_tile')), findsOneWidget);
      expect(find.byKey(const Key('summary_missed_tile')), findsOneWidget);

      // 3. Next Dose Card
      expect(find.text('NEXT DOSE'), findsOneWidget);
      expect(find.byKey(const Key('take_dose_button')), findsOneWidget);
      expect(find.byKey(const Key('snooze_dose_button')), findsOneWidget);

      // 4. Quick Actions
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.byKey(const Key('quick_action_scan_rx')), findsOneWidget);
      expect(find.byKey(const Key('quick_action_add_med')), findsOneWidget);
      expect(find.byKey(const Key('quick_action_schedule')), findsOneWidget);
      expect(find.byKey(const Key('quick_action_history')), findsOneWidget);

      // 5. Upcoming Appointment
      final appointmentCard = find.text('Upcoming Appointment');
      await tester.ensureVisible(appointmentCard);
      expect(appointmentCard, findsOneWidget);
      expect(find.text('Dr. Eleanor Vance, MD'), findsOneWidget);
      expect(find.byKey(const Key('appointment_details_button')), findsOneWidget);

      // 6. Bottom Navigation
      expect(find.byKey(const Key('nav_destination_home')), findsOneWidget);
      expect(find.byKey(const Key('nav_destination_medications')), findsOneWidget);
      expect(find.byKey(const Key('nav_destination_appointments')), findsOneWidget);
      expect(find.byKey(const Key('nav_destination_profile')), findsOneWidget);
    });

    testWidgets('interactively marks next dose as taken and updates summary',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Initially, Atorvastatin is next dose
      expect(find.text('Atorvastatin'), findsOneWidget);

      // Tap "Take Dose" button
      final takeDoseBtn = find.byKey(const Key('take_dose_button'));
      await tester.ensureVisible(takeDoseBtn);
      await tester.tap(takeDoseBtn);
      await tester.pumpAndSettle();

      // Verify confirmation snackbar
      expect(
        find.textContaining('Marked Atorvastatin 20 mg as taken!'),
        findsOneWidget,
      );

      // Next dose card should now indicate all caught up for today
      expect(find.text('All caught up for today!'), findsOneWidget);
    });

    testWidgets('bottom navigation switches cleanly between tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Switch to Medications Tab
      await tester.tap(find.byKey(const Key('nav_destination_medications')));
      await tester.pumpAndSettle();
      expect(find.text('My Medications'), findsOneWidget);
      expect(find.byKey(const Key('tab_add_medication_button')), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);

      // Switch to Appointments Tab
      await tester.tap(find.byKey(const Key('nav_destination_appointments')));
      await tester.pumpAndSettle();
      expect(find.text('Appointments'), findsWidgets);
      expect(find.text('Dr. Eleanor Vance, MD'), findsOneWidget);

      // Switch to Profile Tab
      await tester.tap(find.byKey(const Key('nav_destination_profile')));
      await tester.pumpAndSettle();
      expect(find.text('Portal Preferences'), findsOneWidget);
      expect(find.byKey(const Key('profile_sign_out_button')), findsOneWidget);

      // Switch back to Home Tab
      await tester.tap(find.byKey(const Key('nav_destination_home')));
      await tester.pumpAndSettle();
      expect(find.text("Today's Medication Summary"), findsOneWidget);
    });

    testWidgets('opens appointment details modal sheet with prep instructions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      final detailsBtn = find.byKey(const Key('appointment_details_button'));
      await tester.ensureVisible(detailsBtn);
      await tester.tap(detailsBtn);
      await tester.pumpAndSettle();

      expect(find.text('Preparation & Checklist'), findsOneWidget);
      expect(find.text('Clinic Location'), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Preparation & Checklist'), findsNothing);
    });

    testWidgets('quick actions open scanner, schedule, and history sheets',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // 1. Scan Prescription
      final scanRxBtn = find.byKey(const Key('quick_action_scan_rx'));
      await tester.ensureVisible(scanRxBtn);
      await tester.tap(scanRxBtn);
      await tester.pumpAndSettle();
      expect(find.text('AI Prescription Scanner'), findsOneWidget);

      // Tap simulate scan
      await tester.tap(find.text('Simulate Bottle Scan'));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
      expect(find.text('Amlodipine 5 mg'), findsOneWidget);

      // Dismiss scanner via close button
      await tester.tap(find.byKey(const Key('close_scanner_button')));
      await tester.pumpAndSettle();
      expect(find.text('AI Prescription Scanner'), findsNothing);

      // 2. View History
      final historyBtn = find.byKey(const Key('quick_action_history'));
      await tester.ensureVisible(historyBtn);
      await tester.tap(historyBtn);
      await tester.pumpAndSettle();
      expect(find.text('Medication History'), findsOneWidget);
      expect(find.text('7-Day Adherence Score:'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Section 7: manual medication entry flow validates, reviews, and adds med',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardWidget());
      await tester.pumpAndSettle();

      // Tap "Add Medication" quick action
      final addMedBtn = find.byKey(const Key('quick_action_add_med'));
      await tester.ensureVisible(addMedBtn);
      await tester.tap(addMedBtn);
      await tester.pumpAndSettle();

      // Step 1: Form View
      expect(find.text('Add New Medication'), findsOneWidget);
      expect(find.byKey(const Key('med_name_input')), findsOneWidget);
      expect(find.byKey(const Key('med_dosage_input')), findsOneWidget);

      // Try proceeding with empty fields -> should validate
      final proceedBtn = find.byKey(const Key('proceed_to_review_button'));
      await tester.ensureVisible(proceedBtn);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter the medicine name'), findsOneWidget);

      // Fill in valid details
      await tester.enterText(
        find.byKey(const Key('med_name_input')),
        'Rosuvastatin',
      );
      await tester.enterText(
        find.byKey(const Key('med_dosage_input')),
        '10 mg',
      );
      await tester.enterText(
        find.byKey(const Key('med_instructions_input')),
        'Take in the evening with water',
      );

      // Proceed to review
      await tester.ensureVisible(proceedBtn);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      // Step 2: Review View
      expect(find.text('Review Medication Details'), findsOneWidget);
      expect(find.text('Rosuvastatin'), findsOneWidget);
      expect(find.text('Dosage: 10 mg'), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Take in the evening with water'), findsOneWidget);
      expect(find.byKey(const Key('back_to_edit_button')), findsOneWidget);
      expect(find.byKey(const Key('confirm_add_medication_button')),
          findsOneWidget);

      // Test "Back to Edit" button
      final backToEditBtn = find.byKey(const Key('back_to_edit_button'));
      await tester.ensureVisible(backToEditBtn);
      await tester.tap(backToEditBtn);
      await tester.pumpAndSettle();
      expect(find.text('Add New Medication'), findsOneWidget);

      // Return to review and confirm
      await tester.ensureVisible(proceedBtn);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      final confirmBtn = find.byKey(const Key('confirm_add_medication_button'));
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verify success snackbar and addition to dashboard state
      expect(
        find.text('Rosuvastatin 10 mg added to your schedule!'),
        findsOneWidget,
      );

      // Switch to Medications tab and verify Rosuvastatin is listed
      await tester.tap(find.byKey(const Key('nav_destination_medications')));
      await tester.pumpAndSettle();
      expect(find.text('Rosuvastatin'), findsOneWidget);
      expect(find.textContaining('10 mg'), findsWidgets);
    });
  });
}
