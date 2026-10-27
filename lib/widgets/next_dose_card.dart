import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../theme/app_theme.dart';

/// Section 3: Next Dose Card
/// Displays the very next upcoming dose with medicine name, dosage,
/// scheduled time, reminder status, and quick action buttons.
class NextDoseCard extends StatelessWidget {
  final Medication? nextDose;
  final ValueChanged<Medication>? onTakeDose;
  final ValueChanged<Medication>? onSnoozeDose;

  const NextDoseCard({
    super.key,
    required this.nextDose,
    this.onTakeDose,
    this.onSnoozeDose,
  });

  @override
  Widget build(BuildContext context) {
    if (nextDose == null) {
      return _buildAllCaughtUpEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ribbon: "Next Dose" + Time Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.primaryTealLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.alarm_on_rounded,
                      size: 18,
                      color: AppTheme.primaryTealDark,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'NEXT DOSE',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        nextDose!.scheduledTimeSlot,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Name & Dosage
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        size: 28,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextDose!.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dosage: ${nextDose!.dosage}',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextDose!.instructions,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Reminder Status Indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reminder scheduled for ${nextDose!.scheduledTimeSlot} (Chime + Push)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons: Snooze & Take Dose (50dp tall)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        key: const Key('snooze_dose_button'),
                        onPressed: onSnoozeDose != null
                            ? () => onSnoozeDose!(nextDose!)
                            : null,
                        icon: const Icon(Icons.snooze_rounded, size: 18),
                        label: const Text('Snooze 15m'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.cardBorder),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        key: const Key('take_dose_button'),
                        onPressed: onTakeDose != null
                            ? () => onTakeDose!(nextDose!)
                            : null,
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('Take Dose'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCaughtUpEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEDF8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: AppTheme.successGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All caught up for today!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No more doses scheduled for the remainder of today.',
                  style: TextStyle(
                    fontSize: 13,
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
}
