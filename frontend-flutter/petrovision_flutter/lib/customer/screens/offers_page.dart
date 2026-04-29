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
        automaticallyImplyLeading: false,
        title: const Text(
          "OFFERS",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBg,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentBlue))
          : offers.isEmpty
              ? const Center(child: Text("No offers available"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final offerType = offer["offer_type"] ?? "";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // أيقونة
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(_getIcon(offerType), color: accentBlue, size: 24),
                            ),

                            const SizedBox(width: 16),

                            // النص
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accentBlue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      offer["offer_id"] ?? "",
                                      style: const TextStyle(
                                        color: accentBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    offerType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: primaryNavy,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "Earn ${offer["earn_points"]} pts • Redeem ${offer["redeem_points"]} pts",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}