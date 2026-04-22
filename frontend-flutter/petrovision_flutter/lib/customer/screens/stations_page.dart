import 'package:flutter/material.dart';

class StationsPage extends StatelessWidget {
  const StationsPage({super.key});

  final List<Map<String, String>> stations = const [
    {"title": "Petromin - Al Rawdah", "location": "Prince Sultan St, Jeddah", "phone": "920003467", "hours": "24 Hours"},
    {"title": "Petromin - Al Salamah", "location": "Madinah Rd, Jeddah", "phone": "920003467", "hours": "06:00 AM - 12:00 AM"},
    {"title": "Petromin - Al Zahra", "location": "King Abdulaziz Rd, Jeddah", "phone": "920003467", "hours": "24 Hours"},
    {"title": "Petromin - Al Shatea", "location": "Corniche Rd, Jeddah", "phone": "920003467", "hours": "24 Hours"},
    {"title": "Petromin - Al Safa", "location": "Umm Al Qura St, Jeddah", "phone": "920003467", "hours": "06:00 AM - 11:00 PM"},
    {"title": "Petromin - Al Nahda", "location": "Hira St, Jeddah"},
    {"title": "Petromin - Al Naseem", "location": "Abu Tharr St, Jeddah"},
    {"title": "Petromin - Al Hamra", "location": "Palestine St, Jeddah"},
    {"title": "Petromin - Al Rehab", "location": "Tahliah St, Jeddah"},
    {"title": "Petromin - Al Marwah", "location": "Majid Rd, Jeddah"},
    {"title": "Petromin - Al Fayhaa", "location": "Abdullah Sulayman St, Jeddah"},
    {"title": "Petromin - Al Ruwais", "location": "Ha'il St, Jeddah"},
    {"title": "Petromin - Obhur", "location": "South Obhur Rd, Jeddah"},
    {"title": "Petromin - Al Naeem", "location": "Al Amal St, Jeddah"},
    {"title": "Petromin - Al Basateen", "location": "Asalam St, Jeddah"},
    {"title": "Petromin - Al Aziziyah", "location": "Ghernata St, Jeddah"},
    {"title": "Petromin - Al Muhammadiyah", "location": "Sultan St North, Jeddah"},
    {"title": "Petromin - Al Kandarah", "location": "King Fahd Rd, Jeddah"},
    {"title": "Petromin - Al Baghdadiyah", "location": "King Khalid Rd, Jeddah"},
    {"title": "Petromin - Al Balad", "location": "Dhahab St, Jeddah"},
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);
    const Color scaffoldBg = Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        // --- السطر المطلوب لإخفاء سهم العودة ---
        automaticallyImplyLeading: false, 
        // ---------------------------------------
        title: const Text(
          "STATIONS",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          bool isClickable = index < 5;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: isClickable ? () => _showStationDetails(context, stations[index]) : null,
              borderRadius: BorderRadius.circular(24),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isClickable ? accentBlue.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_gas_station_rounded, 
                        color: isClickable ? accentBlue : Colors.grey.shade400,
                        size: 24
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stations[index]['title']!, 
                            style: TextStyle(
                              fontWeight: FontWeight.w800, 
                              fontSize: 15,
                              color: primaryNavy.withOpacity(isClickable ? 1 : 0.6)
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stations[index]['location']!, 
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                    if (isClickable)
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStationDetails(BuildContext context, Map<String, String> station) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1569336415962-a4bd4f79c3f2?q=80&w=1931'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: primaryNavy)),
                  const SizedBox(height: 6),
                  Text(station['location']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1),
                  ),
                  _infoRow(Icons.access_time_filled_rounded, "Working Hours", station['hours'] ?? "24 Hours", accentBlue),
                  const SizedBox(height: 18),
                  _infoRow(Icons.phone_rounded, "Contact Number", station['phone'] ?? "920003467", accentBlue),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryNavy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2E35))),
          ],
        ),
      ],
    );
  }
}