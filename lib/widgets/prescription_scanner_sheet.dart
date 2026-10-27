import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal simulating AI Prescription bottle scanning.
class PrescriptionScannerSheet extends StatefulWidget {
  final VoidCallback onAddExtractedMedication;

  const PrescriptionScannerSheet({
    super.key,
    required this.onAddExtractedMedication,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAddExtractedMedication,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PrescriptionScannerSheet(
        onAddExtractedMedication: onAddExtractedMedication,
      ),
    );
  }

  @override
  State<PrescriptionScannerSheet> createState() =>
      _PrescriptionScannerSheetState();
}

class _PrescriptionScannerSheetState extends State<PrescriptionScannerSheet> {
  bool _isScanning = false;
  bool _scanComplete = false;

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _scanComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(
                Icons.document_scanner_rounded,
                color: AppTheme.primaryTeal,
                size: 26,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Prescription Scanner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Point camera at medication bottle or pharmacy label',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('close_scanner_button'),
                icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                tooltip: 'Close scanner',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Camera Viewport Simulation
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF132228),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _scanComplete
                    ? AppTheme.successGreen
                    : AppTheme.primaryTeal,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!_isScanning && !_scanComplete)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Align label inside frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                if (_isScanning)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF64DFDF),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Scanning label & recognizing dosage...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (_scanComplete)
                  Container(
                    margin: const EdgeInsets.all(14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: AppTheme.successGreen,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Amlodipine 5 mg',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Take 1 tablet daily with water in morning',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_scanComplete)
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: const Icon(Icons.camera_rounded, size: 20),
              label: Text(_isScanning ? 'Scanning...' : 'Simulate Bottle Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                minimumSize: const Size.fromHeight(50),
              ),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onAddExtractedMedication();
              },
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Review & Add Scanned Med'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _scanComplete = false),
              child: const Text('Scan another label'),
            ),
          ],
        ],
      ),
    );
  }
}
