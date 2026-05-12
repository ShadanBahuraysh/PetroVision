// ========================================================================================================
// PetroVision Loyalty Dashboard Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the LoyaltyDashboardScreen
// used for displaying customer loyalty data
// and reward-management actions within
// the PetroVision platform.
//
// Features included:
// - Displaying customer loyalty points
// - Displaying membership tier progress
// - Loading loyalty and membership data from APIs
// - Supporting reward earning workflows
// - Supporting reward redemption workflows
// - Displaying tier progression indicators
// - Managing loading and loyalty-data states
// - Providing responsive loyalty dashboard UI
//
// It also integrates loyalty APIs,
// reward-management workflows,
// and customer membership tracking
// within the PetroVision platform.
// ========================================================================================================
import 'package:flutter/material.dart';
import 'package:r/l10n/app_localizations.dart';
import 'earn_points_screen.dart';
import 'redeem_points_screen.dart';
import '../../services/loyalty_api_service.dart';

class LoyaltyDashboardScreen extends StatefulWidget {
  final String userId;

  const LoyaltyDashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<LoyaltyDashboardScreen> createState() =>
      _LoyaltyDashboardScreenState();
}

class _LoyaltyDashboardScreenState extends State<LoyaltyDashboardScreen> {
  int currentPoints = 0;
  String tier = "Bronze";
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  int points = 0;
  Map<String, dynamic>? membership;

  try {
    points = await LoyaltyApiService.getPoints(widget.userId);
  } catch (_) {
    points = 0;
  }

  try {
    membership = await LoyaltyApiService.getMembership(widget.userId);
  } catch (_) {
    membership = null;
  }

  if (!mounted) return;

  setState(() {
    currentPoints = points;
    tier = membership?["tier"] ?? "Bronze";
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);
    const Color scaffoldBg = Color(0xFFFBFBFB);
    final l10n = AppLocalizations.of(context)!;

    final int nextTarget = tier == "Bronze" ? 1000 : 5000;

    final String nextTier = tier == "Bronze"
    ? "Silver"
    : "Gold";

    final double progress = tier == "Gold"
    ? 1.0
    : (currentPoints / nextTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.yourPoints,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$currentPoints",
                            style: const TextStyle(
                                color: accentBlue,
                                fontWeight: FontWeight.w900,
                                fontSize: 26),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14)),
                        child: Text(tier,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tierStatus(tier.toUpperCase()),
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$currentPoints / $nextTarget",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w900),
                        ),
                        Text(
                          l10n.pointsToNextTier(nextTier),
                          style: const TextStyle(
                              color: Colors.black45, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            color: accentBlue,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    l10n.actions,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: primaryNavy),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EarnPointsScreen(
        userId: widget.userId,
      ),
    ),
  );

  _loadData();
},
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: accentBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_rounded,
                                    color: accentBlue, size: 26),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.earn,
                                  style: const TextStyle(
                                      color: accentBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RedeemPointsScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );

                          _loadData();
                        },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: primaryNavy.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.card_giftcard_rounded,
                                    color: primaryNavy, size: 26),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.redeem,
                                  style: const TextStyle(
                                      color: primaryNavy,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
