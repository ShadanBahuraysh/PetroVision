import 'package:flutter/material.dart';
import 'confirm_redemption_screen.dart';

class RedeemPointsScreen extends StatefulWidget {
  const RedeemPointsScreen({super.key});

  @override
  State<RedeemPointsScreen> createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen> {
  String selectedCategory = "All";

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final List<Map<String, dynamic>> rewards = [
    {"title": "Fuel Voucher", "pts": "2000 PTS", "cat": "Fuel", "icon": Icons.local_gas_station},
    {"title": "Oil Filter", "pts": "450 PTS", "cat": "Services", "icon": Icons.build},
    {"title": "Car Wash", "pts": "600 PTS", "cat": "Services", "icon": Icons.local_car_wash},
    {"title": "Coffee", "pts": "350 PTS", "cat": "Coffee", "icon": Icons.coffee},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == "All"
        ? rewards
        : rewards.where((e) => e["cat"] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          "REDEEM",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        backgroundColor: scaffoldBg,
        foregroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _pointsCard(),
          _filterChips(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              itemBuilder: (context, i) => _item(context, filtered[i]),
            ),
          )
        ],
      ),
    );
  }

  Widget _pointsCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Your Points", style: TextStyle(color: Colors.black54, fontSize: 12)),
          SizedBox(height: 4),
          Text("795 POINTS", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? accentBlue.withOpacity(0.15) : Colors.grey.shade100,
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
            child: Icon(item['icon'], color: accentBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(item['pts'], style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfirmRedemptionScreen(
                    rewardType: item['title'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Redeem", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}