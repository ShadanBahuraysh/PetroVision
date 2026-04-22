import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // الألوان المنسوخة بدقة من الـ HomePage الخاصة بكِ
  final Color primaryNavy = const Color(0xFF1A2E35); 
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center( // لضمان توسط العناصر بدقة
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40), // زيادة الحواف الجانبية لتصغير العرض
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 150,
              ),
              const SizedBox(height: 3),
              Text(
                "Smart Loyalty & Insights",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 10),
             // const SizedBox(height: 40),
              
             // Text(
               // "PETROVISION",
                //style: TextStyle(
                  //fontSize: 14, // صغرنا الخط ليطابق الـ AppBar
                  //fontWeight: FontWeight.w900,
                  //color: primaryNavy,
                  //letterSpacing: 2,
                //),
              //),
              const SizedBox(height: 10),
              
              Text(
                "Welcome to\nPetroVision",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800, 
                  color: primaryNavy,
                  letterSpacing: -0.5,
                ),
              ),
          const SizedBox(height: 20),


              // زر Login - تم تصغير الارتفاع والعرض
              SizedBox(
                width: 300, // تحديد عرض ثابت وأصغر
                height: 40,  // تقليل الارتفاع ليصبح أنيقاً
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy, // تغيير للون الكحلي ليطابق الـ FAB في الهوم
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height:16 ),

              // زر Sign Up - بستايل شفاف وحدود خفيفة مطابقة لكروت الهوم
              SizedBox(
                width: 300,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5), // حدود رمادية فاتحة مثل الكروت
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: primaryNavy, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}