import 'package:flutter/material.dart';
import 'package:r/l10n/app_localizations.dart';
import '../../services/loyalty_api_service.dart';
import 'offer_details_screen.dart';
class OffersPage extends StatefulWidget {
  final String userId;
  const OffersPage({super.key, required this.userId});

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
    offers = data.where((offer) {
  return (offer["status"] ?? "Active").toString().toLowerCase() == "active";
}).toList();
    offers.sort((a, b) {
      final aPoints = ((a["earn_points"] ?? 0) as num).toInt();
      final bPoints = ((b["earn_points"] ?? 0) as num).toInt();
      return bPoints.compareTo(aPoints);
    });
    isLoading = false;
  });
}

  IconData _getIcon(String offerType) {
    switch (offerType) {
      case "Fuel Cashback":
        return Icons.local_gas_station_rounded;
      case "Coffee Combo":
        return Icons.coffee_rounded;
      case "Free Car Wash":
        return Icons.local_car_wash_rounded;
      case "Weekend Bonus":
        return Icons.stars_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentBlue))
          : offers.isEmpty
              ? Center(child: Text(l10n.noOffersAvailable))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final offerType = offer["name"] ?? offer["offer_type"] ?? "Offer";
                    final earnPts =
                        ((offer["earn_points"] ?? 0) as num).toInt();
                    final redeemPts =
                        ((offer["redeem_points"] ?? 0) as num).toInt();

                    return Padding(
                       padding: const EdgeInsets.only(bottom: 16),
  child: InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OfferDetailsScreen(
            offer: offer,
            userId: widget.userId,
          ),
        ),
      );
    },
    child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(_getIcon(offerType),
                                  color: accentBlue, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
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
                                    l10n.earnRedeemPoints(earnPts, redeemPts),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}