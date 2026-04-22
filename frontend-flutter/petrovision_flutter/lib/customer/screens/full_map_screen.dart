import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';

class FullMapScreen extends StatefulWidget {
  final bool isPreview; // ← أضف هذا
  const FullMapScreen({super.key, this.isPreview = false});
  
  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  bool _isLoading = true;
  int _stationCount = 0;
  List _stations = [];

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final Uri url = Uri.parse('http://localhost:8000/stations');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _stations = data;
          _stationCount = data.length;
          _isLoading = false;
        });
        _initMap();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('خطأ: $e');
    }
  }

  void _initMap() {
    final markersJson = json.encode(_stations);
    final mapHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body, html, #map { margin: 0; padding: 0; width: 100%; height: 100%; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          function initMap() {
            var map = new google.maps.Map(document.getElementById('map'), {
              center: { lat: 24.7136, lng: 46.6753 },
              zoom: 6
            });
            var stations = $markersJson;
            stations.forEach(function(station) {
              var marker = new google.maps.Marker({
                position: { lat: station.lat, lng: station.lng },
                map: map,
                title: station.name,
                icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
              });
              var infoWindow = new google.maps.InfoWindow({
                content: '<b>' + station.name + '</b><br>' + station.address
              });
              marker.addListener('click', function() {
                infoWindow.open(map, marker);
              });
            });
          }
        </script>
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDjdMGkREctRQN52HyAOaC6PS04H-j47Vs&callback=initMap" async defer></script>      </body>
      </html>
    ''';

    final blob = html.Blob([mapHtml], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    ui.platformViewRegistry.registerViewFactory(
      'google-maps-view',
      (int viewId) => html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );

    setState(() {});
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        if (!_isLoading && _stations.isNotEmpty)
          const HtmlElementView(viewType: 'google-maps-view'),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF4195AF)),
          ),

        // زر الرجوع — يظهر فقط في الشاشة الكاملة
        if (!widget.isPreview)
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
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
                ),
              ),
            ),
          ),

        // شريط المعلومات — يظهر فقط في الشاشة الكاملة
        if (!widget.isPreview)
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_gas_station_rounded, color: Color(0xFF4195AF)),
                  const SizedBox(width: 10),
                  Text(
                    _isLoading
                        ? "جاري تحميل المحطات..."
                        : "$_stationCount Petromin stations found",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}}