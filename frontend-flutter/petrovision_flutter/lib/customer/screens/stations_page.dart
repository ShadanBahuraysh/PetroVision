import 'package:flutter/material.dart';
import 'dart:math';
import 'package:webview_flutter/webview_flutter.dart';
class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final List<Map<String, dynamic>> stations = const [
    {
      "title": "Petromin - Al Rawdah",
      "location": "Prince Sultan St, Jeddah",
      "phone": "920003467",
      "hours": "24 Hours",
      "featured": true,
      "offers": ["⭐ Double Points this weekend", "☕ Free coffee with 91 refuel", "🚗 Free car wash over 100 SAR"],
      "lat": 21.5524694,
      "lng": 39.2093806,
    },
    {
      "title": "Petromin - Al Salamah",
      "location": "Madinah Rd, Jeddah",
      "phone": "920003467",
      "hours": "06:00 AM - 12:00 AM",
      "featured": false,
      "lat": 21.5720716,
      "lng": 39.1679925,
    },
    {
      "title": "Petromin - Al Zahra",
      "location": "King Abdulaziz Rd, Jeddah",
      "phone": "920003467",
      "hours": "24 Hours",
      "featured": false,
      "lat": 21.612111,
      "lng": 39.187835,
    },
    {
      "title": "Petromin - Al Shatea",
      "location": "Corniche Rd, Jeddah",
      "phone": "920003467",
      "hours": "24 Hours",
      "featured": false,
      "lat": 21.6045923,
      "lng": 39.2107013,
    },
    {
      "title": "Petromin - Al Safa",
      "location": "Umm Al Qura St, Jeddah",
      "phone": "920003467",
      "hours": "06:00 AM - 11:00 PM",
      "featured": false,
      "lat": 21.5264332,
      "lng": 39.1618967,
    },
    {
      "title": "Petromin - Al Nahda",
      "location": "Hira St, Jeddah",
      "featured": false,
      "lat": 21.5882313,
      "lng": 39.2056387,
    },
    {
      "title": "Petromin - Al Naseem",
      "location": "Abu Tharr St, Jeddah",
      "featured": false,
      "lat": 21.5947949,
      "lng": 39.1946771,
    },
    {
      "title": "Petromin - Al Hamra",
      "location": "Palestine St, Jeddah",
      "featured": false,
      "lat": 21.6270379,
      "lng": 39.1504914,
    },
    {
      "title": "Petromin - Al Rehab",
      "location": "Tahliah St, Jeddah",
      "featured": false,
      "lat": 21.5983365,
      "lng": 39.1639004,
    },
    {
      "title": "Petromin - Al Marwah",
      "location": "Majid Rd, Jeddah",
      "featured": false,
      "lat": 21.5808299,
      "lng": 39.2297679,
    },
    {
      "title": "Petromin - Al Fayhaa",
      "location": "Abdullah Sulayman St, Jeddah",
      "featured": false,
      "lat": 21.5724772,
      "lng": 39.1895818,
    },
    {
      "title": "Petromin - Al Ruwais",
      "location": "Ha'il St, Jeddah",
      "featured": false,
      "lat": 21.5622171,
      "lng": 39.186363,
    },
    {
      "title": "Petromin - Obhur",
      "location": "South Obhur Rd, Jeddah",
      "featured": false,
      "lat": 21.565322,
      "lng": 39.21123,
    },
    {
      "title": "Petromin - Al Naeem",
      "location": "Al Amal St, Jeddah",
      "featured": false,
      "lat": 21.547389,
      "lng": 39.209635,
    },
    {
      "title": "Petromin - Al Basateen",
      "location": "Asalam St, Jeddah",
      "featured": false,
      "lat": 21.6164709,
      "lng": 39.1720017,
    },
    {
      "title": "Petromin - Al Aziziyah",
      "location": "Ghernata St, Jeddah",
      "featured": false,
      "lat": 21.521843,
      "lng": 39.181289,
    },
    {
      "title": "Petromin - Al Muhammadiyah",
      "location": "Sultan St North, Jeddah",
      "featured": false,
      "lat": 21.5725602,
      "lng": 39.1895313,
    },
    {
      "title": "Petromin - Al Kandarah",
      "location": "King Fahd Rd, Jeddah",
      "featured": false,
      "lat": 21.580386,
      "lng": 39.210192,
    },
    {
      "title": "Petromin - Al Baghdadiyah",
      "location": "King Khalid Rd, Jeddah",
      "featured": false,
      "lat": 21.6512419,
      "lng": 39.7071682,
    },
    {
      "title": "Petromin - Al Balad",
      "location": "Dhahab St, Jeddah",
      "featured": false,
      "lat": 21.5739276,
      "lng": 39.229025,
    },
  ];

  // توزيع عشوائي: 2 أحمر، 3 برتقالي، الباقي أخضر
  late final List<String> _statuses;

  @override
  void initState() {
    super.initState();
    _statuses = _generateStatuses(stations.length);
  }

  List<String> _generateStatuses(int count) {
  final list = List<String>.filled(count, 'green');
  list[0] = 'green';  // الأولى خضراء (featured)
  list[1] = 'green';  // الثانية خضراء
  list[2] = 'red';    // الثالثة حمراء
  list[3] = 'orange'; // الرابعة برتقالية
  list[4] = 'orange'; // الخامسة برتقالية
  // الباقي يبقى أخضر
  return list;
}

  Color _statusColor(String status) {
    switch (status) {
      case 'green': return const Color(0xFF22C55E);
      case 'orange': return const Color(0xFFF59E0B);
      case 'red': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color scaffoldBg = Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          final station = stations[index];
          final bool isFeatured = station['featured'] == true;
          final Color statusColor = _statusColor(_statuses[index]);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _showStationDetails(context, station),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isFeatured
                        ? const Color(0xFF22C55E).withOpacity(0.4)
                        : Colors.grey.shade200,
                    width: isFeatured ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isFeatured
                          ? const Color(0xFF22C55E).withOpacity(0.08)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // أيقونة الموقع
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: statusColor,
                            size: 24,
                          ),
                        ),
                        if (isFeatured)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showFeaturedOffers(context, station),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFACC15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  station['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: primaryNavy,
                                  ),
                                ),
                              ),
                              if (isFeatured)
                                GestureDetector(
                                  onTap: () => _showFeaturedOffers(context, station),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFACC15).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFACC15)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded, size: 12, color: Color(0xFFFACC15)),
                                        SizedBox(width: 3),
                                        Text(
                                          "Featured",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            station['location'],
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
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

  void _showFeaturedOffers(BuildContext context, Map<String, dynamic> station) {
    const Color primaryNavy = Color(0xFF1A2E35);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    station['title'],
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("Special offers at this station:", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 16),
            ...List<String>.from(station['offers'] ?? []).map(
              (offer) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
                ),
                child: Text(offer, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryNavy)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showStationDetails(BuildContext context, Map<String, dynamic> station) {
  const Color primaryNavy = Color(0xFF1A2E35);
  const Color accentBlue = Color(0xFF4195AF);
  const apiKey = 'AIzaSyDjdMGkREctRQN52HyAOaC6PS04H-j47Vs';

  final double lat = station['lat'] ?? 21.5433;
  final double lng = station['lng'] ?? 39.1728;

  final mapHtml = '''
    <!DOCTYPE html><html>
    <head><style>body,html,#map{margin:0;padding:0;width:100%;height:100%;}</style></head>
    <body>
      <div id="map"></div>
      <script>
        function initMap() {
          var pos = {lat: $lat, lng: $lng};
          var map = new google.maps.Map(document.getElementById('map'), {
            center: pos, zoom: 15,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false,
          });
          new google.maps.Marker({position: pos, map: map});
        }
      </script>
      <script src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap" async defer></script>
    </body></html>
  ''';

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadHtmlString(mapHtml);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: WebViewWidget(controller: controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(station['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: primaryNavy)),
                const SizedBox(height: 6),
                Text(station['location'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
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