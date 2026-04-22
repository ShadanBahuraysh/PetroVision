import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          "TERMS & CONDITIONS",
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 14, 
            letterSpacing: 1.5
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Welcome to PetroVision",
              style: TextStyle(
                color: primaryNavy, 
                fontWeight: FontWeight.bold, 
                fontSize: 25, // Size 20
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Effective Date: April 2026\nBy using our app, you agree to these Terms and Conditions. Please read them carefully.",
              style: TextStyle(
                color: Colors.grey.shade600, 
                fontSize: 14, 
                height: 1.5
              ),
            ),
            const SizedBox(height: 35),
            // ---------------------------------------

            // بنود الشروط
            _buildSection("1. Use of the App", [
              "PetroVision is intended for personal, non-commercial use.",
              "You must be at least 18 years old to use the app.",
              "You are responsible for maintaining the confidentiality of your account and password.",
            ]),
            _buildSection("2. Loyalty Points and Rewards", [
              "Points are earned based on transactions at PetroMin stations and participating partners.",
              "Points have no cash value and cannot be exchanged for money.",
              "Rewards must be redeemed through the app and are subject to availability.",
              "PetroVision reserves the right to modify or cancel rewards at any time.",
            ]),
            _buildSection("3. Offers and Promotions", [
              "All offers and promotions are subject to terms set by PetroMin stations or their partners.",
              "PetroVision is not responsible for errors, inaccuracies, or expiration of offers.",
            ]),
            _buildSection("4. User Content", [
              "Any content you submit (reviews, feedback, or suggestions) may be used by PetroVision to improve services.",
              "You grant PetroVision a non-exclusive, royalty-free license to use your content.",
            ]),
            _buildSection("5. Privacy", [
              "Your use of the app is also governed by our Privacy Policy, which explains how we collect, use, and protect your information.",
            ]),
            _buildSection("6. Limitation of Liability", [
              "PetroVision is provided “as is” without warranties of any kind.",
              "We are not liable for any damages resulting from your use of the app or inability to access it.",
            ]),
            _buildSection("7. Termination", [
              "We may suspend or terminate your access if you violate these Terms and Conditions.",
              "Upon termination, your account and points may be deactivated.",
            ]),
            _buildSection("8. Changes to Terms", [
              "PetroVision may update these Terms and Conditions at any time.",
              "Continued use of the app after changes constitutes acceptance of the updated terms.",
            ]),
            _buildSection("9. Governing Law", [
              "These Terms are governed by the laws of the country where PetroMin operates.",
            ]),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              color: primaryNavy, 
              fontSize: 15
            ),
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.circle, color: accentBlue, size: 6), // نقطة أنيقة
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      color: Colors.grey.shade700, 
                      fontSize: 13, 
                      height: 1.5
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}