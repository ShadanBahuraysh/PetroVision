import 'package:flutter/material.dart';
import 'loyalty_dashboard_screen.dart';

class RedemptionSuccessScreen extends StatelessWidget {
  const RedemptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: accentBlue, size: 60),
              ),
              const SizedBox(height: 20),
              const Text(
                "Done!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "Reward redeemed successfully",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoyaltyDashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Back to Loyalty",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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