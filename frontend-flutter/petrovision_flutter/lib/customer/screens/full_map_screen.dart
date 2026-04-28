import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  bool _isLoading = true;
  int _stationCount = 0;
  List _stations = [];
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
final response = await http.get(Uri.parse('http://localhost:8000/stations-db'));
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
    }
  }

  void _initMap() {
    const apiKey = 'AIzaSyDjdMGkREctRQN52HyAOaC6PS04H-j47Vs';
    final markersJson = json.encode(_stations);

    final mapHtml = '''
      <!DOCTYPE html><html>
      <head><style>body,html,#map{margin:0;padding:0;width:100%;height:100%;}</style></head>
      <body>
        <div id="map"></div>
        <script>
          function initMap() {
            var map = new google.maps.Map(document.getElementById('map'), {
              center: {lat: 24.7136, lng: 46.6753}, zoom: 6
            });
            var stations = $markersJson;
            stations.forEach(function(s) {
              var marker = new google.maps.Marker({
                position: {lat: s.lat, lng: s.lng}, map: map, title: s.name,
                icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
              });
              var info = new google.maps.InfoWindow({content: '<b>'+s.name+'</b><br>'+s.address});
              marker.addListener('click', function() { info.open(map, marker); });
            });
          }
        </script>
        <script src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap" async defer></script>
      </body></html>
    ''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(mapHtml);

    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF4195AF))),

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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
                ),
              ),
            ),
          ),

          
        ],
      ),
    );
  }
}