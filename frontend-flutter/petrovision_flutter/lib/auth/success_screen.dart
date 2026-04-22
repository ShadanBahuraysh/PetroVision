import 'dart:async';
import 'package:flutter/material.dart';
import '../customer/screens/home_page.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with TickerProviderStateMixin {
  // الألوان الموحدة
  final Color primaryNavy = const Color(0xFF1A2E35); 
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللوجو بتأثير نبض هادئ وحواف مطابقة للهوم بيج
            ScaleTransition(
              scale: Tween(begin: 0.98, end: 1.05).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28), // حواف مطابقة لكروت الهوم
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(Icons.check_circle_rounded, color: accentBlue, size: 50),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // اسم التطبيق بستايل الـ AppBar
            Text(
              "PETROVISION",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryNavy,
                letterSpacing: 3,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              "Processing your request...",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // النقاط المتحركة بلون الـ Accent
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double delay = index * 0.2;
                    double value = ((_controller.value + delay) % 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Opacity(
                        opacity: value < 0.5 ? 1.0 : 0.3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}