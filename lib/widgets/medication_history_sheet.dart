import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet showing patient's past 7-day adherence and medication history.
class MedicationHistorySheet extends StatelessWidget {
  const MedicationHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MedicationHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyLogs = [
      {
        'date': 'Today, Oct 23',
        'med': 'Metformin 500mg',
        'status': 'Taken at 08:15 AM',
        'success': true,
      },
      {
        'date': 'Today, Oct 23',
        'med': 'Lisinopril 10mg',
        'status': 'Taken at 08:10 AM',
        'success': true,
      },
      {
        'date': 'Yesterday, Oct 22',
        'med': 'Atorvastatin 20mg',
        'status': 'Taken at 08:05 PM',
        'success': true,
      },
      {
        'date': 'Yesterday, Oct 22',
        'med': 'Metformin 500mg',
        'status': 'Taken at 08:20 AM',
        'success': true,
      },
      {
        'date': 'Wednesday, Oct 21',
        'med': 'Calcium + Vit D3',
        'status': 'Missed dose (Traveling)',
        'success': false,
      },
      {
        'date': 'Wednesday, Oct 21',
        'med': 'Metformin 500mg',
        'status': 'Taken at 08:30 AM',
        'success': true,
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppTheme.primaryTeal,
                size: 26,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medication History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Past dose confirmations & adherence record',
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
          const SizedBox(height: 16),
          // 7-day adherence banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryTealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '7-Day Adherence Score:',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTealDark,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '94% (Excellent)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: historyLogs.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppTheme.cardBorder,
              ),
              itemBuilder: (context, index) {
                final log = historyLogs[index];
                final isSuccess = log['success'] as bool;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isSuccess
                            ? AppTheme.successGreen
                            : const Color(0xFFC2410C),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['med'] as String,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              log['status'] as String,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isSuccess
                                    ? AppTheme.textSecondary
                                    : const Color(0xFFC2410C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        log['date'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
