import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_selection_dialog.dart';
import 'accept_invitation_screen.dart';
import 'caretaker_dashboard_screen.dart';

/// Mobile-first Caretaker Login page for MediCare AI.
/// Uses demo-only authentication with mock credentials.
class CaretakerLoginScreen extends StatefulWidget {
  final VoidCallback? onBackToRoles;

  const CaretakerLoginScreen({
    super.key,
    this.onBackToRoles,
  });

  @override
  State<CaretakerLoginScreen> createState() => _CaretakerLoginScreenState();
}

class _CaretakerLoginScreenState extends State<CaretakerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _loginErrorMessage;

  // Mock valid caretaker credentials
  static const String _mockValidEmail = 'mark.jenkins@familycare.org';
  static const String _mockValidPhone = '(555) 234-9988';
  static const String _mockValidPassword = 'FamilyCare2026!';

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    // Clear previous errors
    setState(() => _loginErrorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network authentication latency
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    final input = _identifierController.text.trim();
    final password = _passwordController.text;

    final isEmailMatch = input.toLowerCase() == _mockValidEmail.toLowerCase();
    final isPhoneMatch = input.replaceAll(RegExp(r'\D'), '') ==
        _mockValidPhone.replaceAll(RegExp(r'\D'), '');
    final isPasswordMatch = password == _mockValidPassword;

    setState(() => _isLoading = false);

    if ((isEmailMatch || isPhoneMatch) && isPasswordMatch) {
      // Clear current snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Caretaker verified. Opening family dashboard...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const CaretakerDashboardScreen(
            caretakerName: 'Mark Jenkins',
            caretakerRelationship: 'Authorized Family Caregiver',
          ),
        ),
      );
    } else {
      // Failed login state
      setState(() {
        _loginErrorMessage =
            'Authentication failed: Unregistered caregiver account or invalid password. Use the demo autofill chip below.';
      });
    }
  }

  void _autofillCredentials({required bool isValid}) {
    setState(() {
      _loginErrorMessage = null;
      if (isValid) {
        _identifierController.text = _mockValidEmail;
        _passwordController.text = _mockValidPassword;
      } else {
        _identifierController.text = 'unregistered@care.net';
        _passwordController.text = 'BadPass123';
      }
    });
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
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
                Icon(Icons.lock_reset_rounded,
                    color: AppTheme.primaryTeal, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Caregiver Password Recovery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Demo recovery assistance for family caregivers',
                        style: TextStyle(
                            fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Text(
                'Demo credentials are pre-configured:\n'
                '• Email: mark.jenkins@familycare.org\n'
                '• Password: FamilyCare2026!\n'
                '• Linked Patient: Sarah Jenkins (Mother)',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF166534),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                _autofillCredentials(isValid: true);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Autofill Valid Credentials & Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Back to role selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: OutlinedButton.icon(
                          key: const Key('caretaker_back_to_roles_button'),
                          onPressed: () {
                            if (widget.onBackToRoles != null) {
                              widget.onBackToRoles!();
                            } else {
                              RoleSelectionDialog.show(context,
                                  currentRole: 'caregiver');
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          label: const Text(
                            'Switch Role',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextButton.icon(
                          key: const Key('enter_invitation_code_button'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const AcceptInvitationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.mail_outline_rounded,
                            size: 18,
                            color: AppTheme.primaryTeal,
                          ),
                          label: const Text(
                            'Enter Invite Code',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Branding & Medical / Caretaker Icon Area
                  _buildCaretakerBrandHeader(),
                  const SizedBox(height: 24),

                  // 3. Heading & Short Instruction
                  const Text(
                    'Caretaker sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitor medications, appointments, and care updates for authorized family members.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Failed-login error banner
                  if (_loginErrorMessage != null) ...[
                    Container(
                      key: const Key('caretaker_login_error_banner'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorRed.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_rounded,
                            color: AppTheme.errorRed,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _loginErrorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7F1D1D),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 5. Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Caretaker Email or Phone Input
                          const Text(
                            'Email or Mobile Phone',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('caretaker_identifier_field'),
                            controller: _identifierController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'e.g. mark.jenkins@familycare.org',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your registered email or phone';
                              }
                              final trimmed = val.trim();
                              final isEmail = trimmed.contains('@') &&
                                  trimmed.contains('.');
                              final digitsOnly =
                                  trimmed.replaceAll(RegExp(r'\D'), '');
                              final isPhone = digitsOnly.length >= 10;
                              if (!isEmail && !isPhone) {
                                return 'Enter a valid email address or 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Input with show/hide toggle
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            key: const Key('caretaker_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleSignIn(),
                            decoration: InputDecoration(
                              hintText: 'Enter caretaker password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                key: const Key('caretaker_toggle_password_button'),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.textSecondary,
                                ),
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: const Key('caretaker_forgot_password_button'),
                              onPressed: _showForgotPasswordSheet,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Primary Log in Button
                          ElevatedButton(
                            key: const Key('caretaker_primary_login_button'),
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 1,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Sign in as Caretaker',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. Demo Quick-Fill Controls
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded,
                                size: 16, color: AppTheme.primaryTeal),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Demo Credentials & Testing',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTealDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              key: const Key('autofill_valid_caretaker_chip'),
                              avatar: const Icon(Icons.check_circle_rounded,
                                  size: 16, color: AppTheme.successGreen),
                              label: const Text('Autofill Valid Caretaker'),
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: AppTheme.successGreen),
                              onPressed: () =>
                                  _autofillCredentials(isValid: true),
                            ),
                            ActionChip(
                              key: const Key('autofill_invalid_caretaker_chip'),
                              avatar: const Icon(Icons.cancel_rounded,
                                  size: 16, color: AppTheme.errorRed),
                              label: const Text('Autofill Invalid Caretaker'),
                              backgroundColor: Colors.white,
                              side:
                                  const BorderSide(color: AppTheme.errorRed),
                              onPressed: () =>
                                  _autofillCredentials(isValid: false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 7. Security notice
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 14,
                          color: AppTheme.textTertiary,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Caregiver Portal • Patient Consent Protected',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaretakerBrandHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryTeal, Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.family_restroom_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'MediCare',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6F4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.supervised_user_circle_rounded,
                size: 13,
                color: AppTheme.primaryTeal,
              ),
              SizedBox(width: 4),
              Text(
                'Caretaker & Family Portal',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTealDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
