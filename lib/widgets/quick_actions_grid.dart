import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section 4: Quick Actions
/// 4 accessible action cards:
/// 1. Scan Prescription
/// 2. Add Medication Manually
/// 3. View Medication Schedule
/// 4. View Medication History
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onScanPrescription;
  final VoidCallback onAddMedication;
  final VoidCallback onViewSchedule;
  final VoidCallback onViewHistory;

  const QuickActionsGrid({
    super.key,
    required this.onScanPrescription,
    required this.onAddMedication,
    required this.onViewSchedule,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.bolt_rounded,
              size: 20,
              color: AppTheme.primaryTeal,
            ),
            SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 2x2 Grid of Actions
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                key: const Key('quick_action_scan_rx'),
                title: 'Scan Prescription',
                subtitle: 'AI bottle scanner',
                icon: Icons.document_scanner_rounded,
                accentColor: AppTheme.primaryTeal,
                backgroundColor: AppTheme.primaryTealLight,
                onTap: onScanPrescription,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                key: const Key('quick_action_add_med'),
                title: 'Add Medication',
                subtitle: 'Manual entry',
                icon: Icons.add_circle_outline_rounded,
                accentColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEFF6FF),
                onTap: onAddMedication,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                key: const Key('quick_action_schedule'),
                title: 'Med Schedule',
                subtitle: 'Timetable & slots',
                icon: Icons.calendar_month_rounded,
                accentColor: const Color(0xFF0F766E),
                backgroundColor: const Color(0xFFE6F4F1),
                onTap: onViewSchedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                key: const Key('quick_action_history'),
                title: 'Med History',
                subtitle: 'Past 30 days log',
                icon: Icons.history_rounded,
                accentColor: const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFFF5F3FF),
                onTap: onViewHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: accentColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
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
