// ========================================================================================================
// PetroVision Dashboard Widgets
// --------------------------------------------------------------------------------------------------------
// This file defines reusable dashboard widgets
// and visualization components used within the
// PetroVision admin dashboard application.
//
// Features included:
// - Building reusable dashboard cards and layouts
// - Displaying KPI statistics and analytics
// - Displaying member growth visualizations
// - Displaying loyalty-tier distribution charts
// - Displaying station-network maps
// - Displaying AI-generated explanations
// - Displaying station alerts and performance tables
// - Supporting interactive dashboard navigation
// - Providing responsive and animated UI components
//
// It also centralizes reusable dashboard UI
// components, analytics visualizations,
// and operational monitoring widgets
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../screens/alert_detail_screen.dart';
import 'interactive_widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
            color: const Color(0xFF1A2E35).withOpacity(0.06),
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
                  color: item.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E35),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (item.change.trim().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.chipColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.change,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A959E),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MemberGrowthChart extends StatelessWidget {
  final List growthData;
  final int selectedYear;
  final int? selectedMonth;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int?> onMonthChanged;

  const MemberGrowthChart({
    super.key,
    this.growthData = const [],
    required this.selectedYear,
    this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final values = List<double>.generate(12, (index) {
      if (growthData.length > index && growthData[index] is Map) {
        final item = Map<String, dynamic>.from(growthData[index]);
        final value = item['count'];
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString()) ?? 0;
      }
      return 0;
    });

    final maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    Widget dropdownBox({required Widget child}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: DropdownButtonHideUnderline(child: child),
      );
    }

    Widget yearFilter() {
      return dropdownBox(
        child: DropdownButton<int>(
          value: selectedYear,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF4195AF)),
          items: List.generate(5, (i) {
            final year = DateTime.now().year - i;
            return DropdownMenuItem(value: year, child: Text(year.toString()));
          }),
          onChanged: (value) {
            if (value != null) onYearChanged(value);
          },
        ),
      );
    }

    Widget monthFilter() {
      return dropdownBox(
        child: DropdownButton<int?>(
          value: selectedMonth,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF4195AF)),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('All months')),
            ...List.generate(12, (i) {
              return DropdownMenuItem<int?>(value: i + 1, child: Text(labels[i]));
            }),
          ],
          onChanged: onMonthChanged,
        ),
      );
    }

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
                    'Member Activity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2E35)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Transaction activity by selected year and month',
                    style: TextStyle(color: Color(0xFF8A959E), fontSize: 13),
                  ),
                ],
              ),
            ),
            monthFilter(),
            const SizedBox(width: 10),
            yearFilter(),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          height: 320,
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(12, (index) {
                    final normalized = values[index] / safeMax;
                    final barHeight = 20 + (normalized * 210);
                    final isSelected = selectedMonth == index + 1;
                    final isActive = values[index] == safeMax && values[index] > 0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              values[index].toInt().toString(),
                              style: const TextStyle(fontSize: 10, color: Color(0xFF8A959E)),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1A2E35)
                                    : isActive
                                        ? const Color(0xFF1A2E35)
                                        : const Color(0xFF4195AF),
                                borderRadius: BorderRadius.circular(10),
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
                  final selected = selectedMonth == index + 1;
                  return Expanded(
                    child: Center(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: selected ? const Color(0xFF1A2E35) : const Color(0xFF8A959E),
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                        ),
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
  final Map<String, dynamic> tierData;

  const TierDistributionCard({super.key, this.tierData = const {}});

  int _readTier(String key) {
    final value = tierData[key] ?? tierData[key.toLowerCase()] ?? 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final gold = _readTier('Gold');
    final silver = _readTier('Silver');
    final bronze = _readTier('Bronze');
    final total = gold + silver + bronze;

    Widget legend(Color color, String title, int value) {
      final percent = total == 0 ? 0 : ((value / total) * 100).round();
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14))),
            Text('$value  $percent%', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tier Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _TierDonutPainter(gold: gold, silver: silver, bronze: bronze),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                    const SizedBox(height: 4),
                    const Text('Total Members', style: TextStyle(color: Color(0xFF8A959E))),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        legend(const Color(0xFF1A2E35), 'Gold Tier', gold),
        legend(const Color(0xFF4195AF), 'Silver Tier', silver),
        legend(const Color(0xFFB7D5DF), 'Bronze Tier', bronze),
      ],
    );
  }
}

class _TierDonutPainter extends CustomPainter {
  final int gold;
  final int silver;
  final int bronze;

  const _TierDonutPainter({required this.gold, required this.silver, required this.bronze});

  @override
  void paint(Canvas canvas, Size size) {
    final total = gold + silver + bronze;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 14);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = const Color(0xFFE5E7EB);
      canvas.drawArc(rect, -1.5708, 6.28318, false, paint);
      return;
    }

    double start = -1.5708;
    void drawSegment(int value, Color color) {
      if (value <= 0) return;
      final sweep = (value / total) * 6.28318;
      paint.color = color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    drawSegment(gold, const Color(0xFF1A2E35));
    drawSegment(silver, const Color(0xFF4195AF));
    drawSegment(bronze, const Color(0xFFB7D5DF));
  }

  @override
  bool shouldRepaint(covariant _TierDonutPainter oldDelegate) {
    return oldDelegate.gold != gold || oldDelegate.silver != silver || oldDelegate.bronze != bronze;
  }
}

class StationNetworkCard extends StatelessWidget {
  final List mapStations;
  final void Function(Map<String, dynamic> station)? onStationTap;

  const StationNetworkCard({
    super.key,
    required this.mapStations,
    this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Station Network', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
            OutlinedButton.icon(
              onPressed: () => _showFullMap(context),
              style: outlinedDesktopButtonStyle(),
              icon: const Icon(Icons.open_in_full_rounded, size: 18),
              label: const Text('Full Screen', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _MapCanvas(height: 360, mapStations: mapStations, onStationTap: onStationTap),
      ],
    );
  }

  void _showFullMap(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: const Color(0xFFFBFBFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF4195AF).withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2E35).withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.map_rounded, color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Station Network',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A2E35)),
                    ),
                  ),
                  IconButton(
                    hoverColor: const Color(0xFF4195AF).withOpacity(0.08),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF1A2E35)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF4195AF).withOpacity(0.20)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _MapCanvas(height: 610, isExpanded: true, mapStations: mapStations, onStationTap: onStationTap),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  final double height;
  final bool isExpanded;
  final List mapStations;
  final void Function(Map<String, dynamic> station)? onStationTap;

  const _MapCanvas({
    required this.height,
    required this.mapStations,
    this.isExpanded = false,
    this.onStationTap,
  });

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final markers = mapStations.map((item) {
      final s = Map<String, dynamic>.from(item);
      final lat = _toDouble(s['lat'] ?? s['latitude'], 24.7136);
      final lng = _toDouble(s['lng'] ?? s['longitude'], 46.6753);
      final name = s['station_name'] ?? s['name'] ?? s['station_id'] ?? 'Station';

      return Marker(
        point: LatLng(lat, lng),
        width: 44,
        height: 44,
        child: Tooltip(
          message: name.toString(),
          child: GestureDetector(
            onTap: () => onStationTap?.call(s),
            child: const Icon(Icons.location_on_rounded, color: Color(0xFF4195AF), size: 44),
          ),
        ),
      );
    }).toList();

    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(initialCenter: const LatLng(24.7136, 46.6753), initialZoom: isExpanded ? 5.5 : 5),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.petrovision'),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}

class AiExplanationCard extends StatelessWidget {
  final String? explanation;

  const AiExplanationCard({super.key, required this.explanation});

  List<String> _extractLines(String text, String heading) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final start = lines.indexWhere((line) => line.toLowerCase().contains(heading.toLowerCase()));
    if (start == -1) return [];
    final result = <String>[];
    for (var i = start + 1; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      if (lower.contains('summary') || lower.contains('key insights') || lower.contains('management actions') || lower.contains('recommended actions')) {
        break;
      }
      result.add(line.replaceFirst(RegExp(r'^[-•]\s*'), ''));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final text = explanation?.trim() ?? '';
    final summary = _extractLines(text, 'Executive Summary').join(' ');
    final insights = _extractLines(text, 'Key Insights');
    final actions = _extractLines(text, 'Management Actions').isNotEmpty
        ? _extractLines(text, 'Management Actions')
        : _extractLines(text, 'Recommended Actions');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Explanation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 16),
        if (text.isEmpty)
          const Text('No explanation available yet. Run analysis first, then refresh the dashboard.', style: TextStyle(color: Color(0xFF8A959E)))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 800;
              final cards = [
                _ExplanationBox(icon: Icons.description_outlined, title: 'Summary', items: [summary.isEmpty ? text : summary]),
                _ExplanationBox(icon: Icons.lightbulb_outline, title: 'Key Insights', items: insights.isEmpty ? ['No key insights available.'] : insights),
                _ExplanationBox(icon: Icons.task_alt_rounded, title: 'Management Actions', items: actions.isEmpty ? ['No management actions available.'] : actions),
              ];

              if (narrow) {
                return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 14),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 14),
                    Expanded(child: cards[2]),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ExplanationBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ExplanationBox({required this.icon, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4195AF), size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(item, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.45)),
              )),
        ],
      ),
    );
  }
}

class StationAlertsCard extends StatelessWidget {
  final List<AlertItem> alerts;

  const StationAlertsCard({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Station Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          SizedBox(height: 18),
          Text('No repeated station alerts available.', style: TextStyle(color: Color(0xFF8A959E))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Station Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 18),
        ...alerts.map((alert) => _AlertTile(alert: alert)),
      ],
    );
  }
}

class TopStationsCard extends StatelessWidget {
  final List<StationItem> stations;

  const TopStationsCard({super.key, required this.stations});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return const Color(0xFF22C55E);
      case 'fair':
        return const Color(0xFFF59E0B);
      case 'poor':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF4195AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Performing Stations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          SizedBox(height: 18),
          Text('No station analysis available yet.', style: TextStyle(color: Color(0xFF8A959E))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Performing Stations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 18),
        const Row(children: [
          Expanded(child: _TableHeader(title: 'Station')),
          Expanded(child: _TableHeader(title: 'City')),
          Expanded(child: _TableHeader(title: 'Status')),
          Expanded(child: _TableHeader(title: 'Performance Score')),
        ]),
        const Divider(height: 24, color: Color(0xFFE5E7EB)),
        ...stations.map((station) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(child: Text(station.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827)))),
                  Expanded(child: Text(station.city, style: const TextStyle(fontSize: 14, color: Color(0xFF111827)))),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: _statusColor(station.status), borderRadius: BorderRadius.circular(999)),
                        child: Text(station.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                  ),
                  Expanded(child: Text(station.score.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A2E35)))),
                ],
              ),
            )),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String title;
  const _TableHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Color(0xFF8A959E), fontWeight: FontWeight.w600, fontSize: 13));
  }
}

class _AlertTile extends StatefulWidget {
  final AlertItem alert;
  const _AlertTile({required this.alert});

  @override
  State<_AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<_AlertTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertDetailScreen(alert: widget.alert))),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFFFBFBFB) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _hovered ? widget.alert.chipColor.withOpacity(0.3) : const Color(0xFFE5E7EB)),
              boxShadow: [BoxShadow(color: const Color(0xFF1A2E35).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.alert.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111827))),
                      const SizedBox(height: 6),
                      Text(widget.alert.station, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: widget.alert.chipColor, borderRadius: BorderRadius.circular(999)),
                        child: Text(widget.alert.severity, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _hovered ? widget.alert.chipColor : const Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
