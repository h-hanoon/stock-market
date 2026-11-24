import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/candlestick_background.dart';

const _bullGreen = Color(0xFF2ECC71);
const _bgTop = Color(0xFF0B0F14);
const _bgBottom = Color(0xFF121A24);

/// Asks for the code Supabase emails after sign-up. A correct code confirms
/// the account and signs the user in; the auth listener in main.dart then
/// shows the home screen.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      _showMessage('Enter the code from the email.');
      return;
    }
    setState(() => _isVerifying = true);
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        email: widget.email,
        token: code,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showMessage(
        e.code == 'otp_expired'
            ? 'That code is wrong or has expired. Request a new one.'
            : e.message,
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (!mounted) return;
      _showMessage('New code sent to ${widget.email}.');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showMessage(
        e.code == 'over_email_send_rate_limit'
            ? 'Too many emails sent. Wait a bit and try again.'
            : e.message,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    color: _bullGreen,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Check your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification code to\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _codeController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSubmitted: (_) => _verify(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '000000',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: const BorderSide(
                                color: _bullGreen,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _bullGreen,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: borderRadius,
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Verify & Continue',
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isResending ? null : _resend,
                    child: Text(
                      _isResending ? 'Sending…' : "Didn't get it? Resend code",
                      style: const TextStyle(color: _bullGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
