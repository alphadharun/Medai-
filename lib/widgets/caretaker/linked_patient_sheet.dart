import 'package:flutter/material.dart';
import '../../models/caretaker_access.dart';
import '../../screens/caretaker/accept_invitation_screen.dart';
import '../../theme/app_theme.dart';

/// Modal bottom sheet for managing linked patients and access status.
/// Demonstrates patient consent boundaries and removal of access requests.
class LinkedPatientManagementSheet extends StatelessWidget {
  final List<CaregiverLinkedPatient> patients;
  final String selectedPatientId;
  final ValueChanged<String> onPatientSelected;
  final ValueChanged<String> onRequestRemoval;
  final Function(String patientId, CaregiverLinkStatus newStatus) onStatusChanged;
  final VoidCallback onAddPatient;

  const LinkedPatientManagementSheet({
    super.key,
    required this.patients,
    required this.selectedPatientId,
    required this.onPatientSelected,
    required this.onRequestRemoval,
    required this.onStatusChanged,
    required this.onAddPatient,
  });

  static Future<void> show(
    BuildContext context, {
    required List<CaregiverLinkedPatient> patients,
    required String selectedPatientId,
    required ValueChanged<String> onPatientSelected,
    required ValueChanged<String> onRequestRemoval,
    required Function(String patientId, CaregiverLinkStatus newStatus) onStatusChanged,
    required VoidCallback onAddPatient,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => LinkedPatientManagementSheet(
        patients: patients,
        selectedPatientId: selectedPatientId,
        onPatientSelected: onPatientSelected,
        onRequestRemoval: onRequestRemoval,
        onStatusChanged: onStatusChanged,
        onAddPatient: onAddPatient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.manage_accounts_rounded,
                          color: AppTheme.primaryTeal, size: 24),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Linked Patients',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  key: const Key('add_patient_invitation_button'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AcceptInvitationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Patient'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'View consent authorization status and manage care links.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),

            // Consent mandate reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 18, color: AppTheme.primaryTeal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Patient Consent: Health records are visible only for approved links. Patients can revoke caregiver access at any time.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryTealDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Patient List
            ...patients.map((patient) {
              final isSelected = patient.id == selectedPatientId;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryTealLight.withValues(alpha: 0.5)
                      : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryTeal
                        : AppTheme.cardBorder,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryTeal.withValues(alpha: 0.12),
                          radius: 18,
                          child: Text(
                            patient.name.substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
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
                                      patient.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
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
                                        'Viewing',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${patient.relationship} • ${patient.mrn}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(patient.linkStatus),
                      ],
                    ),
                    const Divider(height: 16, color: AppTheme.cardBorder),

                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isSelected)
                          TextButton(
                            key: Key('select_patient_${patient.id}_button'),
                            onPressed: () {
                              onPatientSelected(patient.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Select for Dashboard'),
                          )
                        else
                          const SizedBox(),

                        // Removal Request Button
                        OutlinedButton.icon(
                          key: Key('request_removal_${patient.id}_button'),
                          onPressed: () {
                            _confirmRemovalRequest(context, patient);
                          },
                          icon: const Icon(Icons.link_off_rounded,
                              size: 14, color: AppTheme.errorRed),
                          label: const Text(
                            'Request Removal',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.errorRed,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.errorRed),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ],
                    ),

                    // Demo Simulation Toggles
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Consent Demo:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (patient.linkStatus != CaregiverLinkStatus.revoked)
                          InkWell(
                            key: Key('simulate_revoke_${patient.id}_button'),
                            onTap: () {
                              onStatusChanged(
                                  patient.id, CaregiverLinkStatus.revoked);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.errorRed,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                      'Simulated: ${patient.name} revoked caregiver access.'),
                                ),
                              );
                            },
                            child: const Text(
                              'Simulate Revocation',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorRed,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        if (patient.linkStatus != CaregiverLinkStatus.approved) ...[
                          if (patient.linkStatus != CaregiverLinkStatus.revoked)
                            const SizedBox(width: 8),
                          InkWell(
                            key: Key('simulate_approve_${patient.id}_button'),
                            onTap: () {
                              onStatusChanged(
                                  patient.id, CaregiverLinkStatus.approved);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.successGreen,
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                      'Simulated: ${patient.name} approved caregiver access.'),
                                ),
                              );
                            },
                            child: const Text(
                              'Simulate Approval',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmRemovalRequest(
      BuildContext context, CaregiverLinkedPatient patient) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Removal of Access?'),
        content: Text(
          'Are you sure you want to request removal of caregiver access for ${patient.name}? '
          'You will no longer receive missed-dose alerts, medication tracking, or appointment notices for this patient.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_removal_button'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              onRequestRemoval(patient.id);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.textPrimary,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                      'Access removal processed. ${patient.name} was disconnected.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove Access'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(CaregiverLinkStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case CaregiverLinkStatus.approved:
        bg = const Color(0xFFDCFCE7);
        fg = AppTheme.successGreen;
        label = 'Approved';
        break;
      case CaregiverLinkStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'Pending';
        break;
      case CaregiverLinkStatus.revoked:
        bg = const Color(0xFFFFEAEA);
        fg = AppTheme.errorRed;
        label = 'Revoked';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
