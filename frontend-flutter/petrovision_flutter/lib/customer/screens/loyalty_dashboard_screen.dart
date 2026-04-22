import 'package:flutter/material.dart';
import 'earn_points_screen.dart';
import 'redeem_points_screen.dart';

class LoyaltyDashboardScreen extends StatelessWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);
    const Color scaffoldBg = Color(0xFFFBFBFB);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Points",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "750", // تم التعديل هنا
                      style: TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
                _buildMiniTierBadge()
              ],
            ),

            const SizedBox(height: 30),

            _buildMembershipCard(),

            const SizedBox(height: 35),

            // قسم الـ Actions تم رفعه هنا
            const Text(
              "Actions",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: primaryNavy,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Earn",
                    Icons.add_rounded,
                    accentBlue,
                    const EarnPointsScreen(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    "Redeem",
                    Icons.card_giftcard_rounded,
                    primaryNavy,
                    const RedeemPointsScreen(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // 🔥 Timeline Tracker (Journey) صار تحت الـ Actions
            _buildTierProgress(),

            const SizedBox(height: 35),

            const Text(
              "How it works",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: primaryNavy,
              ),
            ),
            const SizedBox(height: 14),
            _buildExplainerSection(accentBlue),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTierBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        "Bronze",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMembershipCard() {
    const Color accentBlue = Color(0xFF4195AF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BRONZE STATUS",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "750 / 1,000", // تم التعديل هنا
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            "Points to Silver Tier",
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.750, // التقدم أصبح شبه مكتمل
              backgroundColor: Colors.grey.shade200,
              color: accentBlue,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierProgress() {
    double currentPoints = 750; // تحديث القيمة هنا أيضاً

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Membership Journey",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        _timelineItem(
          title: "Bronze",
          points: "0 pts",
          subtitle: "You are here",
          achieved: true,
          isCurrent: true,
          isLast: false,
        ),
        _timelineItem(
          title: "Silver",
          points: "1,000 pts",
          subtitle: "${1000 - currentPoints.toInt()} points to unlock",
          achieved: currentPoints >= 1000,
          isCurrent: false,
          isLast: false,
        ),
        _timelineItem(
          title: "Gold",
          points: "2,000 pts",
          subtitle: "${2000 - currentPoints.toInt()} points to unlock",
          achieved: currentPoints >= 2000,
          isCurrent: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _timelineItem({
    required String title,
    required String points,
    required String subtitle,
    required bool achieved,
    required bool isCurrent,
    required bool isLast,
  }) {
    const Color accentBlue = Color(0xFF4195AF);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: achieved || isCurrent ? accentBlue : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(
                        color: accentBlue.withOpacity(0.3),
                        width: 4,
                      )
                    : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: achieved ? accentBlue : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: achieved || isCurrent ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                points,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrent ? accentBlue : Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExplainerSection(Color blue) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _stepItem(Icons.add_task_rounded, "Earn Points", "Get 1 point for every 10 SAR spent.", blue),
          const SizedBox(height: 12),
          _stepItem(Icons.redeem_rounded, "Redeem Rewards", "Exchange points for rewards.", blue),
          const SizedBox(height: 12),
          _stepItem(Icons.trending_up_rounded, "Level Up", "Unlock better benefits.", blue),
        ],
      ),
    );
  }

  Widget _stepItem(IconData icon, String title, String desc, Color blue) {
    return Row(
      children: [
        Icon(icon, size: 18, color: blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}