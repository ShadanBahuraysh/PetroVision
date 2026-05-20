// ========================================================================================================
// PetroVision Login Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the LoginScreen used for
// user authentication within the PetroVision system.
//
// Features included:
// - Authenticating users through backend APIs
// - Validating login credentials and email format
// - Supporting OTP verification workflows
// - Supporting administrator verification workflows
// - Handling authentication and API errors
// - Managing loading and login states
// - Displaying login validation feedback
// - Navigating users based on account roles
// - Providing responsive authentication UI components
//
// It also integrates login APIs, OTP verification,
// role-based navigation, and secure-access
// workflows within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_screen.dart';
import 'success_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'admin_job_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please enter email and password");
      return;
    }

    if (!email.contains('@')) {
      setState(() => _errorMessage = "Invalid email format");
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final role = data['user']?['role'] ?? 'customer';
        final userId = data['user']?['user_id'] ?? '';
        // Persist the logged-in userId so other screens can read it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_user_id', userId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: email,
              onVerified: () {
                if (role == 'admin') {
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminJobVerificationScreen(userId: userId),
                  ),
                );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SuccessScreen(
  userId: data['user']['user_id'],
  name: '${data['user']['fname']} ${data['user']['lname']}',
  email: data['user']['email'],
)),
                  );
                }
              },
            ),
          ),
        );
      } else {
        String message = 'Invalid email or password';

        try {
          final data = json.decode(response.body);
          message = data['detail'] ?? message;
        } catch (_) {}

        setState(() => _errorMessage = message);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Connection error. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          "LOGIN",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                height: 70, width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(Icons.local_gas_station_rounded, color: accentBlue, size: 35),
              ),
              const SizedBox(height: 40),
              Text("Welcome back", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text("Sign in to your account", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 45),

              _buildLabel("Email Address"),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
                decoration: _buildInputDecoration("Enter your email", Icons.email_outlined),
              ),

              const SizedBox(height: 25),

              _buildLabel("Password"),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible,
                style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
                decoration: _buildInputDecoration("Enter your password", Icons.lock_outline, isPassword: true),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: Text("Forgot password?", style: TextStyle(color: accentBlue, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade600, fontSize: 13))),
                    ],
                  ),
                ),

              const SizedBox(height: 35),

              SizedBox(
                width: 240, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: Text("Sign Up", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: primaryNavy, letterSpacing: 0.5)),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, {bool isPassword = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
      prefixIcon: Icon(icon, size: 20, color: accentBlue),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: Colors.grey.shade400,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            )
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentBlue, width: 1.5),
      ),
    );
  }
}