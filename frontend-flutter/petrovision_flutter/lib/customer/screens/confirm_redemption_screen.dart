// ========================================================================================================
// PetroVision Confirm Redemption Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the ConfirmRedemptionScreen
// used for confirming loyalty reward redemptions
// within the PetroVision customer rewards system.
//
// Features included:
// - Confirming loyalty reward redemption requests
// - Sending redemption requests to backend APIs
// - Displaying redemption QR/barcode information
// - Displaying reward and remaining-points details
// - Handling redemption loading and error states
// - Displaying redemption success and failure feedback
// - Navigating users to redemption success workflows
// - Providing responsive redemption UI components
//
// It also integrates loyalty redemption APIs,
// reward-confirmation workflows,
// and QR redemption functionality
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import '../../services/loyalty_api_service.dart';
import 'redemption_success_screen.dart';

class ConfirmRedemptionScreen extends StatefulWidget {
  final String rewardType;
  final int pointsCost;
  final int currentPoints;
  final String userId;
  final String offerId;

  const ConfirmRedemptionScreen({
    super.key,
    required this.rewardType,
    required this.pointsCost,
    required this.currentPoints,
    required this.userId,
    required this.offerId
  });

  @override
  State<ConfirmRedemptionScreen> createState() =>
      _ConfirmRedemptionScreenState();
}

class _ConfirmRedemptionScreenState extends State<ConfirmRedemptionScreen> {
  bool _isLoading = false;

  Future<void> _confirmRedeem(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final result = await LoyaltyApiService.redeemPoints(
        userId: widget.userId,
        points: widget.pointsCost,
        offerId: widget.offerId,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result != null) {
        _showBarcode(context, result["redeem_qr_code"] ?? "NO CODE");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Something went wrong, try again"),
            backgroundColor: Colors.red,
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

  void _showBarcode(BuildContext context, String redeemCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Color(0xFF4195AF),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Redeem Offer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A2E35),
                  ),
                ),
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
                  child:  Column(
                    children: [
  const Icon(
    Icons.qr_code_2_rounded,
    size: 180,
    color: Color(0xFF1A2E35),
  ),
  const SizedBox(height: 10),
  Text(
    redeemCode,
    style: const TextStyle(
      letterSpacing: 4,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontSize: 12,
    ),
  ),
],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => RedemptionSuccessScreen(
        userId: widget.userId,
      ),
    ),
  );
},
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1A2E35),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
                    ),
                    child: const Text(
                      "Close",
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingPoints = widget.currentPoints - widget.pointsCost;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          "CONFIRM REDEMPTION",
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
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF1A2E35),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You are redeeming:",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.rewardType,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A2E35),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildPointRow("Points required", "${widget.pointsCost}"),
                    const Divider(height: 20),
                    _buildPointRow("Remaining points", "$remainingPoints"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 220,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _confirmRedeem(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2E35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Show Barcode",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
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

  Widget _buildPointRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1A2E35),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
