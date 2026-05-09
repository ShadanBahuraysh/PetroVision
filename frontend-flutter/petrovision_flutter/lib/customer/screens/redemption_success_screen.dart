// ========================================================================================================
// PetroVision Redemption Success Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the RedemptionSuccessScreen
// used for displaying successful reward-redemption
// feedback within the PetroVision loyalty system.
//
// Features included:
// - Displaying successful redemption confirmation
// - Providing redemption-success feedback UI
// - Supporting navigation back to loyalty workflows
// - Displaying responsive success-state layouts
// - Providing branded loyalty-success styling
//
// It also integrates redemption-confirmation workflows
// and post-redemption navigation handling
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'loyalty_dashboard_screen.dart';

class RedemptionSuccessScreen extends StatelessWidget {
  final String userId;

  const RedemptionSuccessScreen({super.key, required this.userId});

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
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Back to Loyalty",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
