// ========================================================================================================
// PetroVision Full Map Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the FullMapScreen used for
// displaying all PetroVision fuel stations
// on an interactive full-screen map interface.
//
// Features included:
// - Loading station data from backend APIs
// - Displaying fuel stations on an interactive map
// - Displaying station markers and location details
// - Handling station coordinate conversion and validation
// - Displaying station information dialogs
// - Managing loading and API request states
// - Supporting interactive map navigation
// - Providing responsive map UI components
//
// It also integrates station-location APIs,
// interactive map visualization,
// and station-information workflows
// within the PetroVision platform.
// ========================================================================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _stations = [];

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8000/stations-db'),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      List data = [];

      try {
        data = json.decode(response.body);
      } catch (_) {
        data = [];
      }

      setState(() {
        _stations = data.map((item) => Map<String, dynamic>.from(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  List<Marker> _buildMarkers(BuildContext context) {
    return _stations.map((station) {
      final lat = _toDouble(station['lat'], 24.7136);
      final lng = _toDouble(station['lng'], 46.6753);
      final name = station['name']?.toString() ?? 'Station';
      final address = station['address']?.toString() ?? '';

      return Marker(
        point: LatLng(lat, lng),
        width: 46,
        height: 46,
        child: GestureDetector(
          onTap: () => _showStationInfo(context, name, address),
          child: const Icon(
            Icons.location_on,
            color: Color(0xFF4195AF),
            size: 42,
          ),
        ),
      );
    }).toList();
  }

  void _showStationInfo(BuildContext context, String name, String address) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4195AF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_gas_station_rounded,
                    color: Color(0xFF4195AF), size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A2E35),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address.isEmpty ? 'No address available' : address,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2E35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Close",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(24.7136, 46.6753),
              initialZoom: 5.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.petrovision.app',
              ),
              MarkerLayer(markers: _buildMarkers(context)),
            ],
          ),

          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4195AF)),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                '${_stations.length} Stations',
                style: const TextStyle(
                  color: Color(0xFF1A2E35),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}