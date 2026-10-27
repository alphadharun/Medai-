import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Healthcare logo area displaying the MediCare AI brand icon and title.
class BrandLogo extends StatelessWidget {
  final bool showBadge;
  final double iconSize;

  const BrandLogo({
    super.key,
    this.showBadge = true,
    this.iconSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Healthcare AI Icon Container
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primaryTeal,
                Color(0xFF148A8A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Medical Cross Shape
              const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 34,
              ),
              // AI Sparkle / Heartbeat accent in top-right
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF64DFDF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // App Title
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'MediCare',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryTeal,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        if (showBadge) ...[
          const SizedBox(height: 6),
          // Patient Portal identifier pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: AppTheme.primaryTealMuted,
                ),
                SizedBox(width: 5),
                Text(
                  'Patient Portal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTealMuted,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
