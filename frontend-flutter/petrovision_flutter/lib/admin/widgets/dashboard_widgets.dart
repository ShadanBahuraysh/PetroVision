import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import 'interactive_widgets.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132935).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class KpiCard extends StatelessWidget {
  final KpiItem item;
  final String selectedFilter;
  final ValueChanged<String?> onChanged;

  const KpiCard({
    super.key,
    required this.item,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A959E),
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            item.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF132935),
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: item.chipColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.change,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8A959E),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Align(
            alignment: Alignment.centerRight,
            child: HoverSurface(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  dropdownColor: const Color(0xFFEAF3F7),
                  style: const TextStyle(
                    color: Color(0xFF132935),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Day', child: Text('Day')),
                    DropdownMenuItem(value: 'Month', child: Text('Month')),
                    DropdownMenuItem(value: 'Quarter', child: Text('Quarter')),
                    DropdownMenuItem(value: 'Year', child: Text('Year')),
                  ],
                  onChanged: onChanged,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MemberGrowthChart extends StatelessWidget {
  const MemberGrowthChart({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [42.0, 55.0, 68.0, 63.0, 78.0, 88.0, 96.0];
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member Growth',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Yearly member acquisition trend',
                    style: TextStyle(color: Color(0xFF8A959E), fontSize: 13),
                  ),
                ],
              ),
            ),
            HoverSurface(
              child: PopupMenuButton<String>(
                tooltip: 'Choose year',
                initialValue: '2025',
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: '2024', child: Text('2024')),
                  PopupMenuItem(value: '2025', child: Text('2025')),
                  PopupMenuItem(value: '2026', child: Text('2026')),
                ],
                child: const Row(
                  children: [
                    Text(
                      '2025',
                      style: TextStyle(color: Color(0xFF132935)),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF132935)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          height: 320,
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(values.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: values[index] * 1.5,
                              decoration: BoxDecoration(
                                color: index == values.length - 1
                                    ? const Color(0xFF132935)
                                    : const Color(0xFF7FB3C8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(labels.length, (index) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        labels[index],
                        style: const TextStyle(color: Color(0xFF8A959E)),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TierDistributionCard extends StatelessWidget {
  const TierDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget legend(Color color, String title, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tier Distribution',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 26,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFD1D5DB)),
                  ),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 0.45,
                    strokeWidth: 26,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF132935)),
                  ),
                ),
                SizedBox.expand(
                  child: Transform.rotate(
                    angle: 2.5,
                    child: CircularProgressIndicator(
                      value: 0.30,
                      strokeWidth: 26,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4195AF)),
                    ),
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '24.5K',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Total', style: TextStyle(color: Color(0xFF8A959E))),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        legend(const Color(0xFF132935), 'Gold Tier', '45%'),
        legend(const Color(0xFF6B7280), 'Silver Tier', '30%'),
        legend(const Color(0xFFD1D5DB), 'Bronze Tier', '25%'),
      ],
    );
  }
}

class StationNetworkCard extends StatelessWidget {
  const StationNetworkCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Station Network',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showFullMap(context),
              style: outlinedDesktopButtonStyle(),
              icon: const Icon(Icons.open_in_full_rounded, size: 18),
              label: const Text('Full Screen', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _MapCanvas(height: 360),
      ],
    );
  }

  void _showFullMap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Station Network',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      hoverColor: const Color(0xFFF3F4F6),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _MapCanvas(height: 560, isExpanded: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapCanvas extends StatefulWidget {
  final double height;
  final bool isExpanded;

  const _MapCanvas({required this.height, this.isExpanded = false});

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  final String _viewId = 'admin-map-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _registerMap();
  }

  void _registerMap() {
    const apiKey = 'AIzaSyDjdMGkREctRQN52HyAOaC6PS04H-j47Vs';
    final mapHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>body,html,#map{margin:0;padding:0;width:100%;height:100%;}</style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          async function initMap() {
            const res = await fetch('http://localhost:8000/stations');
            const stations = await res.json();

            var map = new google.maps.Map(document.getElementById('map'), {
              center: {lat: 24.7136, lng: 46.6753},
              zoom: 5,
              mapTypeControl: false,
              streetViewControl: false,
            });

            stations.forEach(function(station) {
              var marker = new google.maps.Marker({
                position: {lat: station.lat, lng: station.lng},
                map: map,
                title: station.name,
                icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
              });
              var info = new google.maps.InfoWindow({
                content: '<b>' + station.name + '</b><br>' + station.address
              });
              marker.addListener('click', function() {
                info.open(map, marker);
              });
            });
          }
        </script>
        <script src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap" async defer></script>
      </body>
      </html>
    ''';

    final blob = html.Blob([mapHtml], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: HtmlElementView(viewType: _viewId),
      ),
    );
  }
}

class StationAlertsCard extends StatelessWidget {
  final List<AlertItem> alerts;

  const StationAlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Station Alerts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 18),
        ...alerts.map(
          (alert) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF132935).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.station,
                  style: const TextStyle(color: Color(0xFF8A959E), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: alert.chipColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    alert.severity,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TopStationsCard extends StatelessWidget {
  final List<StationItem> stations;

  const TopStationsCard({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performing Stations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 18),
        Row(
          children: const [
            Expanded(child: _TableHeader(title: 'Station')),
            Expanded(child: _TableHeader(title: 'City')),
            Expanded(child: _TableHeader(title: 'Status')),
            Expanded(child: _TableHeader(title: 'Performance Score')),
          ],
        ),
        const Divider(height: 24, color: Color(0xFFE5E7EB)),
        ...stations.map(
          (station) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    station.city,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: station.status == 'Operational'
                            ? const Color(0xFF4195AF)   // blue
    : const Color(0xFF7FB3C8),  // light blue
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        station.status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    station.score.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF132935),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String title;

  const _TableHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF8A959E),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}