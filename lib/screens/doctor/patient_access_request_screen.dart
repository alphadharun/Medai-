import 'package:flutter/material.dart';
import '../../models/patient_access.dart';
import '../../theme/app_theme.dart';

/// Screen displayed after successful doctor login.
/// Allows doctor to select a mock patient and request access for a stated clinical purpose.
/// Enforces the patient-consent rule: Patient must approve access,
/// and caregivers cannot approve access on the patient's behalf.
class PatientAccessRequestScreen extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final VoidCallback? onSignOut;

  const PatientAccessRequestScreen({
    super.key,
    this.doctorName = 'Dr. Eleanor Vance, MD',
    this.doctorSpecialty = 'Cardiology & Internal Medicine',
    this.onSignOut,
  });

  @override
  State<PatientAccessRequestScreen> createState() =>
      _PatientAccessRequestScreenState();
}

class _PatientAccessRequestScreenState
    extends State<PatientAccessRequestScreen> {
  late MockPatientProfile _selectedPatient;
  String _selectedPurpose = 'Cardiology Consultation & Medication Review';
  final _purposeNotesController = TextEditingController(
    text: 'Reviewing recent antihypertensive response and blood pressure logs.',
  );
  bool _notifyCaregiverIfAuthorized = true;

  AccessRequestStatus _requestStatus = AccessRequestStatus.notRequested;
  bool _isSubmitting = false;

  final List<String> _purposeOptions = [
    'Cardiology Consultation & Medication Review',
    'Urgent Triage & EHR History Review',
    'Pre-Operative Cardiac Clearance',
    'Routine Annual Health Examination',
    'Diagnostic Follow-up & Lab Evaluation',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatient = MockPatientDirectory.patients.first;
  }

  @override
  void dispose() {
    _purposeNotesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _requestStatus = AccessRequestStatus.pending;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Access request sent to ${_selectedPatient.name} for patient approval.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePatientDecision(bool approved) {
    setState(() {
      _requestStatus = approved
          ? AccessRequestStatus.approved
          : AccessRequestStatus.declined;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor:
            approved ? AppTheme.successGreen : AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              approved ? Icons.verified_rounded : Icons.block_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                approved
                    ? '${_selectedPatient.name} approved access request.'
                    : '${_selectedPatient.name} declined access request.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetRequest() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _requestStatus = AccessRequestStatus.notRequested;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: Tooltip(
          message: 'Sign out of doctor session',
          child: IconButton(
            key: const Key('doctor_sign_out_button'),
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
            onPressed: () {
              if (widget.onSignOut != null) {
                widget.onSignOut!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: const Text('Patient Access Request'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryTealLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryTeal.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded,
                    size: 14, color: AppTheme.primaryTeal),
                SizedBox(width: 4),
                Text(
                  'MD Session',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTealDark,
                  ),
                ),
              ],
            ),
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
                  // Doctor Profile Banner
                  _buildDoctorBanner(),

                  const SizedBox(height: 16),

                  // State Machine View
                  if (_requestStatus == AccessRequestStatus.notRequested)
                    _buildRequestFormView()
                  else if (_requestStatus == AccessRequestStatus.pending)
                    _buildPendingStateView()
                  else if (_requestStatus == AccessRequestStatus.approved)
                    _buildApprovedStateView()
                  else if (_requestStatus == AccessRequestStatus.declined)
                    _buildDeclinedStateView(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  widget.doctorSpecialty,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 1: REQUEST FORM VIEW
  // ==========================================
  Widget _buildRequestFormView() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.person_search_rounded,
                  color: AppTheme.primaryTeal, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Select Patient for Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Patient Selector Dropdown
          DropdownButtonFormField<MockPatientProfile>(
            key: const Key('patient_selector_dropdown'),
            initialValue: _selectedPatient,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Target Patient',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            items: MockPatientDirectory.patients.map((patient) {
              return DropdownMenuItem(
                value: patient,
                child: Text(
                  '${patient.name} (${patient.mrn}) • Age ${patient.age}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedPatient = val);
              }
            },
          ),
          const SizedBox(height: 16),

          // Caregiver Authorization Status Card
          _buildCaregiverConsentCard(),

          const SizedBox(height: 16),

          // Clinical Purpose Dropdown
          const Text(
            'Clinical Purpose for Record Access *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: const Key('purpose_selector_dropdown'),
            initialValue: _selectedPurpose,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
            items: _purposeOptions.map((purpose) {
              return DropdownMenuItem(
                value: purpose,
                child: Text(
                  purpose,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedPurpose = val);
              }
            },
          ),
          const SizedBox(height: 14),

          // Clinical Purpose Notes
          const Text(
            'Justification & Clinical Notes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('purpose_notes_input'),
            controller: _purposeNotesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Provide concise reason for EHR access request...',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 18),

          // HIPAA / Patient Consent Rule Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryTeal.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel_rounded,
                    size: 18, color: AppTheme.primaryTeal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Consent Rule: The patient must approve access directly. A caregiver cannot approve on the patient\'s behalf.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTealDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Submit Access Request Button
          ElevatedButton.icon(
            key: const Key('submit_access_request_button'),
            onPressed: _isSubmitting ? null : _submitRequest,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(_isSubmitting ? 'Submitting...' : 'Request Patient Access'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverConsentCard() {
    if (_selectedPatient.hasAuthorizedCaregiver) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.family_restroom_rounded,
                    color: AppTheme.primaryTeal, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Authorized Caregiver: ${_selectedPatient.caregiverName}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Relationship: ${_selectedPatient.caregiverRelationship}\nPhone: ${_selectedPatient.caregiverPhone}',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const Divider(height: 16, color: AppTheme.cardBorder),
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                key: const Key('notify_caregiver_checkbox'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _notifyCaregiverIfAuthorized,
                activeColor: AppTheme.primaryTeal,
                title: const Text(
                  'Send courtesy notification to caregiver',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Caregiver will be alerted of this request, but cannot approve it.',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
                onChanged: (val) {
                  setState(() => _notifyCaregiverIfAuthorized = val ?? false);
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.person_off_outlined,
                color: AppTheme.textSecondary, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Caregiver Authorized',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'This patient has not authorized caregiver sharing. Notification and approval will be routed strictly to the patient.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ==========================================
  // VIEW 2: PENDING STATE VIEW
  // ==========================================
  Widget _buildPendingStateView() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Clock / Pending Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFB45309),
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Access Request Pending',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Waiting for ${_selectedPatient.name} to approve request on their patient portal.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),

          // Request Summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryLine('Patient', '${_selectedPatient.name} (${_selectedPatient.mrn})'),
                const SizedBox(height: 6),
                _buildSummaryLine('Purpose', _selectedPurpose),
                const SizedBox(height: 6),
                _buildSummaryLine(
                  'Caregiver Status',
                  _selectedPatient.hasAuthorizedCaregiver && _notifyCaregiverIfAuthorized
                      ? 'Notified: ${_selectedPatient.caregiverName} (Courtesy only - cannot approve)'
                      : 'None notified',
                ),
                const Divider(height: 16, color: Color(0xFFFDE68A)),
                const Text(
                  'Privacy Shield Active: Patient clinical information and records remain hidden until approval is granted.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Demo Controls to simulate Patient response
          const Text(
            'Demo Simulation Controls:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('simulate_approve_button'),
                  onPressed: () => _simulatePatientDecision(true),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Patient Approves'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('simulate_decline_button'),
                  onPressed: () => _simulatePatientDecision(false),
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  label: const Text('Patient Declines'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _resetRequest,
            child: const Text('Cancel and return to patient selection'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 3: APPROVED STATE VIEW (Patient Info Displayed)
  // ==========================================
  Widget _buildApprovedStateView() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successGreen),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Approved Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.successGreen, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Access Granted by Patient',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      Text(
                        'Approval recorded at ${TimeOfDay.now().format(context)} today.',
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
          const SizedBox(height: 18),

          // DISPLAY PATIENT INFORMATION (Only in approved state)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _selectedPatient.name,
                  style: const TextStyle(
                    fontSize: 20,
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
                  _selectedPatient.mrn,
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
            'Age: ${_selectedPatient.age} • Gender: ${_selectedPatient.gender} • Blood: ${_selectedPatient.bloodType}',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Vitals Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FAF9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Clinical Vitals',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTealDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _selectedPatient.recentVitals,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Active Diagnoses
          const Text(
            'Active Diagnoses & Conditions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          ..._selectedPatient.activeConditions.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: AppTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Active Prescriptions
          const Text(
            'Current Medications',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          ..._selectedPatient.currentMedications.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.medication_rounded,
                      size: 16, color: AppTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // End Session Button
          ElevatedButton.icon(
            key: const Key('conclude_session_button'),
            onPressed: _resetRequest,
            icon: const Icon(Icons.lock_rounded, size: 18),
            label: const Text('Conclude Consultation & Lock Records'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 4: DECLINED STATE VIEW
  // ==========================================
  Widget _buildDeclinedStateView() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorRed),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEAEA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block_rounded,
                color: AppTheme.errorRed,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Access Request Declined',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_selectedPatient.name} declined to grant access to health records for this session.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD5D5)),
            ),
            child: const Text(
              'Patient Consent Protection: In accordance with HIPAA & Patient Rights, no health records, medications, or diagnoses are displayed. If access is needed urgently, contact the clinic administrator.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.errorRed,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            key: const Key('try_another_request_button'),
            onPressed: _resetRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Select Another Patient or Purpose'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
