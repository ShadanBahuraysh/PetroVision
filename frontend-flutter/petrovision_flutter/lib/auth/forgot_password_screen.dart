import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email address";
    return null;
  }

  void _onSend() {
    final error = _validateEmail(_emailController.text);
    setState(() => _emailError = error);

    if (error == null) {
      setState(() => _emailSent = true);
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
          child: _emailSent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  // ── حالة الفورم ──────────────────────────────────────────

  Widget _buildFormState() {
    return Column(
      children: [
        const SizedBox(height: 40),

        // أيقونة
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.lock_reset_rounded, color: accentBlue, size: 40),
        ),

        const SizedBox(height: 30),

        Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: primaryNavy,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Enter your email and we'll send you\na link to reset your password.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 45),

        // Email field
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Email Address",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: primaryNavy,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => setState(() => _emailError = _validateEmail(v)),
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              size: 20,
              color: _emailError != null ? Colors.red : accentBlue,
            ),
            errorText: _emailError,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _emailError != null ? Colors.red.shade200 : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // زر الإرسال
        SizedBox(
          width: 240,
          height: 50,
          child: ElevatedButton(
            onPressed: _onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              "Send Reset Link",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // رجوع للـ Login
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Back to Login",
            style: TextStyle(
              color: accentBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ── حالة النجاح ──────────────────────────────────────────

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 80),

        // أيقونة النجاح
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: Color(0xFF22C55E),
            size: 50,
          ),
        ),

        const SizedBox(height: 30),

        Text(
          "Check your email",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: primaryNavy,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "We sent a reset link to\n${_emailController.text.trim()}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 50),

        // زر الرجوع للـ Login
        SizedBox(
          width: 240,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              "Back to Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // إعادة الإرسال
        GestureDetector(
          onTap: () => setState(() => _emailSent = false),
          child: Text(
            "Didn't receive it? Try again",
            style: TextStyle(
              color: accentBlue,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}