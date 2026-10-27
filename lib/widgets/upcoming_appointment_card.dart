import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';

/// Section 5: Upcoming Appointment Card
/// Displays doctor name, specialty, date, time, and an interactive details action.
class UpcomingAppointmentCard extends StatelessWidget {
  final Appointment? appointment;
  final ValueChanged<Appointment>? onDetailsPressed;
  final VoidCallback? onBookAppointment;

  const UpcomingAppointmentCard({
    super.key,
    required this.appointment,
    this.onDetailsPressed,
    this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    if (appointment == null) {
      return _buildNoAppointmentState();
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 20,
                        color: AppTheme.primaryTeal,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Upcoming Appointment',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF8F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: AppTheme.successGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Confirmed',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.cardBorder),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor & Specialty
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment!.doctorName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment!.specialty,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment!.clinicName,
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
                const SizedBox(height: 14),
                // Date & Time Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment!.formattedDate,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 16,
                        color: AppTheme.cardBorder,
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointment!.formattedTime,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Details Action Button (accessible 48dp target)
                OutlinedButton.icon(
                  key: const Key('appointment_details_button'),
                  onPressed: onDetailsPressed != null
                      ? () => onDetailsPressed!(appointment!)
                      : null,
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('View Appointment Details & Prep'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryTeal,
                    side: const BorderSide(color: AppTheme.primaryTeal),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAppointmentState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F5F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  color: AppTheme.textSecondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No upcoming appointments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'You have no scheduled clinical visits at this time.',
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
          if (onBookAppointment != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onBookAppointment,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Schedule New Visit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
