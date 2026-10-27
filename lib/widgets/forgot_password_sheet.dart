import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet allowing patients to request a password reset via email or phone.
class ForgotPasswordSheet extends StatefulWidget {
  final String initialValue;

  const ForgotPasswordSheet({
    super.key,
    this.initialValue = '',
  });

  static Future<void> show(BuildContext context, {String initialValue = ''}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ForgotPasswordSheet(initialValue: initialValue),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _recoveryController;
  bool _isSending = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _recoveryController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _recoveryController.dispose();
    super.dispose();
  }

  String? _validateRecoveryInput(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter your registered email or phone number';
    }

    final isEmail = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    ).hasMatch(trimmed);

    final digitsOnly = trimmed.replaceAll(RegExp(r'[\s\-+()]'), '');
    final isPhone = RegExp(r'^[0-9]{7,15}$').hasMatch(digitsOnly);

    if (!isEmail && !isPhone) {
      return 'Enter a valid email (e.g. name@domain.com) or phone number';
    }

    return null;
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // Simulate safe API dispatch
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSuccess ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      key: const ValueKey('form_view'),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: AppTheme.primaryTeal,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset your password',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'We will send recovery instructions to your device.',
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
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: TextFormField(
            key: const Key('recovery_input_field'),
            controller: _recoveryController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateRecoveryInput,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
            decoration: const InputDecoration(
              labelText: 'Email or Mobile Number',
              hintText: 'e.g. sarah@example.com or +1 555-0142',
              prefixIcon: Icon(Icons.contact_mail_outlined),
            ),
          ),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          key: const Key('send_recovery_button'),
          onPressed: _isSending ? null : _handleReset,
          child: _isSending
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Reset Instructions'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel and return to sign in'),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final contact = _recoveryController.text.trim();
    return Column(
      key: const ValueKey('success_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F6EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successGreen,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Recovery link sent!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If an account exists for "$contact", you will receive a secure reset link shortly. Please check your inbox or text messages.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Sign In'),
        ),
      ],
    );
  }
}
