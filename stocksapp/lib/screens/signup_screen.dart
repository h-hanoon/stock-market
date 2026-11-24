import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/candlestick_background.dart';
import 'verify_email_screen.dart';

const _bullGreen = Color(0xFF2ECC71);
const _bearRed = Color(0xFFE74C3C);
const _bgTop = Color(0xFF0B0F14);
const _bgBottom = Color(0xFF121A24);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final email = _emailController.text.trim();
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (response.session == null) {
        // Email confirmation is on: ask for the code Supabase just emailed.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
        );
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _authErrorMessage(AuthException e) {
    switch (e.code) {
      case 'validation_failed':
      case 'email_address_invalid':
        return 'That email address looks invalid.';
      case 'user_already_exists':
      case 'email_exists':
        return 'An account already exists for that email.';
      case 'weak_password':
        return 'Choose a stronger password.';
      case 'signup_disabled':
      case 'email_provider_disabled':
        return 'Sign up is currently disabled.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Too many attempts. Try again later.';
      default:
        return e.message.isNotEmpty
            ? e.message
            : 'Sign up failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgTop, _bgBottom],
              ),
            ),
          ),
          const Positioned.fill(child: CandlestickBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BackButton(onTap: () => Navigator.of(context).pop()),
                          const SizedBox(height: 4),
                          const _Header(),
                          const SizedBox(height: 32),
                          _SignUpForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            obscurePassword: _obscurePassword,
                            obscureConfirmPassword: _obscureConfirmPassword,
                            isSubmitting: _isSubmitting,
                            onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onToggleObscureConfirm: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            onSubmit: _handleSignUp,
                          ),
                          const Spacer(),
                          const SizedBox(height: 16),
                          _LoginPrompt(
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
            children: [
              TextSpan(
                text: 'Create',
                style: TextStyle(color: _bullGreen),
              ),
              TextSpan(
                text: ' an ',
                style: TextStyle(color: Colors.white54),
              ),
              TextSpan(
                text: 'Account',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to start tracking your portfolio',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isSubmitting,
    required this.onToggleObscure,
    required this.onToggleObscureConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleObscureConfirm;
  final VoidCallback onSubmit;

  InputDecoration _decoration(String label, IconData icon) {
    final borderRadius = BorderRadius.circular(14);
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _bullGreen, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: _bearRed, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration('Email', Icons.mail_outline_rounded),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email';
                }
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration('Password', Icons.lock_outline_rounded)
                  .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: onToggleObscure,
                    ),
                  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                if (value.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              style: const TextStyle(color: Colors.white),
              decoration:
                  _decoration(
                    'Confirm Password',
                    Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: onToggleObscureConfirm,
                    ),
                  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bullGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Log In',
            style: TextStyle(color: _bullGreen, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
