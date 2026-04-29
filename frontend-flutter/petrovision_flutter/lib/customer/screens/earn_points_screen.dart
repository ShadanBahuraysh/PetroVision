import 'package:flutter/material.dart';

class EarnPointsScreen extends StatelessWidget {
  const EarnPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);
    const Color scaffoldBg = Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
  title: const Text(
    "EARN POINTS",
    style: TextStyle(
      color: Color(0xFF1A2E35),
      fontWeight: FontWeight.w900,
      fontSize: 16,
      letterSpacing: 2,
    ),
  ),
  centerTitle: true,
  backgroundColor: const Color(0xFFFBFBFB),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A2E35), size: 20),
    onPressed: () => Navigator.pop(context),
  ),
),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Scan receipt QR code to add points",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 40),

            // QR BOX
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryNavy,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 90,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () => _dialog(context, primaryNavy, accentBlue),
                icon: const Icon(Icons.keyboard_outlined),
                label: const Text(
                  "ENTER CODE MANUALLY",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentBlue,
                  side: BorderSide(color: accentBlue.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dialog(BuildContext context, Color navy, Color blue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Enter Receipt Code",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: navy,
            fontSize: 16,
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: "12-digit code",
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}