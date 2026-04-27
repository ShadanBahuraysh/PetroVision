import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';
import 'alert_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  /// ✅ KPI DATA
  final List<KpiItem> kpis = const [
    KpiItem(
      title: 'Active Stations',
      value: '156',
      change: '+4.2%',
      subtitle: 'compared to last month',
      icon: Icons.local_gas_station_outlined,
      color: Color(0xFF4195AF),
      chipColor: Color(0xFF22C55E),
      isPositive: true,
    ),
    KpiItem(
      title: 'Down Stations',
      value: '08',
      change: '-2.1%',
      subtitle: 'fewer outages this quarter',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFF132935),
      chipColor: Color(0xFFEF4444),
      isPositive: false,
    ),
    KpiItem(
      title: 'Revenue',
      value: 'SAR 1.2M',
      change: '+18.3%',
      subtitle: 'growth this month',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF4195AF),
      chipColor: Color(0xFF22C55E),
      isPositive: true,
    ),
    KpiItem(
      title: 'Losses',
      value: 'SAR 84K',
      change: '-6.8%',
      subtitle: 'lower than previous period',
      icon: Icons.trending_down_rounded,
      color: Color(0xFF132935),
      chipColor: Color(0xFFEF4444),
      isPositive: false,
    ),
  ];

  /// ✅ FIXED (was missing)
  late List<String> selectedFilters;

  /// ✅ FIXED (was missing)
  final alerts = const [
    AlertItem(
      title: 'Pump maintenance overdue',
      station: 'Jeddah North Station',
      severity: 'High',
      chipColor: Color(0xFFEF4444),
      recommendations: [
        AlertRecommendation(
          title: 'Immediate pump inspection',
          description: 'Dispatch a maintenance technician to inspect all pumps at Jeddah North Station. The model detected a 34% drop in pump availability over the past 7 days, indicating mechanical wear or blockage.',
          estimatedTime: '2–3 hours',
        ),
        AlertRecommendation(
          title: 'Reduce downtime through preventive maintenance',
          description: 'Schedule recurring quarterly pump servicing to prevent future outages. Our model flags this station as high-risk for pump failure based on historical downtime patterns.',
          estimatedTime: '1 day (scheduling)',
        ),
        AlertRecommendation(
          title: 'Optimize pump allocation',
          description: 'Temporarily redirect high-traffic flow to operational pumps and update signage. Consider deploying a mobile pump unit if downtime exceeds 4 hours.',
          estimatedTime: '30 minutes',
        ),
      ],
      actionSteps: [
        'Contact on-site technician at Jeddah North Station',
        'Run pump diagnostic and log fault codes',
        'Replace worn components or escalate to supplier',
        'Update pump status in the PetroVision system',
        'Schedule follow-up inspection within 7 days',
      ],
    ),
    AlertItem(
      title: 'Low fuel stock warning',
      station: 'Riyadh East Station',
      severity: 'Medium',
      chipColor: Color(0xFFF59E0B),
      recommendations: [
        AlertRecommendation(
          title: 'Improve inventory replenishment',
          description: 'Current fuel volume at Riyadh East is below the 15% safety threshold. The model predicts a stockout within 18 hours based on current transaction rate and stock levels.',
          estimatedTime: '4–6 hours (delivery)',
        ),
        AlertRecommendation(
          title: 'Review fuel demand patterns',
          description: 'Riyadh East shows consistently higher 91-grade demand on weekends. Adjust the restocking schedule to ensure Friday deliveries are doubled to meet peak demand.',
          estimatedTime: '1 hour (review)',
        ),
        AlertRecommendation(
          title: 'Activate emergency fuel transfer',
          description: 'If restocking is delayed, coordinate a fuel transfer from the nearest surplus station (Riyadh Central) to prevent service interruption.',
          estimatedTime: '2–3 hours',
        ),
      ],
      actionSteps: [
        'Confirm current fuel level readings at Riyadh East',
        'Contact fuel supplier to expedite next delivery',
        'Check alternative stock from Riyadh Central Station',
        'Update inventory forecast model with new demand data',
        'Notify station manager of low-stock protocol',
      ],
    ),
    AlertItem(
      title: 'Network interruption detected',
      station: 'Makkah Gate Station',
      severity: 'Low',
      chipColor: Color(0xFF4195AF),
      recommendations: [
        AlertRecommendation(
          title: 'Stabilize network connectivity',
          description: 'POS uptime at Makkah Gate dropped to 84% over the last 24 hours. The model links this to intermittent ISP outages during peak hours. Verify router and switch health.',
          estimatedTime: '1–2 hours',
        ),
        AlertRecommendation(
          title: 'Enable backup connectivity failover',
          description: 'Activate the secondary SIM-based failover connection to maintain POS availability. Ensure the backup configuration is up to date and tested.',
          estimatedTime: '30 minutes',
        ),
      ],
      actionSteps: [
        'Ping network gateway at Makkah Gate Station',
        'Restart router and check modem signal strength',
        'Activate backup 4G failover connection',
        'Test POS transaction flow end-to-end',
        'Log incident with ISP for SLA review',
      ],
    ),
  ];

  final stations = const [
    StationItem(name: 'Riyadh Central', city: 'Riyadh', status: 'Operational', score: 97.6),
    StationItem(name: 'Jeddah Marina', city: 'Jeddah', status: 'Operational', score: 95.8),
    StationItem(name: 'Makkah Route', city: 'Makkah', status: 'Monitoring', score: 91.9),
    StationItem(name: 'Taif Hills', city: 'Taif', status: 'Operational', score: 89.4),
  ];

  @override
  void initState() {
    super.initState();
    selectedFilters = ['Month', 'Month', 'Month', 'Month'];
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 0,
      title: 'Dashboard Overview',
      subtitle: 'Welcome back! Here\'s what\'s happening across PetroVision today.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// KPI ROW - responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                // 2x2 grid on narrow screens
                return Column(
                  children: [
                    Row(
                      children: List.generate(2, (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 0 ? 16 : 0),
                          child: KpiCard(
                            item: kpis[i],
                            selectedFilter: selectedFilters[i],
                            onChanged: (v) { if (v != null) setState(() => selectedFilters[i] = v); },
                          ),
                        ),
                      )),
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
                              selectedFilter: selectedFilters[idx],
                              onChanged: (v) { if (v != null) setState(() => selectedFilters[idx] = v); },
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }
              // Full 4-column row on wide screens
              return Row(
                children: List.generate(kpis.length, (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == kpis.length - 1 ? 0 : 16),
                    child: KpiCard(
                      item: kpis[index],
                      selectedFilter: selectedFilters[index],
                      onChanged: (v) { if (v != null) setState(() => selectedFilters[index] = v); },
                    ),
                  ),
                )),
              );
            },
          ),

          const SizedBox(height: 22),

          /// CHARTS
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            if (isNarrow) {
              return Column(children: const [
                SectionCard(child: MemberGrowthChart()),
                SizedBox(height: 16),
                SectionCard(child: TierDistributionCard()),
              ]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: SectionCard(child: MemberGrowthChart())),
                SizedBox(width: 20),
                Expanded(child: SectionCard(child: TierDistributionCard())),
              ],
            );
          }),

          const SizedBox(height: 22),

          /// NETWORK + ALERTS
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            if (isNarrow) {
              return Column(children: [
                const SectionCard(child: StationNetworkCard()),
                const SizedBox(height: 16),
                SectionCard(child: StationAlertsCard(alerts: alerts)),
              ]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 2, child: SectionCard(child: StationNetworkCard())),
                const SizedBox(width: 20),
                Expanded(child: SectionCard(child: StationAlertsCard(alerts: alerts))),
              ],
            );
          }),

          const SizedBox(height: 22),

          /// TABLE
          SectionCard(
            child: TopStationsCard(stations: stations),
          ),
        ],
      ),
    );
  }
}