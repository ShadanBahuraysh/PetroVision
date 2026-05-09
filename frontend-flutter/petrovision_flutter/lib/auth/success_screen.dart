// ========================================================================================================
// PetroVision Success Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the SuccessScreen used after
// successful authentication or account verification
// within the PetroVision customer workflow.
//
// Features included:
// - Displaying successful verification feedback
// - Showing animated loading and transition effects
// - Redirecting customers to the home page
// - Passing user account data to the customer interface
// - Managing animation lifecycle and navigation timing
// - Providing a smooth post-login transition screen
//
// It also connects the authentication flow
// with the customer home page after successful
// login, signup, or OTP verification.
// ========================================================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../customer/screens/home_page.dart';

class SuccessScreen extends StatefulWidget {
   final String userId;
  final String name;
  final String email;

  const SuccessScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with TickerProviderStateMixin {
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
          MaterialPageRoute(
  builder: (context) => HomePage(
    userId: widget.userId,
    name: widget.name,
    email: widget.email,
  ),
),
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
            ScaleTransition(
              scale: Tween(begin: 0.98, end: 1.05).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28), 
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