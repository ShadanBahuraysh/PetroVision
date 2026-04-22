import 'package:flutter/material.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isAgreed = false;
  
  // الألوان الثابتة بناءً على HomePage
  final Color primaryNavy = const Color(0xFF1A2E35); 
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

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
              const SizedBox(height: 20),
              
              // اللوجو الموحد الصغير
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
              Text(
                "Create Account", 
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)
              ),
              const SizedBox(height: 8),
              Text(
                "Join PetroVision today", 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)
              ),
              
              const SizedBox(height: 35),

              // حقول الإدخال باستخدام الدالة الموحدة
              _buildField("Full Name", "Enter your full name", Icons.person_outline),
              const SizedBox(height: 20),
              _buildField("Email Address", "Enter your email", Icons.email_outlined),
              const SizedBox(height: 20),
              _buildField("Phone Number", "Enter your phone number", Icons.phone_outlined),
              const SizedBox(height: 20),
              _buildField("Password", "Create a password", Icons.lock_outline, isPass: true),
              
              const SizedBox(height: 25),

              // جزء الموافقة على الشروط بستايل أنيق
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
                      onChanged: (bool? value) {
                        setState(() { isAgreed = value ?? false; });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "I agree to the Terms and Conditions",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // زر التسجيل الموحد (نفس حجم ستايل Login)
              SizedBox(
                width: 240, 
                height: 40,
                child: ElevatedButton(
                  onPressed: isAgreed ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessScreen()));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Sign Up", 
                    style: TextStyle(
                      color: isAgreed ? Colors.white : Colors.grey.shade500, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء الحقول الموحدة لضمان الـ Consistency
  Widget _buildField(String label, String hint, IconData icon, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label, 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: primaryNavy, letterSpacing: 0.5)
          ),
        ),
        TextField(
          obscureText: isPass,
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, size: 20, color: accentBlue),
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
          ),
        ),
      ],
    );
  }
}