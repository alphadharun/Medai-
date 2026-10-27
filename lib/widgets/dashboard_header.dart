import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section 1: Dashboard Header
/// Friendly time-appropriate greeting, patient name, and profile/settings button.
class DashboardHeader extends StatelessWidget {
  final String patientName;
  final VoidCallback onProfilePressed;
  final VoidCallback? onNotificationPressed;

  const DashboardHeader({
    super.key,
    required this.patientName,
    required this.onProfilePressed,
    this.onNotificationPressed,
  });

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting & Patient Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTimeGreeting(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Notification Bell with badge
          IconButton(
            key: const Key('dashboard_notifications_button'),
            tooltip: 'Medication alerts & reminders',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppTheme.textPrimary,
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              if (onNotificationPressed != null) {
                onNotificationPressed!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All medication reminders are up to date.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 4),
          // Patient Avatar / Profile Button (Large accessible 44x44 target)
          Tooltip(
            message: 'View profile & settings',
            child: InkWell(
              key: const Key('dashboard_profile_button'),
              onTap: onProfilePressed,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, Color(0xFF1B8E8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SJ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
