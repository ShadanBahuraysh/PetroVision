import 'package:flutter/material.dart';
import 'redeem_points_screen.dart';

class ConfirmRedemptionScreen extends StatelessWidget {
  final String rewardType;
  const ConfirmRedemptionScreen({super.key, required this.rewardType});

  void _showBarcode(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4195AF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer_rounded, color: Color(0xFF4195AF), size: 30),
                ),
                const SizedBox(height: 20),
                const Text("Redeem Offer",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A2E35))),
                const SizedBox(height: 8),
                Text(
                  "Scan this code at the station",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.qr_code_2_rounded, size: 180, color: Color(0xFF1A2E35)),
                      SizedBox(height: 10),
                      Text("PV-9928-110", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RedeemPointsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2E35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text("CONFIRM REDEMPTION", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFFFBFBFB),
        foregroundColor: const Color(0xFF1A2E35),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center( // أضفنا Center ليكون الزر في المنتصف
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى عمودياً
            children: [
              Text("You are redeeming:", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(rewardType, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A2E35))),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildPointRow("Points required", "200"),
                    const Divider(height: 20),
                    _buildPointRow("Remaining points", "595"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // تعديل عرض الزر هنا ليكون مثل حجم أزرار الـ Login
              SizedBox(
                width: 220, // العرض المحدد ليناسب حجم زر Login العادي
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _showBarcode(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4195AF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Show Barcode", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Color(0xFF1A2E35), fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}