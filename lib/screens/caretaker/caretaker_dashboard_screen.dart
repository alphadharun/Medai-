import 'package:flutter/material.dart';
import '../../models/caretaker_access.dart';
import '../../models/medication.dart';
import '../../theme/app_theme.dart';
import '../../widgets/caretaker/linked_patient_sheet.dart';
import '../../widgets/caretaker/missed_dose_sheet.dart';
import '../../widgets/caretaker/notification_settings_sheet.dart';
import 'accept_invitation_screen.dart';
import 'caretaker_login_screen.dart';

/// Primary mobile-first Caretaker Dashboard for MediCare AI.
/// Displays linked patient information, today's dose summary, missed-dose alerts,
/// upcoming appointments, and refill reminders.
/// Strictly enforces patient consent boundaries (view-only; no prescription edits;
/// records hidden for pending or revoked access).
class CaretakerDashboardScreen extends StatefulWidget {
  final String caretakerName;
  final String caretakerRelationship;
  final CaregiverLinkedPatient? initialPatient;

  const CaretakerDashboardScreen({
    super.key,
    this.caretakerName = 'Mark Jenkins',
    this.caretakerRelationship = 'Authorized Family Caregiver',
    this.initialPatient,
  });

  @override
  State<CaretakerDashboardScreen> createState() =>
      _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  late List<CaregiverLinkedPatient> _linkedPatients;
  late String _selectedPatientId;
  CaretakerNotificationPreferences _preferences =
      const CaretakerNotificationPreferences();

  @override
  void initState() {
    super.initState();
    _linkedPatients = MockCaretakerDirectory.getInitialLinkedPatients();

    if (widget.initialPatient != null) {
      final exists =
          _linkedPatients.any((p) => p.id == widget.initialPatient!.id);
      if (!exists) {
        _linkedPatients.insert(0, widget.initialPatient!);
      }
      _selectedPatientId = widget.initialPatient!.id;
    } else {
      _selectedPatientId = _linkedPatients.first.id;
    }
  }

  CaregiverLinkedPatient? get _selectedPatient {
    try {
      return _linkedPatients.firstWhere((p) => p.id == _selectedPatientId);
    } catch (_) {
      return _linkedPatients.isNotEmpty ? _linkedPatients.first : null;
    }
  }

  void _handleAlertUpdated(MissedDoseAlert updatedAlert) {
    setState(() {
      final index = _linkedPatients.indexWhere((p) => p.id == _selectedPatientId);
      if (index != -1) {
        if (updatedAlert.isFollowUpComplete) {
          // Alert is cleared when follow up is completed
          _linkedPatients[index] = _linkedPatients[index].copyWith(
            clearActiveMissedDose: true,
          );
        } else {
          _linkedPatients[index] = _linkedPatients[index].copyWith(
            activeMissedDose: updatedAlert,
          );
        }
      }
    });
  }

  void _handleStatusChanged(String patientId, CaregiverLinkStatus newStatus) {
    setState(() {
      final index = _linkedPatients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        _linkedPatients[index] =
            _linkedPatients[index].copyWith(linkStatus: newStatus);
      }
    });
  }

  void _handleRequestRemoval(String patientId) {
    setState(() {
      _linkedPatients.removeWhere((p) => p.id == patientId);
      if (_selectedPatientId == patientId && _linkedPatients.isNotEmpty) {
        _selectedPatientId = _linkedPatients.first.id;
      }
    });
  }

  void _openMissedDoseSheet(MissedDoseAlert alert) {
    MissedDoseDetailSheet.show(
      context,
      alert: alert,
      onAlertUpdated: _handleAlertUpdated,
      onDismiss: () {},
    );
  }

  void _openNotificationSettings() {
    NotificationSettingsSheet.show(
      context,
      initialPreferences: _preferences,
      onSaved: (prefs) => setState(() => _preferences = prefs),
    );
  }

  void _openManagePatientsSheet() {
    LinkedPatientManagementSheet.show(
      context,
      patients: _linkedPatients,
      selectedPatientId: _selectedPatientId,
      onPatientSelected: (id) => setState(() => _selectedPatientId = id),
      onRequestRemoval: _handleRequestRemoval,
      onStatusChanged: _handleStatusChanged,
      onAddPatient: () {},
    );
  }

  void _notifyPatientRefill(RefillAlert refill) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Refill prompt sent to ${_selectedPatient?.name} for ${refill.medicationName}.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = _selectedPatient;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Home Today',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('caretaker_notification_settings_button'),
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.textPrimary),
            tooltip: 'Notification Settings',
            onPressed: _openNotificationSettings,
          ),
          IconButton(
            key: const Key('accept_invitation_action_button'),
            icon: const Icon(Icons.person_add_alt_1_outlined,
                color: AppTheme.textPrimary),
            tooltip: 'Accept New Invitation',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => AcceptInvitationScreen(
                    onPatientLinked: (newPatient) {
                      setState(() {
                        if (!_linkedPatients.any((p) => p.id == newPatient.id)) {
                          _linkedPatients.add(newPatient);
                        }
                        _selectedPatientId = newPatient.id;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            key: const Key('caretaker_sign_out_button'),
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textPrimary),
            tooltip: 'Sign out',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => const CaretakerLoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Caretaker Greeting Banner
                  _buildCaretakerHeader(),
                  const SizedBox(height: 16),

                  // Linked Patient Selector Strip
                  _buildLinkedPatientSelector(),
                  const SizedBox(height: 16),

                  // Main Content based on patient consent state
                  if (patient == null)
                    _buildEmptyPatientsCard()
                  else if (patient.isPending)
                    _buildPendingConsentCard(patient)
                  else if (patient.isRevoked)
                    _buildRevokedConsentCard(patient)
                  else
                    ...[
                      // 1. Missed Dose Alert (if active)
                      if (patient.activeMissedDose != null) ...[
                        _buildMissedDoseAlertBanner(patient.activeMissedDose!),
                        const SizedBox(height: 16),
                      ],

                      // 2. Today's Dose Summary Card
                      _buildTodayDoseSummaryCard(patient),
                      const SizedBox(height: 16),

                      // 3. Next Medication Dose Card
                      _buildNextDoseCard(patient),
                      const SizedBox(height: 16),

                      // 4. Upcoming Appointments Card
                      _buildAppointmentsCard(patient),
                      const SizedBox(height: 16),

                      // 5. Refill Reminders Card
                      _buildRefillRemindersCard(patient),
                      const SizedBox(height: 20),
                    ],

                  // View-Only Role Notice
                  _buildViewOnlyDisclaimer(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION: HEADER & PATIENT SELECTOR
  // ==========================================
  Widget _buildCaretakerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 24,
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
                        widget.caretakerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Caregiver',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.caretakerRelationship,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedPatientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Linked Family Members',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('manage_linked_patients_button'),
              onPressed: _openManagePatientsSheet,
              icon: const Icon(Icons.tune_rounded, size: 14),
              label: const Text(
                'Manage',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _linkedPatients.map((p) {
              final isSelected = p.id == _selectedPatientId;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  key: Key('patient_chip_${p.id}'),
                  selected: isSelected,
                  avatar: Icon(
                    p.isApproved
                        ? Icons.check_circle_rounded
                        : (p.isPending
                            ? Icons.hourglass_top_rounded
                            : Icons.cancel_rounded),
                    size: 14,
                    color: p.isApproved
                        ? AppTheme.successGreen
                        : (p.isPending
                            ? const Color(0xFFF59E0B)
                            : AppTheme.errorRed),
                  ),
                  label: Text('${p.name} (${p.relationship})'),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryTealDark
                        : AppTheme.textPrimary,
                  ),
                  backgroundColor: AppTheme.surfaceWhite,
                  selectedColor: AppTheme.primaryTealLight,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryTeal
                        : AppTheme.cardBorder,
                  ),
                  onSelected: (_) => setState(() => _selectedPatientId = p.id),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 1: MISSED DOSE ALERT CARD
  // ==========================================
  Widget _buildMissedDoseAlertBanner(MissedDoseAlert alert) {
    return Container(
      key: const Key('caretaker_missed_dose_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.errorRed.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.errorRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Missed Medication Alert',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.isAcknowledged
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFFFEAEA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.isAcknowledged ? 'Acknowledged' : 'Needs Action',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: alert.isAcknowledged
                        ? const Color(0xFFB45309)
                        : AppTheme.errorRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${alert.patientName} missed scheduled dose of ${alert.medicationName} (${alert.dosage}) at ${alert.scheduledTime}.',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            key: const Key('review_missed_dose_button'),
            onPressed: () => _openMissedDoseSheet(alert),
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
            label: const Text('Review Alert & Follow Up'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: TODAY'S DOSE STATUS SUMMARY
  // ==========================================
  Widget _buildTodayDoseSummaryCard(CaregiverLinkedPatient patient) {
    int taken = 0;
    int missed = 0;
    int remaining = 0;

    for (final m in patient.medications) {
      if (m.isTakenToday) {
        taken++;
      } else if (m.isMissedToday) {
        missed++;
      } else {
        remaining++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_rounded,
                  color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${patient.name}\'s Doses Today',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildDoseMetric(
                label: 'Taken',
                count: taken,
                color: AppTheme.successGreen,
                bgColor: const Color(0xFFF0FDF4),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 10),
              _buildDoseMetric(
                label: 'Remaining',
                count: remaining,
                color: AppTheme.primaryTeal,
                bgColor: AppTheme.primaryTealLight,
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(width: 10),
              _buildDoseMetric(
                label: 'Missed',
                count: missed,
                color: AppTheme.errorRed,
                bgColor: const Color(0xFFFEF2F2),
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoseMetric({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 3: NEXT MEDICATION DOSE CARD
  // ==========================================
  Widget _buildNextDoseCard(CaregiverLinkedPatient patient) {
    final nextMed = patient.medications.firstWhere(
      (m) => !m.isTakenToday && !m.isMissedToday,
      orElse: () => patient.medications.isNotEmpty
          ? patient.medications.first
          : Medication(
              id: 'none',
              name: 'No Pending Dose',
              dosage: '--',
              frequency: MedicationFrequency.onceDaily,
              startDate: DateTime(2026, 1, 1),
              instructions: 'All scheduled doses complete for today',
              reminderTimes: const [],
              scheduledTimeSlot: '--',
            ),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alarm_on_rounded,
                  color: AppTheme.primaryTeal, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Next Scheduled Dose',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  nextMed.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nextMed.scheduledTimeSlot,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTealDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dosage: ${nextMed.dosage} • ${nextMed.purpose}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Instructions: ${nextMed.instructions}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: UPCOMING APPOINTMENTS
  // ==========================================
  Widget _buildAppointmentsCard(CaregiverLinkedPatient patient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upcoming Appointments (${patient.appointments.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (patient.appointments.isEmpty)
            const Text(
              'No upcoming appointments scheduled.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            )
          else
            ...patient.appointments.map((apt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apt.doctorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${apt.specialty} • ${apt.formattedDate} at ${apt.formattedTime}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${apt.clinicName} (${apt.visitType})',
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
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: REFILL REMINDERS
  // ==========================================
  Widget _buildRefillRemindersCard(CaregiverLinkedPatient patient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_liquid_rounded,
                  color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Prescription Refill Reminders',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Low Supply',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (patient.refillAlerts.isEmpty)
            const Text(
              'All prescriptions have sufficient supply.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            )
          else
            ...patient.refillAlerts.map((refill) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFB45309),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                refill.medicationName,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Only ${refill.pillsRemaining} pills remaining (~${refill.daysLeft} days)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        key: Key('notify_refill_${refill.id}_button'),
                        onPressed: () => _notifyPatientRefill(refill),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB45309),
                          side: const BorderSide(color: Color(0xFFB45309)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Remind Patient'),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION: SHIELDED CONSENT STATES
  // ==========================================
  Widget _buildPendingConsentCard(CaregiverLinkedPatient patient) {
    return Container(
      key: const Key('caretaker_pending_shield_card'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFB45309),
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Access Pending Patient Approval',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${patient.name} must approve your caretaker link in their MediCare AI app before health details can be displayed.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Text(
              'Patient Consent Rule: In compliance with HIPAA and patient rights, no doses, vitals, or appointments can be viewed without active patient authorization.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            key: const Key('simulate_patient_approves_link_button'),
            onPressed: () {
              _handleStatusChanged(patient.id, CaregiverLinkStatus.approved);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.successGreen,
                  behavior: SnackBarBehavior.floating,
                  content: Text('${patient.name} approved access request.'),
                ),
              );
            },
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Simulate: Patient Approves Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevokedConsentCard(CaregiverLinkedPatient patient) {
    return Container(
      key: const Key('caretaker_revoked_shield_card'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEAEA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_accounts_rounded,
                color: AppTheme.errorRed,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Access Revoked by Patient',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${patient.name} has revoked caretaker sharing permissions. All health records, medication schedules, and appointment updates are hidden.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('remove_revoked_patient_button'),
            onPressed: () => _handleRequestRemoval(patient.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove from Caregiver Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPatientsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.people_outline_rounded,
              size: 40, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'No Linked Patients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter an invitation code from a family member to link their care portal.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => AcceptInvitationScreen(
                    onPatientLinked: (newPatient) {
                      setState(() {
                        _linkedPatients.add(newPatient);
                        _selectedPatientId = newPatient.id;
                      });
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Accept Invitation Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOnlyDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: AppTheme.primaryTeal),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Caregiver Permissions: You can view medication schedules, acknowledge alerts, and remind patients. Caregivers cannot create, prescribe, or edit medications.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.primaryTealDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
