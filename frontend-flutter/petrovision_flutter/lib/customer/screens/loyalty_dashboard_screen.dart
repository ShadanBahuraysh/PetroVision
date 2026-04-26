import 'package:flutter/material.dart';
import 'earn_points_screen.dart';
import 'redeem_points_screen.dart';
import '../../services/loyalty_api_service.dart';

class LoyaltyDashboardScreen extends StatefulWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  State<LoyaltyDashboardScreen> createState() => _LoyaltyDashboardScreenState();
}

class _LoyaltyDashboardScreenState extends State<LoyaltyDashboardScreen> {
  int currentPoints = 0;
  String tier = "Bronze";
  bool isLoading = true;

  final String userId = "U-0003";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final points = await LoyaltyApiService.getPoints(userId);
    final membership = await LoyaltyApiService.getMembership(userId);
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

    int nextTarget = tier == "Gold" ? 2000 : 1000;
    String nextTier = tier == "Bronze" ? "Silver" : "Gold";
    double progress = (currentPoints / nextTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "LOYALTY PROGRAM",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
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
                          const Text("Your Points",
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text("$currentPoints",
                              style: const TextStyle(color: accentBlue, fontWeight: FontWeight.w900, fontSize: 26)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                        child: Text(tier, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
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
                        Text("${tier.toUpperCase()} STATUS",
                            style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Text("$currentPoints / $nextTarget",
                            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                        Text("Points to $nextTier Tier",
                            style: const TextStyle(color: Colors.black45, fontSize: 13)),
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
                  const Text("Actions",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarnPointsScreen())),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(color: accentBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, color: accentBlue, size: 26),
                                SizedBox(height: 8),
                                Text("Earn", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RedeemPointsScreen())),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(color: primaryNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_giftcard_rounded, color: primaryNavy, size: 26),
                                SizedBox(height: 8),
                                Text("Redeem", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w700, fontSize: 13)),
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
