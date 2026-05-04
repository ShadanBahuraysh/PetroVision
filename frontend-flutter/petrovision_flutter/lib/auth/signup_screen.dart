import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_screen.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isAgreed = false;

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) return "Full name is required";
    if (value.trim().length < 3) return "Name must be at least 3 characters";
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email address";
    return null;
  }

  String? _validatePhone(String value) {
    if (value.trim().isEmpty) return "Phone number is required";
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return "Enter a valid phone number";
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 8) return "Password must be at least 8 characters";
    if (!value.contains(RegExp(r'[A-Z]'))) return "Must contain at least one uppercase letter";
    if (!value.contains(RegExp(r'[a-z]'))) return "Must contain at least one lowercase letter";
    if (!value.contains(RegExp(r'[0-9]'))) return "Must contain at least one number";
    return null;
  }

  bool get _isFormValid {
    return _validateName(_nameController.text) == null &&
        _validateEmail(_emailController.text) == null &&
        _validatePhone(_phoneController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        isAgreed;
  }

  Future<void> _onSignUp() async {
    setState(() {
      _nameError = _validateName(_nameController.text);
      _emailError = _validateEmail(_emailController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final nameParts = _nameController.text.trim().split(' ');
      final fname = nameParts.first;
      final lname = nameParts.length > 1 ? nameParts.last : '';

      final signupResponse = await http.post(
        Uri.parse('http://localhost:8000/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fname': fname,
          'lname': lname,
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': 'customer',
        }),
      );

if (signupResponse.statusCode == 200) {
  final signupData = json.decode(signupResponse.body);
  final user = signupData['user'];

  await http.post(
    Uri.parse('http://localhost:8000/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    }),
  );

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OtpScreen(
        email: _emailController.text.trim(),
        onVerified: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SuccessScreen(
                userId: user['user_id'],
                name: '${user['fname']} ${user['lname']}',
                email: user['email'],
              ),
            ),
          );
        },
      ),
    ),
  );
} else {
        final data = json.decode(signupResponse.body);
        setState(() => _emailError = data['detail'] ?? 'Signup failed');
      }
    } catch (e) {
      setState(() => _emailError = 'Connection error. Try again.');
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
          "SIGN UP",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(Icons.person_add_rounded, color: accentBlue, size: 28),
              ),
              const SizedBox(height: 25),
              Text("Create Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text("Join PetroVision today", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 35),

              _buildField(label: "Full Name", hint: "Enter your full name", icon: Icons.person_outline,
                controller: _nameController, errorText: _nameError,
                onChanged: (v) => setState(() => _nameError = _validateName(v))),
              const SizedBox(height: 20),

              _buildField(label: "Email Address", hint: "Enter your email", icon: Icons.email_outlined,
                controller: _emailController, errorText: _emailError,
                onChanged: (v) => setState(() => _emailError = _validateEmail(v)),
                keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),

              _buildField(label: "Phone Number", hint: "Enter your phone number", icon: Icons.phone_outlined,
                controller: _phoneController, errorText: _phoneError,
                onChanged: (v) => setState(() => _phoneError = _validatePhone(v)),
                keyboardType: TextInputType.phone),
              const SizedBox(height: 20),

              _buildPasswordField(),

              if (_passwordController.text.isNotEmpty) _buildPasswordRules(),

              const SizedBox(height: 25),

              Row(
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      value: isAgreed,
                      activeColor: accentBlue,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      onChanged: (bool? value) => setState(() => isAgreed = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text("I agree to the Terms and Conditions",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 240, height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading ? _onSignUp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text("Sign Up",
                          style: TextStyle(
                            color: _isFormValid ? Colors.white : Colors.grey.shade500,
                            fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRules() {
    final password = _passwordController.text;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Password requirements:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          _passwordRule("At least 8 characters", password.length >= 8),
          _passwordRule("At least one uppercase letter", password.contains(RegExp(r'[A-Z]'))),
          _passwordRule("At least one lowercase letter", password.contains(RegExp(r'[a-z]'))),
          _passwordRule("At least one number", password.contains(RegExp(r'[0-9]'))),
        ],
      ),
    );
  }

  Widget _passwordRule(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16, color: isValid ? const Color(0xFF22C55E) : Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12,
            color: isValid ? const Color(0xFF22C55E) : Colors.grey.shade500,
            fontWeight: isValid ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label, required String hint, required IconData icon,
    required TextEditingController controller, String? errorText,
    Function(String)? onChanged, TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: primaryNavy, letterSpacing: 0.5)),
        ),
        TextField(
          controller: controller, onChanged: onChanged, keyboardType: keyboardType,
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, size: 20, color: errorText != null ? Colors.red : accentBlue),
            errorText: errorText, filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: errorText != null ? Colors.red.shade200 : Colors.grey.shade200, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentBlue, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Password", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: primaryNavy, letterSpacing: 0.5)),
        ),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          onChanged: (v) => setState(() => _passwordError = _validatePassword(v)),
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Create a password",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(Icons.lock_outline, size: 20, color: _passwordError != null ? Colors.red : accentBlue),
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade400, size: 20),
              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
            ),
            errorText: _passwordError, filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _passwordError != null ? Colors.red.shade200 : Colors.grey.shade200, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentBlue, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
        ),
      ],
    );
  }
}