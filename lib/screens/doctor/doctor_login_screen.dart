import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_selection_dialog.dart';
import 'patient_access_request_screen.dart';

/// Doctor Login screen for MediCare AI.
/// Focuses on professional, calm clinical aesthetics, validation, and clear demo success / failure states.
class DoctorLoginScreen extends StatefulWidget {
  final VoidCallback? onBackToRoleSelection;

  const DoctorLoginScreen({
    super.key,
    this.onBackToRoleSelection,
  });

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final _identifierFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _loginErrorMessage;

  // Recognized demo doctor credentials
  static const String validEmail = 'dr.vance@medicare.ai';
  static const String validNpi = '9482014829';
  static const String validPassword = 'ClinicalPass2026!';

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Please enter your professional email or NPI / Medical ID';
    }

    if (input.contains('@')) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
      );
      if (!emailRegex.hasMatch(input)) {
        return 'Please enter a valid clinical email (e.g. dr.vance@medicare.ai)';
      }
      return null;
    }

    // Validate NPI / Medical ID: alphanumeric or numeric 6-12 chars
    final digitsAndLetters = input.replaceAll(RegExp(r'[\s\-]'), '');
    if (digitsAndLetters.length < 6) {
      return 'Medical ID or NPI must be at least 6 digits/characters';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Please enter your clinical password';
    }
    if (input.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loginErrorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final id = _identifierController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // Check against demo credentials
    final isAuthorized =
        (id == validEmail || id == validNpi || id == 'dr.vance') &&
            password == validPassword;

    setState(() => _isLoading = false);

    if (isAuthorized) {
      // Success State
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
                  'Clinician verified. Opening Patient Access Request...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      // Navigate to Patient Access Request Screen
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PatientAccessRequestScreen(
            doctorName: 'Dr. Eleanor Vance, MD',
            doctorSpecialty: 'Cardiology & Vascular Health',
            onSignOut: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } else {
      // Failed Login State
      setState(() {
        _loginErrorMessage =
            'Authentication failed: Provider credentials not found in clinical directory. '
            'In demo mode, use dr.vance@medicare.ai or tap "Autofill Valid Doctor".';
      });
    }
  }

  void _autofillValidDoctor() {
    setState(() {
      _identifierController.text = validEmail;
      _passwordController.text = validPassword;
      _loginErrorMessage = null;
      _autovalidateMode = AutovalidateMode.disabled;
    });
  }

  void _autofillInvalidDoctor() {
    setState(() {
      _identifierController.text = 'unregistered.doctor@clinic.net';
      _passwordController.text = 'WrongSecret999!';
      _loginErrorMessage = null;
      _autovalidateMode = AutovalidateMode.disabled;
    });
  }

  void _navigateBack() {
    if (widget.onBackToRoleSelection != null) {
      widget.onBackToRoleSelection!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      RoleSelectionDialog.show(context);
    }
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                Icon(Icons.admin_panel_settings_rounded,
                    color: AppTheme.primaryTeal, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinician Password Reset',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Hospital credentials require IT security verification',
                        style: TextStyle(
                            fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'To reset your medical staff password, contact your hospital IT helpdesk or use the Hospital Enterprise SSO portal.\n\nHelpline: (555) 900-CLINIC\nEmail: it-security@medicare.ai (Demo)',
              style: TextStyle(
                fontSize: 13.5,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
              ),
              child: const Text('Return to Doctor Sign In'),
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
      appBar: AppBar(
        leading: Tooltip(
          message: 'Back to role selection',
          child: IconButton(
            key: const Key('doctor_back_to_roles_button'),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textPrimary,
              size: 24,
            ),
            onPressed: _navigateBack,
          ),
        ),
        title: const Text('Clinical Portal'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            key: const Key('doctor_role_switcher_button'),
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
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. MediCare AI Branding & Doctor Icon Area
                  _buildDoctorBrandHeader(),

                  const SizedBox(height: 20),

                  // 2. Heading and Instruction
                  const Text(
                    'Doctor sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Access your clinical workstation with your hospital email or National Provider Identifier (NPI).',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Demo Credentials Helper Chips (Valid vs Invalid)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        key: const Key('autofill_valid_doctor_chip'),
                        avatar: const Icon(
                          Icons.verified_user_rounded,
                          size: 15,
                          color: AppTheme.successGreen,
                        ),
                        label: const Text(
                          'Autofill Valid Doctor',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTealDark,
                          ),
                        ),
                        backgroundColor: AppTheme.primaryTealLight,
                        side: BorderSide(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                        ),
                        onPressed: _autofillValidDoctor,
                      ),
                      ActionChip(
                        key: const Key('autofill_invalid_doctor_chip'),
                        avatar: const Icon(
                          Icons.error_outline_rounded,
                          size: 15,
                          color: AppTheme.errorRed,
                        ),
                        label: const Text(
                          'Autofill Invalid Doctor',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.errorRed,
                          ),
                        ),
                        backgroundColor: const Color(0xFFFFECEB),
                        side: BorderSide(
                          color: AppTheme.errorRed.withValues(alpha: 0.3),
                        ),
                        onPressed: _autofillInvalidDoctor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Error State Banner (When failed login occurs)
                  if (_loginErrorMessage != null) ...[
                    Container(
                      key: const Key('doctor_login_error_banner'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.errorRed.withValues(alpha: 0.4),
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

                  // 3. Form Card
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
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Identifier Field (Email or NPI)
                          const Text(
                            'Email or Professional NPI / ID',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('doctor_identifier_field'),
                            controller: _identifierController,
                            focusNode: _identifierFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateIdentifier,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. dr.vance@medicare.ai or 9482014829',
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                size: 22,
                              ),
                              suffixIcon: _identifierController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _identifierController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                          ),

                          const SizedBox(height: 18),

                          // Password Field
                          const Text(
                            'Clinical Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: const Key('doctor_password_field'),
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter clinical account password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                key: const Key('doctor_toggle_password_button'),
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

                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: const Key('doctor_forgot_password_button'),
                              onPressed: _showForgotPasswordSheet,
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

                          const SizedBox(height: 12),

                          // Primary "Log in" button
                          ElevatedButton(
                            key: const Key('doctor_primary_login_button'),
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
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

                  const SizedBox(height: 22),

                  // Security notice
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
                            'Provider Authentication • HIPAA / HITECH Compliant',
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

  Widget _buildDoctorBrandHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryTeal, Color(0xFF0C5E5E)],
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
              Icons.medical_services_rounded,
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
                Icons.medical_services_rounded,
                size: 13,
                color: AppTheme.primaryTeal,
              ),
              SizedBox(width: 5),
              Text(
                'Doctor / Clinician Portal',
                style: TextStyle(
                  fontSize: 12,
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
