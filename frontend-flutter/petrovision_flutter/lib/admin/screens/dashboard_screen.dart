// ========================================================================================================
// PetroVision Dashboard Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the DashboardScreen and related
// dashboard operations used within the PetroVision
// admin dashboard application.
//
// Features included:
// - Loading dashboard analytics data
// - Running AI analysis manually
// - Displaying KPI statistics and station performance
// - Displaying loyalty-program analytics
// - Displaying station alerts and recommendations
// - Displaying AI-generated explanations
// - Comparing station performance results
// - Displaying station analysis details
// - Exporting and downloading analysis reports
// - Saving reports to the database
// - Handling dashboard loading and error states
//
// It also integrates backend analytics APIs,
// AI explanation services, loyalty analytics,
// and interactive dashboard visualizations
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../utils/download_helper.dart';

import '../models/dashboard_models.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String baseUrl = 'http://localhost:8000';

  static const Color navy = Color(0xFF1A2E35);
  static const Color accent = Color(0xFF4195AF);
  static const Color offWhite = Color(0xFFFBFBFB);
  static const Color softGrey = Color(0xFF8A959E);

  Map<String, dynamic>? overview;
  List<StationItem> stations = [];
  List<AlertItem> alerts = [];
  List mapStations = [];
  String? overviewExplanation;

  List growthData = [];
  Map<String, dynamic> tierData = {};
  int totalCustomers = 0;
  int selectedYear = DateTime.now().year;
  int? selectedMonth;

  bool isLoading = true;
  bool isRunningAnalysis = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _prepareDashboard() async {
    await _loadDashboardData();

    final bool hasAnalysisCache =
        overview != null &&
        overview?['cached'] != false &&
        (overview?['total_stations'] ?? 0) > 0;

    if (!hasAnalysisCache) {
      await _runInitialAnalysisInBackground();
    }
  }

  Future<void> _runInitialAnalysisInBackground() async {
    if (isRunningAnalysis) return;

    setState(() {
      isRunningAnalysis = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analysis/run-all?force=false'),
      );

      if (response.statusCode == 200) {
        await _loadDashboardData();
      }
    } catch (e) {
      errorMessage = 'Initial analysis failed to run';
    }

    if (!mounted) return;

    setState(() {
      isRunningAnalysis = false;
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.wait([
        _fetchOverview(),
        _fetchTopStations(),
        _fetchStationsMap(),
        _fetchLoyaltySummary(),
      ]);

      final bool hasAnalysisCache =
          overview != null &&
          overview?['cached'] != false &&
          (overview?['total_stations'] ?? 0) > 0;

      if (hasAnalysisCache) {
        await _fetchOverviewExplanation();
      } else {
        overviewExplanation = null;
      }
    } catch (e) {
      errorMessage = 'Failed to load dashboard data';
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _runAnalysisManually() async {
    setState(() {
      isRunningAnalysis = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analysis/run-all?force=true'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'running') {
          errorMessage = 'Analysis is already running';
        } else {
          await _loadDashboardData();
        }
      } else {
        errorMessage = 'Analysis failed to run';
      }
    } catch (e) {
      errorMessage = 'Analysis failed to run';
    }

    if (!mounted) return;
    setState(() => isRunningAnalysis = false);
  }

  Future<void> _fetchOverview() async {
    final response = await http.get(Uri.parse('$baseUrl/analysis/overview'));

    if (response.statusCode == 200) {
      overview = jsonDecode(response.body);
      alerts = _buildAlertsFromOverview(overview);
    }
  }

  Future<void> _fetchTopStations() async {
    final response = await http.get(Uri.parse('$baseUrl/analysis/top-bottom'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List topList = [];

      if (data is Map && data['top_10'] is List) {
        topList = List.from(data['top_10']).reversed.toList();
      } else if (data is Map && data['top'] is List) {
        topList = data['top'];
      } else if (data is List) {
        topList = data;
      }

      stations = topList.take(5).map((item) {
        final s = Map<String, dynamic>.from(item);

        return StationItem(
          name: _readString(s, [
            'station_name',
            'name',
            'station_id',
          ], 'Station'),
          city: _readString(s, ['city'], 'Saudi Arabia'),
          status: _readString(s, ['performance_status', 'status'], 'Good'),
          score: _readDouble(s, [
            'final_station_score',
            'score',
            'average_performance_score',
            'predicted_mean',
          ], 0),
        );
      }).toList();
    }
  }

  Future<void> _fetchStationsMap() async {
    final response = await http.get(Uri.parse('$baseUrl/stations-db'));

    if (response.statusCode == 200) {
      mapStations = jsonDecode(response.body);
    }
  }

  Future<void> _fetchOverviewExplanation() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analysis/explain/overview'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      overviewExplanation = data['explanation']?.toString();
    }
  }

  Future<void> _fetchLoyaltySummary() async {
    final monthQuery = selectedMonth == null ? '' : '&month=$selectedMonth';
    final res = await http.get(
      Uri.parse('$baseUrl/loyalty/admin-summary?year=$selectedYear$monthQuery'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      growthData = data['member_growth'] ?? [];
      tierData = Map<String, dynamic>.from(data['tier_distribution'] ?? {});
      totalCustomers = data['total_customers'] ?? 0;
    }
  }

  Future<void> _changeLoyaltyYear(int year) async {
    setState(() {
      selectedYear = year;
      isLoading = true;
    });

    await _fetchLoyaltySummary();

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _changeLoyaltyMonth(int? month) async {
    setState(() {
      selectedMonth = month;
      isLoading = true;
    });

    await _fetchLoyaltySummary();

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _showStationDetails(Map<String, dynamic> station) async {
    final stationId = _readString(station, ['station_id', 'id'], '');
    if (stationId.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: accent)),
    );

    Map<String, dynamic>? analysis;
    String? explanation;

    try {
      final analysisRes = await http.get(
        Uri.parse('$baseUrl/analysis/station/$stationId'),
      );
      final explainRes = await http.get(
        Uri.parse('$baseUrl/analysis/explain/station/$stationId'),
      );

      if (analysisRes.statusCode == 200) {
        analysis = jsonDecode(analysisRes.body);
      }

      if (explainRes.statusCode == 200) {
        final data = jsonDecode(explainRes.body);
        explanation = data['explanation']?.toString();
      }
    } catch (_) {}

    if (!mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) {
        final issues = analysis?['main_issues'] as List? ?? [];
        final actions = analysis?['recommended_actions'] as List? ?? [];

        return Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: offWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 820,
            constraints: const BoxConstraints(maxHeight: 860),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: offWhite,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: navy.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_gas_station_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Station $stationId Analysis',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: navy,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: navy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _metricCard(
                        'Score',
                        '${analysis?['final_station_score'] ?? '-'}',
                        Icons.speed_rounded,
                      ),
                      const SizedBox(width: 12),
                      _metricCard(
                        'Status',
                        '${analysis?['performance_status'] ?? analysis?['priority'] ?? '-'}',
                        Icons.analytics_rounded,
                      ),
                      const SizedBox(width: 12),
                      _metricCard(
                        'Best Time',
                        '${analysis?['best_time']?['time_slot'] ?? '-'}',
                        Icons.wb_sunny_rounded,
                      ),
                      const SizedBox(width: 12),
                      _metricCard(
                        'Worst Time',
                        '${analysis?['worst_time']?['time_slot'] ?? '-'}',
                        Icons.nightlight_round,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _sectionTitle('Main Issues', Icons.warning_amber_rounded),
                  const SizedBox(height: 12),
                  if (issues.isEmpty)
                    _emptyBox('No major issues found.')
                  else
                    ...issues.map((item) {
                      final i = Map<String, dynamic>.from(item);
                      return _infoCard(
                        title: i['issue']?.toString() ?? '-',
                        subtitle: i['explanation']?.toString(),
                        icon: Icons.error_outline_rounded,
                        color: const Color(0xFFEF4444),
                      );
                    }),
                  const SizedBox(height: 22),
                  _sectionTitle('Recommended Actions', Icons.task_alt_rounded),
                  const SizedBox(height: 12),
                  if (actions.isEmpty)
                    _emptyBox('No actions available.')
                  else
                    ...actions.map((item) {
                      final a = Map<String, dynamic>.from(item);
                      return _infoCard(
                        title:
                            a['action']?.toString() ??
                            a['issue']?.toString() ??
                            '-',
                        subtitle: null,
                        icon: Icons.check_circle_outline_rounded,
                        color: accent,
                      );
                    }),
                  const SizedBox(height: 22),
                  _sectionTitle('AI Explanation', Icons.auto_awesome_rounded),
                  const SizedBox(height: 12),
                  _aiBox(
                    explanation ??
                        analysis?['summary']?.toString() ??
                        'No explanation available.',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCompareDialog() async {
    String? stationA;
    String? stationB;
    String? resultText;
    String? validationMessage;
    bool loading = false;

    final stationIds =
        mapStations
            .map(
              (item) => _readString(Map<String, dynamic>.from(item), [
                'station_id',
                'id',
              ], ''),
            )
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> runCompare() async {
              if (stationA == null || stationB == null) {
                setDialogState(() {
                  validationMessage =
                      'Please select Station A and Station B before comparing.';
                  resultText = null;
                });
                return;
              }

              if (stationA == stationB) {
                setDialogState(() {
                  validationMessage = 'Please select two different stations.';
                  resultText = null;
                });
                return;
              }

              setDialogState(() {
                loading = true;
                validationMessage = null;
                resultText = null;
              });

              try {
                final res = await http.get(
                  Uri.parse('$baseUrl/analysis/compare/$stationA/$stationB'),
                );

                if (res.statusCode == 200) {
                  final data = jsonDecode(res.body);
                  resultText =
                      data['explanation']?.toString() ??
                      'No comparison explanation available.';
                } else {
                  validationMessage = 'Comparison failed. Please try again.';
                }
              } catch (_) {
                validationMessage =
                    'Comparison failed. Please check the backend connection.';
              }

              setDialogState(() => loading = false);
            }

            return Dialog(
              backgroundColor: offWhite,
              insetPadding: const EdgeInsets.all(32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                width: 760,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: offWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: accent.withOpacity(0.22)),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.compare_arrows_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Compare Stations',
                              style: TextStyle(
                                color: navy,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: navy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _stationDropdown(
                              'Station A',
                              stationA,
                              stationIds,
                              (v) => setDialogState(() => stationA = v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _stationDropdown(
                              'Station B',
                              stationB,
                              stationIds,
                              (v) => setDialogState(() => stationB = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: loading ? null : runCompare,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: loading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.compare_arrows_rounded),
                        label: Text(
                          loading ? 'Comparing...' : 'Compare',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (validationMessage != null) ...[
                        const SizedBox(height: 20),
                        _compareMessageBox(validationMessage!),
                      ],
                      if (resultText != null) ...[
                        const SizedBox(height: 20),
                        _compareResultCards(resultText!),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _compareMessageBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compareResultCards(String text) {
    final cleaned = text.trim();

    final summary = _extractCompareSection(
      cleaned,
      'Comparison Summary:',
      'Key Differences:',
    );
    final differences = _extractCompareSection(
      cleaned,
      'Key Differences:',
      'Action Plan for Weaker Station:',
    );
    final actions = _extractCompareSection(
      cleaned,
      'Action Plan for Weaker Station:',
      null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _compareSectionCard(
          title: 'Comparison Summary',
          icon: Icons.summarize_rounded,
          text: summary.isEmpty ? cleaned : summary,
        ),
        if (differences.isNotEmpty)
          _compareSectionCard(
            title: 'Key Differences',
            icon: Icons.rule_rounded,
            text: differences,
          ),
        if (actions.isNotEmpty)
          _compareSectionCard(
            title: 'Action Plan for Weaker Station',
            icon: Icons.task_alt_rounded,
            text: actions,
          ),
      ],
    );
  }

  String _extractCompareSection(String text, String start, String? end) {
    final startIndex = text.indexOf(start);
    if (startIndex == -1) return '';

    final contentStart = startIndex + start.length;
    final endIndex = end == null ? -1 : text.indexOf(end, contentStart);
    final raw = endIndex == -1
        ? text.substring(contentStart)
        : text.substring(contentStart, endIndex);

    return raw.replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• ').trim();
  }

  Widget _compareSectionCard({
    required String title,
    required IconData icon,
    required String text,
  }) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...lines.map((line) {
            final isBullet = line.startsWith('•') || line.startsWith('-');
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBullet) ...[
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7, right: 8),
                      decoration: const BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line.replaceFirst(RegExp(r'^[•-]\s*'), ''),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        line,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.45,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _stationDropdown(
    String label,
    String? value,
    List<String> stationIds,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
      items: stationIds
          .map((id) => DropdownMenuItem(value: id, child: Text(id)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          height: 1.55,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  List<AlertItem> _buildAlertsFromOverview(Map<String, dynamic>? data) {
    final issues = data?['most_common_issues'];

    if (issues is List && issues.isNotEmpty) {
      return issues.take(3).map((item) {
        final issue = Map<String, dynamic>.from(item);
        final issueName = issue['issue']?.toString() ?? 'Performance issue';
        final explanation =
            issue['explanation']?.toString() ??
            'This issue was detected from station performance patterns.';
        final count = int.tryParse(issue['count']?.toString() ?? '0') ?? 0;
        final severity = count > 20
            ? 'High'
            : count > 10
            ? 'Medium'
            : 'Low';
        final color = severity == 'High'
            ? const Color(0xFFEF4444)
            : severity == 'Medium'
            ? const Color(0xFFF59E0B)
            : accent;

        return AlertItem(
          title: issueName,
          station: 'Across $count stations',
          severity: severity,
          chipColor: color,
          recommendations: [
            AlertRecommendation(
              title: 'Review $issueName',
              description: explanation,
              estimatedTime: '1–2 hours',
            ),
          ],
          actionSteps: [
            'Review affected stations in the ranking table',
            'Check operational data related to $issueName',
            'Assign the issue to the responsible team',
            'Monitor improvement after action is completed',
          ],
        );
      }).toList();
    }

    return const [];
  }

  String _overviewValue(List<String> keys, String fallback) {
    final data = overview;
    if (data == null) return fallback;

    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        if (value is num) return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
        return value.toString();
      }
    }

    return fallback;
  }

  String _readString(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty)
        return value.toString();
    }
    return fallback;
  }

  double _readDouble(
    Map<String, dynamic> data,
    List<String> keys,
    double fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toDouble();
      if (value != null) {
        final parsed = double.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  List<KpiItem> get kpis {
    return [
      KpiItem(
        title: 'Total Stations',
        value: _overviewValue(['total_stations'], '0'),
        change: 'Live',
        subtitle: 'latest analysis',
        icon: Icons.local_gas_station_outlined,
        color: accent,
        chipColor: accent,
        isPositive: true,
      ),
      KpiItem(
        title: 'Low Performance',
        value: _overviewValue(['low_performance_count'], '0'),
        change: 'Alert',
        subtitle: 'needs attention',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFEF4444),
        chipColor: const Color(0xFFEF4444),
        isPositive: false,
      ),
      KpiItem(
        title: 'Avg Score',
        value: _overviewValue(['overall_average_score'], '0'),
        change: 'Score',
        subtitle: 'network performance',
        icon: Icons.trending_up_rounded,
        color: accent,
        chipColor: accent,
        isPositive: true,
      ),
      KpiItem(
        title: 'High Performance',
        value: _overviewValue(['high_performance_count'], '0'),
        change: 'Strong',
        subtitle: 'strong stations',
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFF22C55E),
        chipColor: const Color(0xFF22C55E),
        isPositive: true,
      ),
    ];
  }

  Future<void> _exportAnalysisReport() async {
    debugPrint("EXPORT CLICKED");
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/analysis/export?save_to_db=false'),
      );

      if (res.statusCode != 200) {
        final message = _extractErrorMessage(res.body);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final decoded = jsonDecode(res.body);
      final rows = decoded is List ? decoded : decoded['rows'] ?? [];

      if (rows is! List || rows.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No report data available to export.')),
        );
        return;
      }

      await _showExportReportDialog(rows.cast<dynamic>());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {}
    return 'Request failed. Please check the backend and try again.';
  }

  Future<void> _downloadReportFile(String selectedFormat) async {
    final fileType = selectedFormat == 'Excel' ? 'excel' : 'csv';

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/analysis/export/download?file_type=$fileType'),
      );

      if (res.statusCode != 200) {
        throw Exception(_extractErrorMessage(res.body));
      }

      final extension = fileType == 'excel' ? 'xlsx' : 'csv';
      final fileName =
          'petrovision_analysis_report_${DateTime.now().millisecondsSinceEpoch}.$extension';

      await saveFileToDevice(res.bodyBytes, fileName);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Report downloaded: $fileName')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  Future<void> _saveReportToDatabase() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/analysis/export/save'));

      if (res.statusCode != 200) {
        throw Exception(_extractErrorMessage(res.body));
      }

      final decoded = jsonDecode(res.body);
      final rowsCount = decoded is Map
          ? decoded['rows_count']?.toString()
          : null;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            rowsCount == null
                ? 'Report saved to database successfully.'
                : 'Report saved to database successfully ($rowsCount rows).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _showExportReportDialog(List<dynamic> rows) async {
    String selectedFormat = 'CSV';
    bool saving = false;
    bool downloading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> downloadReport() async {
              setDialogState(() => downloading = true);
              await _downloadReportFile(selectedFormat);
              if (context.mounted) {
                setDialogState(() => downloading = false);
              }
            }

            Future<void> saveReport() async {
              setDialogState(() => saving = true);
              await _saveReportToDatabase();
              if (context.mounted) {
                setDialogState(() => saving = false);
              }
            }

            return Dialog(
              backgroundColor: offWhite,
              insetPadding: const EdgeInsets.all(28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              child: Container(
                width: 920,
                constraints: const BoxConstraints(maxHeight: 780),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: offWhite,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: accent.withOpacity(0.22)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: navy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Export Analysis Report',
                            style: TextStyle(
                              color: navy,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: navy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _exportChoice(
                          label: 'CSV',
                          selected: selectedFormat == 'CSV',
                          onTap: () =>
                              setDialogState(() => selectedFormat = 'CSV'),
                        ),
                        const SizedBox(width: 12),
                        _exportChoice(
                          label: 'Excel',
                          selected: selectedFormat == 'Excel',
                          onTap: () =>
                              setDialogState(() => selectedFormat = 'Excel'),
                        ),
                        const Spacer(),
                        Text(
                          '${rows.length} rows ready',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(child: _reportPreviewTable(rows)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: downloading ? null : downloadReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: downloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            downloading
                                ? 'Downloading...'
                                : 'Download $selectedFormat',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: saving ? null : saveReport,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: navy,
                            side: const BorderSide(color: navy),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_alt_rounded, size: 18),
                          label: Text(
                            saving ? 'Saving...' : 'Save Report',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Download does not save to database.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _exportChoice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accent : softGrey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? accent : navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportPreviewTable(List<dynamic> rows) {
    final previewRows = rows
        .take(8)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            color: navy,
            fontWeight: FontWeight.w900,
          ),
          dataTextStyle: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          columns: const [
            DataColumn(label: Text('Station')),
            DataColumn(label: Text('Score')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Top Issue')),
            DataColumn(label: Text('Recommendation')),
          ],
          rows: previewRows.map((row) {
            return DataRow(
              cells: [
                DataCell(Text('${row['station_id'] ?? '-'}')),
                DataCell(Text('${row['score'] ?? '-'}')),
                DataCell(Text('${row['status'] ?? '-'}')),
                DataCell(Text('${row['priority'] ?? '-'}')),
                DataCell(Text('${row['top_issue'] ?? '-'}')),
                DataCell(
                  SizedBox(
                    width: 260,
                    child: Text(
                      '${row['recommendation'] ?? '-'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<String> get _reportHeaders => const [
    'station_id',
    'score',
    'status',
    'priority',
    'top_issue',
    'recommendation',
    'generated_at',
  ];

  String _buildCsvReport(List<dynamic> rows) {
    final buffer = StringBuffer()..writeln(_reportHeaders.join(','));

    for (final row in rows) {
      final map = Map<String, dynamic>.from(row);
      buffer.writeln(_reportHeaders.map((key) => _csvCell(map[key])).join(','));
    }

    return buffer.toString();
  }

  String _buildExcelCompatibleReport(List<dynamic> rows) {
    final buffer = StringBuffer()..writeln(_reportHeaders.join('\t'));

    for (final row in rows) {
      final map = Map<String, dynamic>.from(row);
      buffer.writeln(
        _reportHeaders.map((key) => _excelCell(map[key])).join('\t'),
      );
    }

    return buffer.toString();
  }

  String _csvCell(dynamic value) {
    final text = (value ?? '').toString().replaceAll('"', '""');
    return '"$text"';
  }

  String _excelCell(dynamic value) {
    return (value ?? '').toString().replaceAll('\n', ' ').replaceAll('\t', ' ');
  }

  Widget _totalCustomersCard() {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_outline, color: accent),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Customers',
                style: TextStyle(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCustomers registered customers',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const Spacer(),
          Text(
            totalCustomers.toString(),
            style: const TextStyle(
              color: navy,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 0,
      onExport: _exportAnalysisReport,
      title: 'Dashboard Overview',
      subtitle:
          'Welcome back! Here\'s what\'s happening across PetroVision today.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLoading)
                const Expanded(
                  child: LinearProgressIndicator(color: accent, minHeight: 4),
                )
              else
                const Spacer(),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showCompareDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent.withOpacity(0.12),
                  foregroundColor: accent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: accent),
                  ),
                ),
                icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                label: const Text(
                  'Compare Stations',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: isRunningAnalysis ? null : _runAnalysisManually,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isRunningAnalysis
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(
                  isRunningAnalysis ? 'Running...' : 'Run Analysis',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.25),
                ),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  children: [
                    Row(
                      children: List.generate(
                        2,
                        (i) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 0 ? 16 : 0),
                            child: KpiCard(
                              item: kpis[i],
                              selectedFilter: '',
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(2, (i) {
                        final idx = i + 2;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 0 ? 16 : 0),
                            child: KpiCard(
                              item: kpis[idx],
                              selectedFilter: '',
                              onChanged: (_) {},
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }
              return Row(
                children: List.generate(
                  kpis.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == kpis.length - 1 ? 0 : 16,
                      ),
                      child: KpiCard(
                        item: kpis[index],
                        selectedFilter: '',
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  children: [
                    SectionCard(
                      child: MemberGrowthChart(
                        growthData: growthData,
                        selectedYear: selectedYear,
                        selectedMonth: selectedMonth,
                        onYearChanged: _changeLoyaltyYear,
                        onMonthChanged: _changeLoyaltyMonth,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      child: TierDistributionCard(tierData: tierData),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SectionCard(
                      child: MemberGrowthChart(
                        growthData: growthData,
                        selectedYear: selectedYear,
                        selectedMonth: selectedMonth,
                        onYearChanged: _changeLoyaltyYear,
                        onMonthChanged: _changeLoyaltyMonth,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),
                  Expanded(
                    child: SectionCard(
                      child: TierDistributionCard(tierData: tierData),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  children: [
                    SectionCard(
                      child: StationNetworkCard(
                        mapStations: mapStations,
                        onStationTap: _showStationDetails,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(child: StationAlertsCard(alerts: alerts)),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SectionCard(
                      child: StationNetworkCard(
                        mapStations: mapStations,
                        onStationTap: _showStationDetails,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _totalCustomersCard(),
                        const SizedBox(height: 20),
                        SectionCard(child: StationAlertsCard(alerts: alerts)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          SectionCard(
            child: AiExplanationCard(explanation: overviewExplanation),
          ),
          const SizedBox(height: 22),
          SectionCard(child: TopStationsCard(stations: stations)),
        ],
      ),
    );
  }
}