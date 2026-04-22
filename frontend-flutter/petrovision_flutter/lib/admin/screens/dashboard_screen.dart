import 'package:flutter/material.dart';

import '../models/dashboard_models.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';

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
    ),
    AlertItem(
      title: 'Low fuel stock warning',
      station: 'Riyadh East Station',
      severity: 'Medium',
      chipColor: Color(0xFFF59E0B),
    ),
    AlertItem(
      title: 'Network interruption detected',
      station: 'Makkah Gate Station',
      severity: 'Low',
      chipColor: Color(0xFF4195AF),
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

          /// KPI ROW
          Row(
            children: List.generate(kpis.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == kpis.length - 1 ? 0 : 16),
                  child: KpiCard(
                    item: kpis[index],
                    selectedFilter: selectedFilters[index],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedFilters[index] = value);
                    },
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 22),

          /// CHARTS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                flex: 2,
                child: SectionCard(child: MemberGrowthChart()),
              ),
              SizedBox(width: 20),
              Expanded(
                child: SectionCard(child: TierDistributionCard()),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /// NETWORK + ALERTS
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: SectionCard(child: StationNetworkCard()),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SectionCard(child: StationAlertsCard(alerts: alerts)),
              ),
            ],
          ),

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