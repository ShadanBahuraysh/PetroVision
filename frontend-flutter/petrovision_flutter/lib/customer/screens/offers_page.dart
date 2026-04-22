import 'package:flutter/material.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  static const primaryNavy = Color(0xFF1A2E35);
  static const accentBlue = Color(0xFF4195AF);
  static const scaffoldBg = Color(0xFFFBFBFB);

  final List<Map<String, dynamic>> promoOffers = const [
    {
      "title": "Free Coffee with Super 91",
      "desc": "Refuel for 50 SAR or more and get a free Espresso from Primo.",
      "icon": Icons.coffee_rounded,
      "tag": "Limited Time",
      "gradient": [Color(0xFF1A2E35), Color(0xFF2D4F5E)],
    },
    {
      "title": "Friday Wash Offer",
      "desc": "Get 20% off on Full Wash every Friday before 12 PM.",
      "icon": Icons.local_car_wash_rounded,
      "tag": "Every Friday",
      "gradient": [Color(0xFF4195AF), Color(0xFF5BB8D4)],
    },
    {
      "title": "Petromin Express Deal",
      "desc": "Change your oil and get a free 10-point safety checkup.",
      "icon": Icons.build_rounded,
      "tag": "Exclusive",
      "gradient": [Color(0xFF1A2E35), Color(0xFF4195AF)],
    },
    {
      "title": "Double Points Weekend",
      "desc": "Earn 2x points on all snacks and drinks this weekend.",
      "icon": Icons.stars_rounded,
      "tag": "Weekend Only",
      "gradient": [Color(0xFF4195AF), Color(0xFF1A2E35)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          "Special Offers",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: promoOffers.length,
            itemBuilder: (context, index) {
              return _OfferCard(offer: promoOffers[index]);
            },
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final gradientColors = offer['gradient'] as List<Color>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // أيقونة
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                offer['icon'] as IconData,
                color: Colors.white,
                size: 26,
              ),
            ),

            const SizedBox(width: 16),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      offer['tag'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    offer['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    offer['desc'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
/*
            // سهم
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
            */
          ],
        ),
      ),
    );
  }
}