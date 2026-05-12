// ========================================================================================================
// PetroVision Offer Details Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the OfferDetailsScreen
// used for displaying loyalty-offer details
// and reward actions within the PetroVision platform.
//
// Features included:
// - Displaying loyalty offer information
// - Displaying earn and redeem point values
// - Loading customer loyalty-point data from APIs
// - Supporting QR earning workflows
// - Supporting reward redemption workflows
// - Displaying offer descriptions and terms
// - Managing loading and redemption states
// - Providing responsive offer-details UI
//
// It also integrates loyalty APIs,
// reward-redemption workflows,
// and customer loyalty interactions
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import '../../services/loyalty_api_service.dart';
import 'confirm_redemption_screen.dart';
import 'earn_points_screen.dart';

class OfferDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> offer;
  final String userId;

  const OfferDetailsScreen({
    super.key,
    required this.offer,
    required this.userId,
  });

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  static const Color primaryNavy = Color(0xFF1A2E35);
  static const Color accentBlue = Color(0xFF4195AF);
  static const Color scaffoldBg = Color(0xFFFBFBFB);

  int _currentPoints = 0;
  bool _loadingPoints = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
  int pts = 0;

  try {
    pts = await LoyaltyApiService.getPoints(widget.userId);
  } catch (_) {
    pts = 0;
  }

  if (!mounted) return;

  setState(() {
    _currentPoints = pts;
    _loadingPoints = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final String title   = widget.offer["name"] ?? widget.offer["offer_type"] ?? "Offer";
    final int earnPoints = ((widget.offer["earn_points"]   ?? 0) as num).toInt();
    final int redeemPoints = ((widget.offer["redeem_points"] ?? 0) as num).toInt();
    final String type    = widget.offer["offer_type"] ?? "Special Offer";
    final String offerId = widget.offer["offer_id"] ?? "";
    final bool canRedeem = !_loadingPoints && _currentPoints >= redeemPoints && redeemPoints > 0;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "OFFER DETAILS",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentBlue, accentBlue.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: accentBlue.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text(type, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(child: _pointCard(title: "Earn", value: "$earnPoints pts")),
                      const SizedBox(width: 14),
                      Expanded(child: _pointCard(title: "Redeem", value: "$redeemPoints pts")),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Action buttons ─────────────────────────────────────────────
            Row(
              children: [
                // EARN button — opens QR scanner/manual entry
                if (earnPoints > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EarnPointsScreen(userId: widget.userId),
                        ),
                      ).then((_) => _loadPoints()),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text("Earn Points"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                if (earnPoints > 0 && redeemPoints > 0) const SizedBox(width: 12),
                // REDEEM button
                if (redeemPoints > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadingPoints
                          ? null
                          : !canRedeem
                              ? null
                              : () async {
                                  final redeemed = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ConfirmRedemptionScreen(
                                        rewardType: title,
                                        pointsCost: redeemPoints,
                                        currentPoints: _currentPoints,
                                        userId: widget.userId,
                                        offerId: offerId,
                                      ),
                                    ),
                                  );
                                  if (redeemed == true) _loadPoints();
                                },
                      icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                      label: _loadingPoints
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(canRedeem ? "Redeem" : "Need ${redeemPoints - _currentPoints} more pts"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canRedeem ? accentBlue : Colors.grey.shade300,
                        foregroundColor: canRedeem ? Colors.white : Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // ── About ──────────────────────────────────────────────────────
            const Text("About this offer",
                style: TextStyle(color: primaryNavy, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                "Enjoy exclusive rewards with this PetroVision offer. "
                "You can earn loyalty points during fuel purchases and redeem "
                "them later for special station rewards and premium benefits.",
                style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),

            // ── Terms ──────────────────────────────────────────────────────
            const Text("Terms & Conditions",
                style: TextStyle(color: primaryNavy, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: const [
                  _TermItem(text: "Each offer can only be earned once per user."),
                  SizedBox(height: 12),
                  _TermItem(text: "Points cannot be exchanged for cash."),
                  SizedBox(height: 12),
                  _TermItem(text: "PetroVision reserves the right to update offers."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pointCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String text;
  const _TermItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF4195AF), size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700, height: 1.5))),
      ],
    );
  }
}
