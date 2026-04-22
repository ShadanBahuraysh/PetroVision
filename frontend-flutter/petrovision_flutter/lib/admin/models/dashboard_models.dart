import 'package:flutter/material.dart';

/// 🎨 COLOR SYSTEM
class AppColors {
  static const navy = Color(0xFF132935);
  static const blue = Color(0xFF4195AF);
  static const lightBlue = Color(0xFF7FB3C8);

  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444);

  static const grey = Color(0xFF8A959E);
}

/// KPI MODEL
class KpiItem {
  final String title;
  final String value;
  final String change;
  final String subtitle;
  final IconData icon;

  /// 🎨 NEW
  final Color color;        // main accent (bars/icons)
  final Color chipColor;    // change badge
  final bool isPositive;    // for logic

  const KpiItem({
    required this.title,
    required this.value,
    required this.change,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.chipColor,
    required this.isPositive,
  });
}

/// ALERT MODEL
class AlertItem {
  final String title;
  final String station;
  final String severity;
  final Color chipColor;

  const AlertItem({
    required this.title,
    required this.station,
    required this.severity,
    required this.chipColor,
  });
}

/// STATION MODEL
class StationItem {
  final String name;
  final String city;
  final String status;
  final double score;

  const StationItem({
    required this.name,
    required this.city,
    required this.status,
    required this.score,
  });
}