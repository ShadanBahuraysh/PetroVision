import 'package:flutter/material.dart';
import 'confirm_redemption_screen.dart';
import '../../services/loyalty_api_service.dart';

class RedeemPointsScreen extends StatefulWidget {
  const RedeemPointsScreen({super.key});

  @override
  State<RedeemPointsScreen> createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen> {
  String selectedCategory = "All";
  int currentPoints = 0;
  bool isLoading = true;
  final String userId = "U-0003";

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final List<Map<String, dynamic>> rewards = [
    {"title": "Fuel Voucher", "pts": 2000, "cat": "Fuel", "icon": Icons.local_gas_station},
    {"title": "Oil Filter", "pts": 450, "cat": "Services", "icon": Icons.build},
    {"title": "Car Wash", "pts": 600, "cat": "Services", "icon": Icons.local_car_wash},
    {"title": "Coffee", "pts": 350, "cat": "Coffee", "icon": Icons.coffee},
  ];

  // ✅ جديد — تجيب النقاط من الـ API
  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final pts = await LoyaltyApiService.getPoints(userId);
    setState(() {
      currentPoints = pts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == "All"
        ? rewards
        : rewards.where((e) => e["cat"] == selectedCategory).toList();

    return Scaffold(
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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A2E35), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
        children: [
          const Text("Your Points", style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          // ✅ جديد — النقاط الحقيقية
          isLoading
              ? const CircularProgressIndicator()
              : Text(
                  "$currentPoints POINTS",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
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
                Text("${item['pts']} PTS", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: currentPoints < item['pts']
                ? null  // ✅ الزر يتعطل لو ما في نقاط كافية
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmRedemptionScreen(
                          rewardType: item['title'],
                          pointsCost: item['pts'],        // ✅ جديد
                          currentPoints: currentPoints,   // ✅ جديد
                          userId: userId,                 // ✅ جديد
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Redeem", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
