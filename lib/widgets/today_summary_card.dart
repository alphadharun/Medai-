import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section 2: Today's Medication Summary
/// Displays doses taken, remaining, and missed with visual progress.
class TodaySummaryCard extends StatelessWidget {
  final int takenCount;
  final int remainingCount;
  final int missedCount;
  final VoidCallback? onTap;

  const TodaySummaryCard({
    super.key,
    required this.takenCount,
    required this.remainingCount,
    required this.missedCount,
    this.onTap,
  });

  int get totalDoses => takenCount + remainingCount + missedCount;
  double get completionProgress =>
      totalDoses == 0 ? 0.0 : (takenCount / totalDoses).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Progress Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      size: 20,
                      color: AppTheme.primaryTeal,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Today's Medication Summary",
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalDoses == 0
                      ? 'No doses'
                      : '${(completionProgress * 100).toInt()}% Done',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTealDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Subtle Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: completionProgress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE7ECEB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          ),
          const SizedBox(height: 16),
          // Three Stat Tiles: Taken, Remaining, Missed
          Row(
            children: [
              Expanded(
                child: _DoseStatTile(
                  key: const Key('summary_taken_tile'),
                  label: 'Taken',
                  count: takenCount,
                  icon: Icons.check_circle_rounded,
                  accentColor: AppTheme.successGreen,
                  backgroundColor: const Color(0xFFEDF8F1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DoseStatTile(
                  key: const Key('summary_remaining_tile'),
                  label: 'Remaining',
                  count: remainingCount,
                  icon: Icons.hourglass_top_rounded,
                  accentColor: const Color(0xFF0F766E),
                  backgroundColor: const Color(0xFFE8F6F4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DoseStatTile(
                  key: const Key('summary_missed_tile'),
                  label: 'Missed',
                  count: missedCount,
                  icon: Icons.warning_amber_rounded,
                  accentColor: const Color(0xFFC2410C),
                  backgroundColor: const Color(0xFFFEF3EC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoseStatTile extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  const _DoseStatTile({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 5),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
