import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/candlestick_background.dart';
import 'signup_screen.dart';
import 'verify_email_screen.dart';

const _bullGreen = Color(0xFF2ECC71);
const _bearRed = Color(0xFFE74C3C);
const _bgTop = Color(0xFF0B0F14);
const _bgBottom = Color(0xFF121A24);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email_not_confirmed') {
        // Account exists but was never verified: send a fresh code.
        final email = _emailController.text.trim();
        try {
          await Supabase.instance.client.auth.resend(
            type: OtpType.signup,
            email: email,
          );
        } on AuthException catch (_) {
          // Rate-limited: the earlier code may still work.
        }
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
        );
        return;
      }
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
      case 'user_banned':
        return 'This account has been disabled.';
      case 'invalid_credentials':
      case 'user_not_found':
        return 'Incorrect email or password.';
      case 'email_not_confirmed':
        return 'Confirm your email first. Check your inbox.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Too many attempts. Try again later.';
      default:
        return e.message.isNotEmpty
            ? e.message
            : 'Login failed. Please try again.';
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first.')),
      );
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authErrorMessage(e))));
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
                          const SizedBox(height: 12),
                          const _BullBearSplash(),
                          const SizedBox(height: 8),
                          const _Header(),
                          const SizedBox(height: 32),
                          _LoginForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            rememberMe: _rememberMe,
                            isSubmitting: _isSubmitting,
                            onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onToggleRemember: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            onSubmit: _handleLogin,
                            onForgotPassword: _handleForgotPassword,
                          ),
                          const Spacer(),
                          const SizedBox(height: 16),
                          _SignUpPrompt(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
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

class _BullBearSplash extends StatelessWidget {
  const _BullBearSplash();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: Transform.rotate(
              angle: -0.12,
              child: const _GlowEmoji(emoji: '🐂', color: _bullGreen),
            ),
          ),
          Positioned(
            right: 0,
            child: Transform.rotate(
              angle: 0.12,
              child: const _GlowEmoji(emoji: '🐻', color: _bearRed),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: Colors.white70,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowEmoji extends StatelessWidget {
  const _GlowEmoji({required this.emoji, required this.color});

  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
        ),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 56)),
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
                text: 'Bull',
                style: TextStyle(color: _bullGreen),
              ),
              TextSpan(
                text: ' & ',
                style: TextStyle(color: Colors.white54),
              ),
              TextSpan(
                text: 'Bear',
                style: TextStyle(color: _bearRed),
              ),
              TextSpan(
                text: ' Markets',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to track your portfolio',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isSubmitting,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isSubmitting;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

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
            const SizedBox(height: 4),
            Row(
              children: [
                Transform.scale(
                  scale: 0.85,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onToggleRemember,
                    fillColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? _bullGreen
                          : Colors.transparent,
                    ),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Text(
                  'Remember me',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onForgotPassword,
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: _bullGreen, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                        'Log In',
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

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Sign Up',
            style: TextStyle(color: _bullGreen, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
