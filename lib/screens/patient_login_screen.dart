import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/forgot_password_sheet.dart';
import '../widgets/login_success_dialog.dart';
import '../widgets/role_selection_dialog.dart';
import 'patient_dashboard_screen.dart';

/// Mobile-first Patient Login screen for MediCare AI.
/// Focuses purely on an accessible, calming, and trustworthy login flow.
class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final _identifierFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Validates email or phone number format.
  String? _validateIdentifier(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Please enter your email or phone number';
    }

    // Check if input looks like an email (contains @)
    if (input.contains('@')) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
      );
      if (!emailRegex.hasMatch(input)) {
        return 'Please enter a valid email address (e.g. name@example.com)';
      }
      return null;
    }

    // Otherwise validate as a phone number
    final digitsOnly = input.replaceAll(RegExp(r'[\s\-+().]'), '');
    final phoneRegex = RegExp(r'^[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(digitsOnly)) {
      return 'Please enter a valid phone number (e.g. +1 555-0123) or email';
    }

    return null;
  }

  /// Validates password field.
  String? _validatePassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Please enter your password';
    }
    if (input.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Executes simulated demo sign-in flow.
  Future<void> _handleLogin() async {
    // Unfocus active inputs to prevent keyboard jitter
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network authentication delay
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() => _isLoading = false);

    final identifier = _identifierController.text.trim();

    // Show floating snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sign-in successful! Welcome back.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Show detailed success confirmation dialog
    LoginSuccessDialog.show(
      context,
      accountIdentifier: identifier,
      onDismiss: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => PatientDashboardScreen(
              onSignOut: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  /// Fills demo credentials for quick testing and review.
  void _fillDemoPatientCredentials() {
    setState(() {
      _identifierController.text = 'sarah.jenkins@example.com';
      _passwordController.text = 'CarePass2026!';
      _autovalidateMode = AutovalidateMode.disabled;
    });
  }

  /// Navigates back to role selection or displays role picker.
  void _navigateBackToRoleSelection() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      RoleSelectionDialog.show(context);
    }
  }

  /// Shows account creation informational dialog for demo.
  void _showCreateAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: AppTheme.primaryTeal),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'New Patient Setup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New to MediCare AI?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Patient portal access is typically created with your healthcare provider or clinic. You can also self-register with your Medical ID card.\n\n(Account registration wizard demo)',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting new patient onboarding flow (Demo)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Start Registration'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: Tooltip(
          message: 'Back to role selection',
          child: IconButton(
            key: const Key('back_to_role_selection_button'),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textPrimary,
              size: 24,
            ),
            onPressed: _navigateBackToRoleSelection,
          ),
        ),
        title: const Text('Patient Sign In'),
        centerTitle: true,
        actions: [
          // Quick Role Switcher button
          TextButton.icon(
            key: const Key('role_switcher_action_button'),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Roles'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => RoleSelectionDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              // Keep layout comfortable and centered on both phones and tablets/desktops
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. MediCare AI Logo and Brand Area
                  const Center(
                    child: BrandLogo(showBadge: true, iconSize: 56),
                  ),

                  const SizedBox(height: 24),

                  // 2. "Welcome back" heading and sign-in instruction
                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in with your email address or mobile number to access your personal health portal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Demo Credentials Quick-Fill Chip (Helpful for testing)
                  Center(
                    child: ActionChip(
                      key: const Key('demo_autofill_chip'),
                      avatar: const Icon(
                        Icons.auto_fix_high_rounded,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      label: const Text(
                        'Autofill Demo Patient',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      backgroundColor: AppTheme.primaryTealLight,
                      side: BorderSide(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      onPressed: _fillDemoPatientCredentials,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Login Form Card
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
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email or Phone Number Input
                          const Text(
                            'Email or Mobile Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('login_identifier_field'),
                            controller: _identifierController,
                            focusNode: _identifierFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateIdentifier,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. sarah@example.com or (555) 000-0000',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                size: 22,
                              ),
                              suffixIcon: _identifierController.text.isNotEmpty
                                  ? IconButton(
                                      key: const Key('clear_identifier_button'),
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                        color: AppTheme.textTertiary,
                                      ),
                                      tooltip: 'Clear field',
                                      onPressed: () {
                                        setState(() {
                                          _identifierController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) {
                              // Trigger state update to toggle clear icon
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                          ),

                          const SizedBox(height: 18),

                          // Password Input
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('login_password_field'),
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                key: const Key('toggle_password_visibility_button'),
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 22,
                                  color: AppTheme.textSecondary,
                                ),
                                tooltip: _isPasswordVisible
                                    ? 'Hide password'
                                    : 'Show password',
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),

                          const SizedBox(height: 6),

                          // Forgot password link (Accessible 48px tap target)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: const Key('forgot_password_button'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                ForgotPasswordSheet.show(
                                  context,
                                  initialValue:
                                      _identifierController.text.trim(),
                                );
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Primary "Log in" button
                          ElevatedButton(
                            key: const Key('primary_login_button'),
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              disabledBackgroundColor:
                                  AppTheme.primaryTeal.withValues(alpha: 0.65),
                              minimumSize: const Size.fromHeight(54),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Log in',
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. "New to MediCare AI? Create account" link
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'New to MediCare AI? ',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        InkWell(
                          key: const Key('create_account_link'),
                          onTap: _showCreateAccountDialog,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            child: Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTeal,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!isKeyboardOpen) ...[
                    const SizedBox(height: 20),
                    // Security & Privacy calm footer notice
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_clock_rounded,
                          size: 14,
                          color: AppTheme.textTertiary,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Protected by HIPAA compliant end-to-end encryption',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
