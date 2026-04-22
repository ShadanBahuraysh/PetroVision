import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);

  final List<Map<String, dynamic>> historyItems = const [
    {
      "station": "Petromin - Al Rawdah",
      "date": "2023-10-25 | 04:30 PM",
      "points": "+50 PTS",
      "type": "Earning",
      "icon": Icons.add_circle_outline_rounded,
    },
    {
      "station": "Free Espresso - Primo",
      "date": "2023-10-22 | 09:15 AM",
      "points": "-350 PTS",
      "type": "Redeemed",
      "icon": Icons.remove_circle_outline_rounded,
    },
    {
      "station": "Petromin - Al Salamah",
      "date": "2023-10-20 | 08:00 PM",
      "points": "+45 PTS",
      "type": "Earning",
      "icon": Icons.add_circle_outline_rounded,
    },
    {
      "station": "Fuel Discount Voucher",
      "date": "2023-10-15 | 01:20 PM",
      "points": "-1200 PTS",
      "type": "Redeemed",
      "icon": Icons.confirmation_number_outlined,
    },
    {
      "station": "Petromin - Al Zahra",
      "date": "2023-10-10 | 11:45 AM",
      "points": "+60 PTS",
      "type": "Earning",
      "icon": Icons.add_circle_outline_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text(
          "TRANSACTION HISTORY",
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 14, 
            letterSpacing: 1.5
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          bool isEarning = item['type'] == "Earning";

          // تحديد اللون بناءً على النوع باستخدام ألوان الهوية فقط
          Color themeColor = isEarning ? accentBlue : primaryNavy;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4)
                )
              ],
            ),
            child: Row(
              children: [
                // أيقونة النوع بستايل الهوية
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item['icon'], color: themeColor, size: 20),
                ),
                const SizedBox(width: 16),
                // تفاصيل العملية
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['station'],
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          color: primaryNavy, 
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['date'],
                        style: TextStyle(
                          color: Colors.grey.shade500, 
                          fontSize: 11,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ),
                // قيمة النقاط
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['points'],
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: themeColor,
                      ),
                    ),
                    Text(
                      item['type'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}