import 'package:flutter/material.dart';
import '../screens/caretaker/caretaker_login_screen.dart';
import '../screens/doctor/doctor_login_screen.dart';
import '../screens/patient_login_screen.dart';
import '../theme/app_theme.dart';

/// Dialog shown when navigating back to role selection or switching portals.
class RoleSelectionDialog extends StatelessWidget {
  final String currentRole; // 'patient' or 'doctor' or 'caregiver'

  const RoleSelectionDialog({
    super.key,
    this.currentRole = 'patient',
  });

  static Future<void> show(BuildContext context, {String currentRole = 'patient'}) {
    return showDialog<void>(
      context: context,
      builder: (context) => RoleSelectionDialog(currentRole: currentRole),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPatientActive = currentRole.toLowerCase() == 'patient';
    final isDoctorActive = currentRole.toLowerCase() == 'doctor';
    final isCaregiverActive = currentRole.toLowerCase() == 'caregiver';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: const Row(
        children: [
          Icon(Icons.switch_account_rounded, color: AppTheme.primaryTeal),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Select Portal Role',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose how you want to sign in to MediCare AI:',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          _RoleOptionTile(
            icon: Icons.person_rounded,
            title: 'Patient Portal',
            subtitle: 'Access your health records and AI symptom assistant',
            isSelected: isPatientActive,
            onTap: () {
              Navigator.of(context).pop();
              if (!isPatientActive) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const PatientLoginScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          _RoleOptionTile(
            icon: Icons.medical_services_rounded,
            title: 'Doctor & Clinician',
            subtitle: 'Provider workspace, EHR charts, and triage queue',
            isSelected: isDoctorActive,
            onTap: () {
              Navigator.of(context).pop();
              if (!isDoctorActive) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DoctorLoginScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          _RoleOptionTile(
            icon: Icons.family_restroom_rounded,
            title: 'Caregiver & Family',
            subtitle: 'Monitor elderly and dependent family health status',
            isSelected: isCaregiverActive,
            onTap: () {
              Navigator.of(context).pop();
              if (!isCaregiverActive) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const CaretakerLoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Stay on ${isDoctorActive ? 'Doctor' : (isCaregiverActive ? 'Caretaker' : 'Patient')} Login',
          ),
        ),
      ],
    );
  }
}

class _RoleOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTealLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryTeal
                    : AppTheme.cardBorder.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppTheme.primaryTealDark
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
