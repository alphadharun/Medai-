import 'package:flutter/material.dart';
import '../../models/caretaker_access.dart';
import '../../theme/app_theme.dart';

/// Modal bottom sheet allowing caretakers to configure alerts for missed doses, appointments, and refills.
class NotificationSettingsSheet extends StatefulWidget {
  final CaretakerNotificationPreferences initialPreferences;
  final ValueChanged<CaretakerNotificationPreferences> onSaved;

  const NotificationSettingsSheet({
    super.key,
    required this.initialPreferences,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required CaretakerNotificationPreferences initialPreferences,
    required ValueChanged<CaretakerNotificationPreferences> onSaved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => NotificationSettingsSheet(
        initialPreferences: initialPreferences,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  late bool _missedDoses;
  late bool _appointments;
  late bool _refills;
  late bool _dailySummary;

  @override
  void initState() {
    super.initState();
    _missedDoses = widget.initialPreferences.missedDoses;
    _appointments = widget.initialPreferences.appointments;
    _refills = widget.initialPreferences.refills;
    _dailySummary = widget.initialPreferences.dailySummary;
  }

  void _savePreferences() {
    final updated = CaretakerNotificationPreferences(
      missedDoses: _missedDoses,
      appointments: _appointments,
      refills: _refills,
      dailySummary: _dailySummary,
    );
    widget.onSaved(updated);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        content: Text('Notification preferences saved.'),
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
          const Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  color: AppTheme.primaryTeal, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Caretaker Notification Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Control which real-time alerts you receive for linked family members.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Setting 1: Missed Doses
          _buildSwitchOption(
            key: const Key('toggle_missed_doses_switch'),
            title: 'Missed-Dose Alerts',
            subtitle: 'Instant push & SMS alerts when a scheduled medication is missed',
            value: _missedDoses,
            onChanged: (val) => setState(() => _missedDoses = val),
          ),
          const Divider(height: 16, color: AppTheme.cardBorder),

          // Setting 2: Upcoming Appointments
          _buildSwitchOption(
            key: const Key('toggle_appointments_switch'),
            title: 'Upcoming Appointment Reminders',
            subtitle: 'Reminders 24 hours and 2 hours before doctor consultations',
            value: _appointments,
            onChanged: (val) => setState(() => _appointments = val),
          ),
          const Divider(height: 16, color: AppTheme.cardBorder),

          // Setting 3: Refill Reminders
          _buildSwitchOption(
            key: const Key('toggle_refills_switch'),
            title: 'Prescription Refill Alerts',
            subtitle: 'Warnings when patient medication supply drops below 5 days',
            value: _refills,
            onChanged: (val) => setState(() => _refills = val),
          ),
          const Divider(height: 16, color: AppTheme.cardBorder),

          // Setting 4: Daily Summary
          _buildSwitchOption(
            key: const Key('toggle_daily_summary_switch'),
            title: 'Daily Care Digest',
            subtitle: 'Morning overview of patient medication schedule and vitals',
            value: _dailySummary,
            onChanged: (val) => setState(() => _dailySummary = val),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            key: const Key('save_notification_settings_button'),
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Notification Preferences'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption({
    required Key key,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        key: key,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        value: value,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.primaryTeal,
        onChanged: onChanged,
      ),
    );
  }
}
