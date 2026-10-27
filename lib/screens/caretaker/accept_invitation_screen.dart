import 'package:flutter/material.dart';
import '../../models/caretaker_access.dart';
import '../../theme/app_theme.dart';
import 'caretaker_dashboard_screen.dart';

/// Screen allowing caretakers to enter and process an invitation code.
/// Highlights patient consent mandate and supports pending, accepted, and invalid states.
enum InvitationCodeState {
  initial,
  pending,
  accepted,
  invalid,
}

class AcceptInvitationScreen extends StatefulWidget {
  final ValueChanged<CaregiverLinkedPatient>? onPatientLinked;

  const AcceptInvitationScreen({
    super.key,
    this.onPatientLinked,
  });

  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  InvitationCodeState _state = InvitationCodeState.initial;
  bool _isProcessing = false;
  String? _errorMessage;
  CaregiverLinkedPatient? _resolvedPatient;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _processCode(String inputCode) async {
    final code = inputCode.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an invitation code';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (code == 'CARE-8492') {
      // Sarah Jenkins: already accepted / approved link
      setState(() {
        _state = InvitationCodeState.accepted;
        _resolvedPatient = MockCaretakerDirectory.getInitialLinkedPatients()[0];
      });
      widget.onPatientLinked?.call(_resolvedPatient!);
    } else if (code == 'CARE-5921') {
      // Robert Chen: submitted, waiting for patient approval
      setState(() {
        _state = InvitationCodeState.pending;
        _resolvedPatient = MockCaretakerDirectory.getInitialLinkedPatients()[1];
      });
      widget.onPatientLinked?.call(_resolvedPatient!);
    } else if (code == 'CARE-7711') {
      // New Invitation: enters pending state first
      setState(() {
        _state = InvitationCodeState.pending;
        _resolvedPatient = const CaregiverLinkedPatient(
          id: 'patient_david',
          name: 'David Miller',
          relationship: 'Father',
          age: 72,
          gender: 'Male',
          mrn: 'MRN-771142',
          phone: '(555) 667-1122',
          linkStatus: CaregiverLinkStatus.pending,
          linkedSince: 'Oct 23, 2026',
          medications: [],
          appointments: [],
          activeMissedDose: null,
          refillAlerts: [],
        );
      });
      widget.onPatientLinked?.call(_resolvedPatient!);
    } else {
      // Invalid code
      setState(() {
        _state = InvitationCodeState.invalid;
        _errorMessage =
            'Invalid or expired code "$code". Please check with the patient or request a new invite.';
        _resolvedPatient = null;
      });
    }
  }

  void _simulatePatientApproval() {
    if (_resolvedPatient == null) return;
    setState(() {
      _state = InvitationCodeState.accepted;
      _resolvedPatient = _resolvedPatient!.copyWith(
        linkStatus: CaregiverLinkStatus.approved,
      );
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_resolvedPatient!.name} has approved your caregiver access!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetInput() {
    setState(() {
      _state = InvitationCodeState.initial;
      _errorMessage = null;
      _codeController.clear();
      _resolvedPatient = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Accept Caretaker Invitation'),
        centerTitle: true,
        leading: IconButton(
          key: const Key('invitation_back_button'),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Consent Notice Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF8F7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.gavel_rounded,
                            size: 20, color: AppTheme.primaryTeal),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Consent Mandate',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTealDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'A caregiver cannot approve access on a patient\'s behalf. Once you submit a code, the patient must approve the link before health details are shown.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // State-based View Rendering
                  if (_state == InvitationCodeState.initial)
                    _buildCodeInputCard()
                  else if (_state == InvitationCodeState.pending)
                    _buildPendingStateCard()
                  else if (_state == InvitationCodeState.accepted)
                    _buildAcceptedStateCard()
                  else if (_state == InvitationCodeState.invalid)
                    _buildInvalidStateCard(),

                  const SizedBox(height: 20),

                  // Demo Quick-Fill Codes
                  _buildDemoCodesCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: CODE INPUT CARD
  // ==========================================
  Widget _buildCodeInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.key_rounded, color: AppTheme.primaryTeal, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter Caretaker Invitation Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the 8-character invitation code provided by the patient or their clinic.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('invitation_code_field'),
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'e.g. CARE-8492',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                suffixIcon: _codeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _codeController.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('submit_invitation_code_button'),
              onPressed: _isProcessing
                  ? null
                  : () => _processCode(_codeController.text),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 20),
              label: Text(_isProcessing ? 'Verifying...' : 'Verify & Request Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 2: PENDING STATE CARD
  // ==========================================
  Widget _buildPendingStateCard() {
    return Container(
      key: const Key('invitation_pending_card'),
      padding: const EdgeInsets.all(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            'Link Invitation Submitted',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Waiting for ${_resolvedPatient?.name ?? 'the patient'} to approve your caretaker access request.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Patient Name', _resolvedPatient?.name ?? 'Unknown'),
                const SizedBox(height: 6),
                _buildInfoRow('Record MRN', _resolvedPatient?.mrn ?? 'Pending'),
                const SizedBox(height: 6),
                _buildInfoRow('Link Status', 'Pending Patient Approval'),
                const Divider(height: 16, color: Color(0xFFFDE68A)),
                const Text(
                  'Privacy Shield: Health records, prescriptions, and upcoming appointments are obscured until the patient approves.',
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
          ElevatedButton.icon(
            key: const Key('simulate_patient_approval_button'),
            onPressed: _simulatePatientApproval,
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Simulate: Patient Approves Access'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _resetInput,
            child: const Text('Try Another Code'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 3: ACCEPTED STATE CARD
  // ==========================================
  Widget _buildAcceptedStateCard() {
    return Container(
      key: const Key('invitation_accepted_card'),
      padding: const EdgeInsets.all(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: AppTheme.successGreen,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Caregiver Access Granted',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_resolvedPatient?.name ?? 'The patient'} has approved your caretaker link.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Patient', _resolvedPatient?.name ?? 'Sarah Jenkins'),
                const SizedBox(height: 6),
                _buildInfoRow('Relationship', _resolvedPatient?.relationship ?? 'Mother'),
                const SizedBox(height: 6),
                _buildInfoRow('Access Level', 'Dose Tracking & Appointment Alerts (View-Only)'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            key: const Key('open_caretaker_dashboard_button'),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => CaretakerDashboardScreen(
                    caretakerName: 'Mark Jenkins',
                    caretakerRelationship: 'Authorized Family Caregiver',
                    initialPatient: _resolvedPatient,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.dashboard_rounded, size: 18),
            label: const Text('Open Caretaker Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 4: INVALID STATE CARD
  // ==========================================
  Widget _buildInvalidStateCard() {
    return Container(
      key: const Key('invitation_invalid_card'),
      padding: const EdgeInsets.all(22),
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
                Icons.error_outline_rounded,
                color: AppTheme.errorRed,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Invalid Invitation Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'The invitation code is invalid or has expired.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: const Key('try_again_button'),
            onPressed: _resetInput,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Another Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCodesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.tune_rounded, size: 16, color: AppTheme.primaryTeal),
              SizedBox(width: 8),
              Text(
                'Demo Invitation Codes',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                key: const Key('chip_code_approved'),
                avatar: const Icon(Icons.verified_rounded,
                    size: 16, color: AppTheme.successGreen),
                label: const Text('CARE-8492 (Approved)'),
                backgroundColor: const Color(0xFFF0FDF4),
                side: const BorderSide(color: AppTheme.successGreen),
                onPressed: () {
                  _codeController.text = 'CARE-8492';
                  _processCode('CARE-8492');
                },
              ),
              ActionChip(
                key: const Key('chip_code_pending'),
                avatar: const Icon(Icons.hourglass_top_rounded,
                    size: 16, color: Color(0xFFF59E0B)),
                label: const Text('CARE-5921 (Pending)'),
                backgroundColor: const Color(0xFFFEF9C3),
                side: const BorderSide(color: Color(0xFFF59E0B)),
                onPressed: () {
                  _codeController.text = 'CARE-5921';
                  _processCode('CARE-5921');
                },
              ),
              ActionChip(
                key: const Key('chip_code_new_pending'),
                avatar: const Icon(Icons.add_rounded,
                    size: 16, color: AppTheme.primaryTeal),
                label: const Text('CARE-7711 (New Invite)'),
                backgroundColor: AppTheme.primaryTealLight,
                side: const BorderSide(color: AppTheme.primaryTeal),
                onPressed: () {
                  _codeController.text = 'CARE-7711';
                  _processCode('CARE-7711');
                },
              ),
              ActionChip(
                key: const Key('chip_code_invalid'),
                avatar: const Icon(Icons.cancel_rounded,
                    size: 16, color: AppTheme.errorRed),
                label: const Text('CARE-0000 (Invalid)'),
                backgroundColor: const Color(0xFFFEF2F2),
                side: const BorderSide(color: AppTheme.errorRed),
                onPressed: () {
                  _codeController.text = 'CARE-0000';
                  _processCode('CARE-0000');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
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
          flex: 3,
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
