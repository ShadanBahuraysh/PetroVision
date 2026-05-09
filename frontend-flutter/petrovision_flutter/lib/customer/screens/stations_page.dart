// ========================================================================================================
// PetroVision Stations Page
// --------------------------------------------------------------------------------------------------------
// This file defines the StationsPage used for
// displaying PetroVision fuel stations
// and nearby station information within the application.
//
// Features included:
// - Loading station data from backend APIs
// - Displaying nearby stations and station details
// - Supporting geolocation and distance calculations
// - Sorting stations based on user proximity
// - Opening station locations in Google Maps
// - Displaying interactive station-detail dialogs
// - Displaying featured station offers
// - Supporting interactive station maps using FlutterMap
// - Managing loading, location, and station states
// - Providing responsive station-list UI components
//
// It also integrates station APIs,
// geolocation services,
// map visualization workflows,
// and station-navigation functionality
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:r/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  List<Map<String, dynamic>> stations = [];
  List<String> _statuses = [];
  bool _isLoading = true;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadStations().then((_) => _getUserLocation());
  }

  Future<void> _loadStations() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/stations-db'));
      if (response.statusCode == 200) {
        List data = [];
          try {
            data = json.decode(response.body);
          } catch (_) {
            data = [];
          }
        final List<Map<String, dynamic>> loaded = data.map((s) => {
          "title": "Petromin - ${s['name']}",
          "location": s['address'] ?? '',
          "phone": "920003467",
          "hours": "24 Hours",
          "featured": s['name'] == 'Haddaf',
          "offers": ["⭐ Double Points this weekend", "☕ Free coffee with 91 refuel", "🚗 Free car wash over 100 SAR"],
          "lat": s['lat'],
          "lng": s['lng'],
          "status": s['status'] ?? 'active',
        }).toList();
        if (!mounted) return;
        setState(() {
          stations = loaded;
          _statuses = _generateStatuses(loaded.length);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
    if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getUserLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please enable location services',
      ),
    ),
  );

  return;
}

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Location permission is required',
      ),
    ),
  );

  return;
}
    }
    if (permission == LocationPermission.deniedForever) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Location permission permanently denied',
      ),
    ),
  );

  return;
}

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    if (!mounted) return;
    setState(() => _userPosition = position);
    _sortByDistance();
  } catch (e) {
    debugPrint('Location error: $e');
  }
}
Future<void> _openGoogleMaps(double lat, double lng) async {
  final Uri googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );

  if (!await launchUrl(
    googleMapsUrl,
    mode: LaunchMode.externalApplication,
  )) {
    if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Could not open Google Maps'),
  ),
);
  }
}

  void _sortByDistance() {
    if (_userPosition == null) return;
    stations.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        _userPosition!.latitude, _userPosition!.longitude,
        _toDouble(a['lat'], 0), _toDouble(a['lng'], 0),
      );
      final distB = Geolocator.distanceBetween(
        _userPosition!.latitude, _userPosition!.longitude,
        _toDouble(b['lat'], 0), _toDouble(b['lng'], 0),
      );
      return distA.compareTo(distB);
    });
    setState(() {
      _statuses = _generateStatuses(stations.length);
    });
  }

  List<String> _generateStatuses(int count) {
    final list = List<String>.filled(count, 'green');
    if (count > 0) list[0] = 'green';
    if (count > 2) list[2] = 'red';
    if (count > 3) list[3] = 'orange';
    if (count > 4) list[4] = 'orange';
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

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  String _formatDistance(Map<String, dynamic> station) {
    if (_userPosition == null) return '';
    final dist = Geolocator.distanceBetween(
      _userPosition!.latitude, _userPosition!.longitude,
      _toDouble(station['lat'], 0), _toDouble(station['lng'], 0),
    );
    if (dist < 1000) return '${dist.toInt()} m';
    return '${(dist / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color scaffoldBg = Color(0xFFFBFBFB);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4195AF)))
          : stations.isEmpty
              ? Center(child: Text(l10n.noStationsFound))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final bool isFeatured = station['featured'] == true;
                    final Color statusColor = _statusColor(_statuses[index]);
                    final String distance = _formatDistance(station);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _showStationDetails(context, station, l10n),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isFeatured ? const Color(0xFF22C55E).withOpacity(0.4) : Colors.grey.shade200,
                              width: isFeatured ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isFeatured ? const Color(0xFF22C55E).withOpacity(0.08) : Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.location_on_rounded, color: statusColor, size: 24),
                                  ),
                                  if (isFeatured)
                                    Positioned(
                                      top: 0, right: 0,
                                      child: GestureDetector(
                                        onTap: () => _showFeaturedOffers(context, station, l10n),
                                        child: Container(
                                          width: 18, height: 18,
                                          decoration: const BoxDecoration(color: Color(0xFFFACC15), shape: BoxShape.circle),
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
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: primaryNavy),
                                          ),
                                        ),
                                        if (isFeatured)
                                          GestureDetector(
                                            onTap: () => _showFeaturedOffers(context, station, l10n),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFACC15).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: const Color(0xFFFACC15)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFACC15)),
                                                  const SizedBox(width: 3),
                                                  Text(l10n.featured, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(station['location'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        ),
                                        if (distance.isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(Icons.near_me_rounded, size: 12, color: Colors.grey.shade400),
                                              const SizedBox(width: 3),
                                              Text(distance, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                      ],
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

  void _showFeaturedOffers(BuildContext context, Map<String, dynamic> station, AppLocalizations l10n) {
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
                  child: Text(station['title'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.specialOffersAtStation, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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

  void _showStationDetails(BuildContext context, Map<String, dynamic> station, AppLocalizations l10n) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);

    final double lat = _toDouble(station['lat'], 21.5433);
    final double lng = _toDouble(station['lng'], 39.1728);

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
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(lat, lng),
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.petrovision.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 44, height: 44,
                          child: const Icon(Icons.location_on, color: accentBlue, size: 42),
                        ),
                      ],
                    ),
                  ],
                ),
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
                  _infoRow(Icons.access_time_filled_rounded, l10n.workingHours, station['hours'] ?? "24 Hours", accentBlue),
                  const SizedBox(height: 18),
                  _infoRow(Icons.phone_rounded, l10n.contactNumber, station['phone'] ?? "920003467", accentBlue),
                  const SizedBox(height: 30),

Row(
  children: [

    Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
  onPressed: () => _openGoogleMaps(lat, lng),

  icon: const Icon(
    Icons.map_rounded,
    color: Colors.white,
    size: 18,
  ),

  label:  Text(
     l10n.openMaps,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),

  style: ElevatedButton.styleFrom(
    backgroundColor: accentBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 0,
  ),
),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),

          style: ElevatedButton.styleFrom(
            backgroundColor: primaryNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),

          child: Text(
            l10n.close,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),

  ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2E35))),
            ],
          ),
        ),
      ],
    );
  }
}