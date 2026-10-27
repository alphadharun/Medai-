import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal dialog shown upon successful demo sign-in.
class LoginSuccessDialog extends StatelessWidget {
  final String accountIdentifier;
  final VoidCallback onDismiss;

  const LoginSuccessDialog({
    super.key,
    required this.accountIdentifier,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String accountIdentifier,
    required VoidCallback onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginSuccessDialog(
        accountIdentifier: accountIdentifier,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 6,
      backgroundColor: AppTheme.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reassuring Green Shield / Check Icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F6EF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome back!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have securely signed in as:\n$accountIdentifier',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            // Security affirmation badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 16,
                    color: AppTheme.primaryTeal,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '256-bit Encrypted Patient Session',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('continue_dashboard_button'),
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss();
              },
              child: const Text('Continue to Health Portal (Demo)'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
