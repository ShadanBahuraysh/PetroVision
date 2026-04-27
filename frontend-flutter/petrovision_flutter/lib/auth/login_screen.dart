import 'package:flutter/material.dart';
import 'success_screen.dart';
import 'signup_screen.dart';
import '../admin/screens/dashboard_screen.dart';
import 'forgot_password_screen.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }

    if (email.toLowerCase() == 'admin@petro.com') {
      Navigator.pushReplacementNamed(context, '/'); // Admin dashboard
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
      ); // Customer success → home
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
              Text(
                "Welcome back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to your account",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

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
                obscureText: true,
                style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
                decoration: _buildInputDecoration("Enter your password", Icons.lock_outline, isPassword: true),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
  ),
  child: Text(
    "Forgot password?",
    style: TextStyle(color: accentBlue, fontSize: 13, fontWeight: FontWeight.w700),
  ),
),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: 240,
                height: 40,
                child: ElevatedButton(
                  onPressed: handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: accentBlue, fontWeight: FontWeight.w800),
                    ),
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
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: primaryNavy, letterSpacing: 0.5),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, {bool isPassword = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
      prefixIcon: Icon(icon, size: 20, color: accentBlue),
      suffixIcon: isPassword ? Icon(Icons.visibility_off_outlined, size: 20, color: Colors.grey.shade400) : null,
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
