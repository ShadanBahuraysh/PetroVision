import 'package:flutter/material.dart';
import '../../services/loyalty_api_service.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  static const primaryNavy = Color(0xFF1A2E35);
  static const accentBlue = Color(0xFF4195AF);
  static const scaffoldBg = Color(0xFFFBFBFB);

  List<dynamic> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final data = await LoyaltyApiService.getAllOffers();
    setState(() {
      offers = data;
      isLoading = false;
    });
  }

  List<Color> _getGradient(String offerType) {
    switch (offerType) {
      case "Fuel Cashback":
        return [const Color(0xFF1A2E35), const Color(0xFF2D4F5E)];
      case "Coffee Combo":
        return [const Color(0xFF4195AF), const Color(0xFF5BB8D4)];
      case "Free Car Wash":
        return [const Color(0xFF1A2E35), const Color(0xFF4195AF)];
      case "Weekend Bonus":
        return [const Color(0xFF4195AF), const Color(0xFF1A2E35)];
      default:
        return [const Color(0xFF1A2E35), const Color(0xFF4195AF)];
    }
  }

  IconData _getIcon(String offerType) {
    switch (offerType) {
      case "Fuel Cashback": return Icons.local_gas_station_rounded;
      case "Coffee Combo": return Icons.coffee_rounded;
      case "Free Car Wash": return Icons.local_car_wash_rounded;
      case "Weekend Bonus": return Icons.stars_rounded;
      default: return Icons.card_giftcard_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          "Special Offers",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
              ? const Center(child: Text("No offers available"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final offerType = offer["offer_type"] ?? "";
                    final gradient = _getGradient(offerType);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(_getIcon(offerType), color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      offer["offer_id"] ?? "",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    offerType,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Earn ${offer["earn_points"]} pts • Redeem ${offer["redeem_points"]} pts",
                                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
