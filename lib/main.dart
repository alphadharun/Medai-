import 'package:flutter/material.dart';
import 'screens/caretaker/accept_invitation_screen.dart';
import 'screens/caretaker/caretaker_dashboard_screen.dart';
import 'screens/caretaker/caretaker_login_screen.dart';
import 'screens/doctor/doctor_login_screen.dart';
import 'screens/doctor/patient_access_request_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/patient_login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediCareAiApp());
}

/// Root widget for the MediCare AI application.
class MediCareAiApp extends StatelessWidget {
  final Widget? initialScreen;

  const MediCareAiApp({super.key, this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialScreen ??
          Builder(
            builder: (context) => PatientDashboardScreen(
              onSignOut: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const PatientLoginScreen(),
                  ),
                );
              },
            ),
          ),
      routes: {
        '/dashboard': (context) => const PatientDashboardScreen(),
        '/login': (context) => const PatientLoginScreen(),
        '/doctor-login': (context) => const DoctorLoginScreen(),
        '/doctor-access-request': (context) =>
            const PatientAccessRequestScreen(),
        '/caretaker-login': (context) => const CaretakerLoginScreen(),
        '/caretaker-dashboard': (context) => const CaretakerDashboardScreen(),
        '/caretaker-accept-invitation': (context) =>
            const AcceptInvitationScreen(),
      },
    );
  }
}
