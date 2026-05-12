// ========================================================================================================
// PetroVision Redeem Points Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the RedeemPointsScreen
// used for displaying available redeemable rewards
// within the PetroVision loyalty system.
//
// Features included:
// - Loading customer loyalty points from APIs
// - Loading redeemable reward offers from APIs
// - Filtering active reward offers
// - Displaying reward categories and filters
// - Supporting reward-redemption workflows
// - Navigating users to redemption confirmation screens
// - Managing loading and reward-availability states
// - Providing responsive rewards-list UI
//
// It also integrates loyalty APIs,
// reward-filtering workflows,
// and redemption-management functionality
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'confirm_redemption_screen.dart';
import '../../services/loyalty_api_service.dart';

class RedeemPointsScreen extends StatefulWidget {
  final String userId;

  const RedeemPointsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<RedeemPointsScreen> createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen> {
  String selectedCategory = "All";
  int currentPoints = 0;
  bool isLoading = true;

  List<Map<String, dynamic>> rewards = [];

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _loadData() async {
  int pts = 0;
  List<dynamic> offers = [];

  try {
    pts = await LoyaltyApiService.getPoints(widget.userId);
  } catch (_) {
    pts = 0;
  }

  try {
    offers = await LoyaltyApiService.getAllOffers();
  } catch (_) {
    offers = [];
  }

  if (!mounted) return;

  setState(() {
    currentPoints = pts;

    rewards = offers
        .map((e) => Map<String, dynamic>.from(e))
        .where((offer) =>
            (offer["status"] ?? "Active")
                    .toString()
                    .toLowerCase() ==
                "active" &&
            _toInt(offer["redeem_points"]) > 0)
        .toList();

    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == "All"
        ? rewards
        : rewards.where((e) => e["category"] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          "REDEEM",
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
      body: Column(
        children: [
          _pointsCard(),
          _filterChips(),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No rewards available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _item(context, filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _pointsCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Points",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              isLoading ? "..." : "$currentPoints POINTS",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips() {
    final categories = ["All", "Fuel", "Services", "Coffee"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: categories.map((c) {
          final isSelected = selectedCategory == c;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentBlue.withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    color: isSelected ? accentBlue : Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _item(BuildContext context, Map<String, dynamic> item) {
    final int pointsCost = _toInt(item["redeem_points"]);
    final bool canRedeem = currentPoints >= pointsCost;
    final String offerName = item["name"] ?? "Offer";
    final String category = item["category"] ?? "";
    final String offerId = item["offer_id"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_offer_rounded, color: accentBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offerName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  "$pointsCost PTS",
                  style: const TextStyle(color: Colors.grey),
                ),
                if (category.isNotEmpty)
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: !canRedeem || offerId.isEmpty
                ? null
                : () async {
                    final redeemed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmRedemptionScreen(
                          rewardType: offerName,
                          pointsCost: pointsCost,
                          currentPoints: currentPoints,
                          userId: widget.userId,
                          offerId: offerId,
                        ),
                      ),
                    );

                    if (redeemed == true) {
                      _loadData();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Redeem",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
