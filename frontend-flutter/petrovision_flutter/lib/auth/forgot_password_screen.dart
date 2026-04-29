import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _otpError;
  String? _passwordError;

  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  static const baseUrl = 'http://localhost:8000';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email address";
    return null;
  }

  // ── الخطوة 1: إرسال OTP ──────────────────────────────────
  Future<void> _onSendOtp() async {
    final error = _validateEmail(_emailController.text);
    setState(() => _emailError = error);
    if (error != null) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() => _otpSent = true);
      } else {
        final data = json.decode(response.body);
        setState(() => _emailError = data['detail'] ?? 'Email not found');
      }
    } catch (e) {
      setState(() => _emailError = 'Connection error. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── الخطوة 2: تحقق من OTP وتغيير الباسوورد ──────────────
  Future<void> _onResetPassword() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() => _otpError = "OTP is required");
      return;
    }
    if (_newPasswordController.text.length < 8) {
      setState(() => _passwordError = "Password must be at least 8 characters");
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _passwordError = "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'code': _otpController.text.trim(),
          'new_password': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _otpVerified = true);
      } else {
        final data = json.decode(response.body);
        setState(() => _otpError = data['detail'] ?? 'Invalid OTP');
      }
    } catch (e) {
      setState(() => _otpError = 'Connection error. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
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
          icon: Icon(Icons.arrow_back_ios_new, color: primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "FORGOT PASSWORD",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _otpVerified
              ? _buildSuccessState()
              : _otpSent
                  ? _buildOtpState()
                  : _buildEmailState(),
        ),
      ),
    );
  }

  // ── حالة 1: إدخال الإيميل ────────────────────────────────
  Widget _buildEmailState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          height: 80, width: 80,
          decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
          child: Icon(Icons.lock_reset_rounded, color: accentBlue, size: 40),
        ),
        const SizedBox(height: 30),
        Text("Reset Password", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text("Enter your email and we'll send you\na verification code.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 45),
        _buildField("Email Address", _emailController, Icons.email_outlined, errorText: _emailError,
          onChanged: (v) => setState(() => _emailError = _validateEmail(v))),
        const SizedBox(height: 40),
        SizedBox(
          width: 240, height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onSendOtp,
            style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text("Send OTP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text("Back to Login", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }

  // ── حالة 2: إدخال OTP وباسوورد جديد ─────────────────────
  Widget _buildOtpState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          height: 80, width: 80,
          decoration: BoxDecoration(color: accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
          child: Icon(Icons.verified_outlined, color: accentBlue, size: 40),
        ),
        const SizedBox(height: 30),
        Text("Check your email", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        Text("We sent a code to\n${_emailController.text.trim()}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 35),

        // OTP field
        _buildField("Verification Code", _otpController, Icons.pin_outlined,
          errorText: _otpError, keyboardType: TextInputType.number,
          onChanged: (v) => setState(() => _otpError = null)),
        const SizedBox(height: 20),

        // New Password
        _buildField("New Password", _newPasswordController, Icons.lock_outline,
          errorText: _passwordError, obscure: !_passwordVisible,
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
          onChanged: (v) => setState(() => _passwordError = null)),
        const SizedBox(height: 20),

        // Confirm Password
        _buildField("Confirm Password", _confirmPasswordController, Icons.lock_outline,
          obscure: true, onChanged: (v) => setState(() => _passwordError = null)),

        const SizedBox(height: 40),
        SizedBox(
          width: 240, height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onResetPassword,
            style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text("Reset Password", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _otpSent = false),
          child: Text("Try different email", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }

  // ── حالة 3: نجاح ─────────────────────────────────────────
  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          height: 100, width: 100,
          decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 55),
        ),
        const SizedBox(height: 30),
        Text("Password Reset!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        Text("Your password has been reset successfully.\nYou can now login with your new password.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 50),
        SizedBox(
          width: 240, height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: const Text("Back to Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ── Field Builder ─────────────────────────────────────────
  Widget _buildField(String label, TextEditingController controller, IconData icon, {
    String? errorText, bool obscure = false, Function(String)? onChanged,
    TextInputType? keyboardType, Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: primaryNavy, letterSpacing: 0.5)),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: errorText != null ? Colors.red : accentBlue),
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: errorText != null ? Colors.red.shade200 : Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
      ],
    );
  }
}