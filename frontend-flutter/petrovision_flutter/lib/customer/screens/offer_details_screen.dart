import 'package:flutter/material.dart';

class OfferDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> offer;

  const OfferDetailsScreen({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);
    const Color scaffoldBg = Color(0xFFFBFBFB);

    final String title =
        offer["name"] ?? offer["offer_type"] ?? "Offer";

    final int earnPoints =
        ((offer["earn_points"] ?? 0) as num).toInt();

    final int redeemPoints =
        ((offer["redeem_points"] ?? 0) as num).toInt();

    final String type =
        offer["offer_type"] ?? "Special Offer";

    return Scaffold(
      backgroundColor: scaffoldBg,

      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: primaryNavy,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "OFFER DETAILS",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentBlue,
                    accentBlue.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: accentBlue.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    type,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [

                      Expanded(
                        child: _pointCard(
                          title: "Earn",
                          value: "$earnPoints pts",
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: _pointCard(
                          title: "Redeem",
                          value: "$redeemPoints pts",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // DESCRIPTION
            const Text(
              "About this offer",
              style: TextStyle(
                color: primaryNavy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Text(
                "Enjoy exclusive rewards with this PetroVision offer. "
                "You can earn loyalty points during fuel purchases and redeem "
                "them later for special station rewards and premium benefits.",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TERMS
            const Text(
              "Terms & Conditions",
              style: TextStyle(
                color: primaryNavy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Column(
                children: const [

                  _TermItem(
                    text: "Offer valid at participating stations only.",
                  ),

                  SizedBox(height: 12),

                  _TermItem(
                    text: "Points cannot be exchanged for cash.",
                  ),

                  SizedBox(height: 12),

                  _TermItem(
                    text: "PetroVision reserves the right to update offers.",
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _pointCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final String text;

  const _TermItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4195AF),
          size: 18,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}