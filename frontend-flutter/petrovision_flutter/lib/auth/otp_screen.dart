// ========================================================================================================
// PetroVision OTP Verification Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the OtpScreen and related
// OTP verification components used within
// the PetroVision authentication system.
//
// Features included:
// - Verifying OTP authentication codes
// - Resending verification codes
// - Managing OTP countdown timers
// - Handling OTP validation and verification errors
// - Supporting secure authentication workflows
// - Managing loading and verification states
// - Supporting automatic OTP verification
// - Displaying verification feedback messages
// - Providing responsive OTP input UI components
//
// It also integrates OTP verification APIs,
// authentication-security workflows,
// and verification-state management
// within the PetroVision platform.
// ========================================================================================================
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerified; 

  const OtpScreen({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color primaryNavy = Color(0xFF1A2E35);
  static const Color accentBlue  = Color(0xFF4195AF);
  static const Color scaffoldBg  = Color(0xFFFBFBFB);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  static const String _baseUrl = 'http://localhost:8000';

  bool _hasError    = false;
  bool _isVerifying = false;
  bool _isResending = false;

  // Countdown timer for resend
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
         if (!mounted) return;
         setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  String get _enteredOtp =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _hasError = false);

    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when all 6 filled
    if (_enteredOtp.length == 6) _verify();
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  Future<void> _verify() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _hasError = false;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email.trim(),
          'code': _enteredOtp.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _isVerifying = false);
        widget.onVerified();
      } else {
        _clearOtpWithError();
      }
    } catch (e) {
      if (!mounted) return;
      _clearOtpWithError();
    }
  }

  void _clearOtpWithError() {
    setState(() {
      _isVerifying = false;
      _hasError = true;
    });

    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  Future<void> _resend() async {
  if (_secondsLeft > 0 || _isResending) return;

  setState(() => _isResending = true);

  try {
  final response = await http.post(
    Uri.parse('$_baseUrl/auth/resend-otp'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': widget.email.trim(),
    }),
  );

  if (!mounted) return;

  if (response.statusCode != 200) {
    setState(() => _isResending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to resend code')),
    );
    return;
  }
} catch (e) {
  if (!mounted) return;

  setState(() => _isResending = false);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Connection error. Try again.')),
  );
  return;
}

setState(() => _isResending = false);

  _startTimer();

  for (final c in _controllers) c.clear();

  _focusNodes[0].requestFocus();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('A new code was sent to ${widget.email}'),
      backgroundColor: primaryNavy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

  // Mask email: j***@gmail.com
  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final name   = parts[0];
    final domain = parts[1];
    final masked = name.length <= 2
        ? '${name[0]}***'
        : '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
    return '$masked@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VERIFICATION',
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Icon
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: accentBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.mark_email_read_outlined, color: accentBlue, size: 38),
              ),

              const SizedBox(height: 30),

              const Text(
                'Check your email',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit verification code to\n'),
                    TextSpan(
                      text: _maskedEmail,
                      style: const TextStyle(color: primaryNavy, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 44),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  hasError: _hasError,
                  onChanged: (v) => _onDigitChanged(i, v),
                  onKeyEvent: (e) => _onKeyDown(i, e),
                )),
              ),

              // Error message
              AnimatedOpacity(
                opacity: _hasError ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade400),
                      const SizedBox(width: 6),
                      Text(
                        'Incorrect code. Please try again.',
                        style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Verify button
              SizedBox(
                width: 240,
                height: 48,
                child: ElevatedButton(
                  onPressed: _enteredOtp.length == 6 && !_isVerifying ? _verify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // Resend
              Column(
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _resend,
                    child: _secondsLeft > 0
                        ? RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                              children: [
                                const TextSpan(text: 'Resend code in '),
                                TextSpan(
                                  text: '${_secondsLeft}s',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: primaryNavy),
                                ),
                              ],
                            ),
                          )
                        : _isResending
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: accentBlue),
                              )
                            : const Text(
                                'Resend code',
                                style: TextStyle(
                                  color: accentBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Security note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentBlue.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: accentBlue.withOpacity(0.8)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'For your security, this code expires in 5 minutes and can only be used once.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single OTP digit box ─────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onKeyEvent,
      child: SizedBox(
        width: 46,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2E35),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade300 : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF4195AF),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
