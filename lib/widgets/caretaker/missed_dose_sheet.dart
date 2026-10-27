import 'package:flutter/material.dart';
import '../../models/caretaker_access.dart';
import '../../theme/app_theme.dart';

/// Modal bottom sheet displaying detailed missed-dose alert information.
/// Provides actions to acknowledge, contact the patient, and mark follow-up complete.
class MissedDoseDetailSheet extends StatefulWidget {
  final MissedDoseAlert alert;
  final ValueChanged<MissedDoseAlert> onAlertUpdated;
  final VoidCallback onDismiss;

  const MissedDoseDetailSheet({
    super.key,
    required this.alert,
    required this.onAlertUpdated,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required MissedDoseAlert alert,
    required ValueChanged<MissedDoseAlert> onAlertUpdated,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MissedDoseDetailSheet(
        alert: alert,
        onAlertUpdated: onAlertUpdated,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<MissedDoseDetailSheet> createState() => _MissedDoseDetailSheetState();
}

class _MissedDoseDetailSheetState extends State<MissedDoseDetailSheet> {
  late MissedDoseAlert _currentAlert;
  final _noteController = TextEditingController();
  bool _isContacting = false;

  @override
  void initState() {
    super.initState();
    _currentAlert = widget.alert;
    _noteController.text = _currentAlert.followUpNote ??
        'Spoke with ${_currentAlert.patientName}; confirmed dose taken with water.';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _acknowledgeAlert() {
    setState(() {
      _currentAlert = _currentAlert.copyWith(
        isAcknowledged: true,
        acknowledgedAt: DateTime.now(),
      );
    });
    widget.onAlertUpdated(_currentAlert);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Alert acknowledged by caregiver.'),
            ),
          ],
        ),
      ),
    );
  }

  void _contactPatient() async {
    setState(() => _isContacting = true);

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isContacting = false);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Contact ${_currentAlert.patientName}'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Direct Phone: ${_currentAlert.patientPhone}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Simulated Message:\n"Hi ${_currentAlert.patientName}, your MediCare AI reminder shows your ${_currentAlert.medicationName} (${_currentAlert.dosage}) was due at ${_currentAlert.scheduledTime}. Have you taken it?"',
                style: const TextStyle(fontSize: 12.5, color: AppTheme.primaryTealDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.successGreen,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                      'Automated medication check sent to ${_currentAlert.patientName}.'),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send Reminder SMS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _markFollowUpComplete() {
    setState(() {
      _currentAlert = _currentAlert.copyWith(
        isAcknowledged: true,
        isFollowUpComplete: true,
        followUpNote: _noteController.text.trim(),
        completedAt: DateTime.now(),
      );
    });
    widget.onAlertUpdated(_currentAlert);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.task_alt_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Follow-up marked complete for ${_currentAlert.medicationName}.'),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop();
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notification_important_rounded,
                    color: AppTheme.errorRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Missed-Dose Alert Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Patient: ${_currentAlert.patientName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Medication & Scheduled Time Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD5D5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _currentAlert.medicationName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEAEA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorRed),
                        ),
                        child: const Text(
                          'Missed Dose',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dosage: ${_currentAlert.dosage} • Scheduled Time: ${_currentAlert.scheduledTime}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient Direct Phone: ${_currentAlert.patientPhone}',
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Status Progress
            Row(
              children: [
                _buildStatusStepChip(
                  label: 'Acknowledged',
                  isDone: _currentAlert.isAcknowledged,
                ),
                const SizedBox(width: 8),
                _buildStatusStepChip(
                  label: 'Follow-Up Complete',
                  isDone: _currentAlert.isFollowUpComplete,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ACTION 1: Acknowledge Alert
            ElevatedButton.icon(
              key: const Key('acknowledge_alert_button'),
              onPressed: _currentAlert.isAcknowledged ? null : _acknowledgeAlert,
              icon: Icon(
                _currentAlert.isAcknowledged
                    ? Icons.check_circle_rounded
                    : Icons.check_rounded,
                size: 18,
              ),
              label: Text(
                _currentAlert.isAcknowledged
                    ? 'Alert Acknowledged'
                    : '1. Acknowledge Alert',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ACTION 2: Contact the Patient
            OutlinedButton.icon(
              key: const Key('contact_patient_button'),
              onPressed: _isContacting ? null : _contactPatient,
              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
              label: Text('2. Contact ${_currentAlert.patientName} (Call / SMS)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ACTION 3: Mark Follow-Up Complete
            const Text(
              '3. Caregiver Follow-Up Notes',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('follow_up_note_input'),
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Record outcome of patient contact...',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              key: const Key('mark_follow_up_complete_button'),
              onPressed: _markFollowUpComplete,
              icon: const Icon(Icons.task_alt_rounded, size: 18),
              label: const Text('Mark Follow-Up Complete & Clear Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
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

  Widget _buildStatusStepChip({required String label, required bool isDone}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFEDF8F1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDone ? AppTheme.successGreen : AppTheme.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 14,
              color: isDone ? AppTheme.successGreen : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppTheme.successGreen : AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
