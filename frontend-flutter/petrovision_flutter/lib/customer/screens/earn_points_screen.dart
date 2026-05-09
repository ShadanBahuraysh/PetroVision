// ========================================================================================================
// PetroVision Earn Points Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the EarnPointsScreen used
// for scanning and redeeming loyalty QR codes
// within the PetroVision customer rewards system.
//
// Features included:
// - Scanning QR codes using the device camera
// - Supporting manual QR-code entry
// - Validating QR-code formats
// - Sending loyalty-point requests to backend APIs
// - Displaying earned-points feedback messages
// - Handling invalid and duplicate QR-code usage
// - Managing loading and redemption states
// - Displaying responsive scanning and dialog UI
//
// It also integrates QR scanning workflows,
// loyalty-point APIs,
// and customer reward operations
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/loyalty_api_service.dart';

class EarnPointsScreen extends StatefulWidget {
  final String userId;

  const EarnPointsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<EarnPointsScreen> createState() =>
      _EarnPointsScreenState();
}

class _EarnPointsScreenState extends State<EarnPointsScreen> {
  final String tier = "Bronze";
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

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
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF1A2E35), size: 20),
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

            // QR SCANNER
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: Stack(
                  children: [
                    MobileScanner(
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final raw = barcodes.first.rawValue ?? '';
                          final code = raw.trim().toUpperCase();
                          final regex = RegExp(r'^EFC-[0-9]{4}$');
                          if (regex.hasMatch(code)) {
                            _handleQrCode(context, code, primaryNavy, accentBlue);
                          }
                        }
                      },
                    ),
                    // Scan overlay hint
                    Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () => _dialog(this.context, primaryNavy, accentBlue),
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

  // Called both from camera scan AND manual entry
Future<void> _handleQrCode(BuildContext context, String code, Color navy, Color blue) async {
  if (_isLoading) return;

  setState(() => _isLoading = true);

  try {
    final result = await LoyaltyApiService.scanEarnQr(
      qrCode: code,
      userId: widget.userId,
      amount: 100,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    final scaffoldContext = context;

    if (result != null && result['error'] != true) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text("✅ +${result['earned_points']} points added!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final String detail = (result?['detail'] ?? '').toString();
      final bool alreadyUsed = detail.toLowerCase().contains('already');

      showDialog(
        context: scaffoldContext,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                alreadyUsed ? Icons.info_outline_rounded : Icons.error_outline_rounded,
                color: alreadyUsed ? const Color(0xFF4195AF) : Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alreadyUsed ? "Offer Already Used" : "Something Went Wrong",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            alreadyUsed
                ? "You have already earned points from this offer.\n\nEach offer can only be used once per user."
                : "Could not process the QR code. Please try again.",
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(scaffoldContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2E35),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Connection error. Try again."),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _dialog(BuildContext context, Color navy, Color blue) {
    _codeController.clear();
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
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            decoration: InputDecoration(
            hintText: "EFC-0001",
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
            onPressed: _isLoading
                ? null
                : () async {
                    final code = _codeController.text.trim().toUpperCase();
                    final regex = RegExp(r'^EFC-[0-9]{4}$');
                    if (!regex.hasMatch(code)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid code like EFC-0001"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    // Use the outer scaffold context, not the dialog context
                    if (mounted) {
                      await _handleQrCode(this.context, code, navy, blue);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Submit",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}