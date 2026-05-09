// test/logic_test.dart
//
// Unit tests for the pure-logic helpers extracted from:
//   - stations_page.dart   → _toDouble, _formatDistance, _sortByDistance,
//                             _statusColor, _generateStatuses
//   - full_map_screen.dart → _toDouble
//   - home_page.dart       → _toDouble
//
// Run with:  flutter test test/logic_test.dart
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers extracted from the widgets under test.
// These are pure functions so they can be tested without a widget tree.
// ---------------------------------------------------------------------------

/// Extracted from StationsPage / FullMapScreen / HomePage
double toDouble(dynamic value, double fallback) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

/// Extracted from StationsPage
List<String> generateStatuses(int count) {
  final list = List<String>.filled(count, 'green');
  if (count > 0) list[0] = 'green';
  if (count > 2) list[2] = 'red';
  if (count > 3) list[3] = 'orange';
  if (count > 4) list[4] = 'orange';
  return list;
}

/// Extracted from StationsPage
Color statusColor(String status) {
  switch (status) {
    case 'green':
      return const Color(0xFF22C55E);
    case 'orange':
      return const Color(0xFFF59E0B);
    case 'red':
      return const Color(0xFFEF4444);
    default:
      return Colors.grey;
  }
}

/// Simplified _formatDistance logic (without Geolocator, using a stub).
/// Mirrors the logic in stations_page.dart:
///   dist < 1000  → "${dist.toInt()} m"
///   otherwise    → "${(dist/1000).toStringAsFixed(1)} km"
String formatDistanceFromMeters(double distMeters) {
  if (distMeters < 1000) return '${distMeters.toInt()} m';
  return '${(distMeters / 1000).toStringAsFixed(1)} km';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // _toDouble — coordinate parsing
  // =========================================================================
  group('_toDouble – coordinate parsing', () {
    test('returns fallback when value is null', () {
      expect(toDouble(null, 0.0), equals(0.0));
    });

    test('returns fallback when value is null with non-zero fallback', () {
      expect(toDouble(null, 21.5433), closeTo(21.5433, 1e-6));
    });

    test('converts int to double', () {
      expect(toDouble(21, 0.0), equals(21.0));
    });

    test('converts double directly', () {
      expect(toDouble(39.1728, 0.0), closeTo(39.1728, 1e-6));
    });

    test('parses numeric string', () {
      expect(toDouble('24.7136', 0.0), closeTo(24.7136, 1e-6));
    });

    test('parses negative coordinate string', () {
      expect(toDouble('-33.8688', 0.0), closeTo(-33.8688, 1e-6));
    });

    test('parses integer string', () {
      expect(toDouble('39', 0.0), equals(39.0));
    });

    test('returns fallback for non-numeric string', () {
      expect(toDouble('invalid', -1.0), equals(-1.0));
    });

    test('returns fallback for empty string', () {
      expect(toDouble('', -1.0), equals(-1.0));
    });

    test('handles zero as a valid value (not treated as null)', () {
      expect(toDouble(0, -1.0), equals(0.0));
    });

    test('handles zero string', () {
      expect(toDouble('0.0', -1.0), equals(0.0));
    });
  });

  // =========================================================================
  // _generateStatuses
  // =========================================================================
  group('_generateStatuses – station status list generation', () {
    test('empty list when count is 0', () {
      expect(generateStatuses(0), isEmpty);
    });

    test('single station is green', () {
      expect(generateStatuses(1), equals(['green']));
    });

    test('two stations are both green', () {
      expect(generateStatuses(2), equals(['green', 'green']));
    });

    test('third station (index 2) is red', () {
      final statuses = generateStatuses(3);
      expect(statuses[2], equals('red'));
    });

    test('fourth station (index 3) is orange', () {
      final statuses = generateStatuses(4);
      expect(statuses[3], equals('orange'));
    });

    test('fifth station (index 4) is orange', () {
      final statuses = generateStatuses(5);
      expect(statuses[4], equals('orange'));
    });

    test('first station always green regardless of count', () {
      for (int i = 1; i <= 10; i++) {
        expect(generateStatuses(i)[0], equals('green'),
            reason: 'index 0 should be green when count=$i');
      }
    });

    test('second station (index 1) is always green', () {
      final statuses = generateStatuses(5);
      expect(statuses[1], equals('green'));
    });

    test('list length equals count', () {
      for (int i = 0; i <= 8; i++) {
        expect(generateStatuses(i).length, equals(i));
      }
    });
  });

  // =========================================================================
  // _statusColor
  // =========================================================================
  group('_statusColor – color mapping', () {
    test('green maps to Color(0xFF22C55E)', () {
      expect(statusColor('green'), equals(const Color(0xFF22C55E)));
    });

    test('orange maps to Color(0xFFF59E0B)', () {
      expect(statusColor('orange'), equals(const Color(0xFFF59E0B)));
    });

    test('red maps to Color(0xFFEF4444)', () {
      expect(statusColor('red'), equals(const Color(0xFFEF4444)));
    });

    test('unknown status maps to grey', () {
      expect(statusColor('unknown'), equals(Colors.grey));
    });

    test('empty string maps to grey', () {
      expect(statusColor(''), equals(Colors.grey));
    });

    test('uppercase status not matched → falls back to grey', () {
      // Current implementation is case-sensitive
      expect(statusColor('GREEN'), equals(Colors.grey));
    });
  });

  // =========================================================================
  // _formatDistance (logic layer – no Geolocator dependency)
  // =========================================================================
  group('_formatDistance – distance formatting', () {
    test('0 meters returns "0 m"', () {
      expect(formatDistanceFromMeters(0), equals('0 m'));
    });

    test('500 meters returns "500 m"', () {
      expect(formatDistanceFromMeters(500), equals('500 m'));
    });

    test('999 meters returns "999 m" (still below 1 km threshold)', () {
      expect(formatDistanceFromMeters(999), equals('999 m'));
    });

    test('1000 meters returns "1.0 km"', () {
      expect(formatDistanceFromMeters(1000), equals('1.0 km'));
    });

    test('1500 meters returns "1.5 km"', () {
      expect(formatDistanceFromMeters(1500), equals('1.5 km'));
    });

    test('10000 meters returns "10.0 km"', () {
      expect(formatDistanceFromMeters(10000), equals('10.0 km'));
    });

    test('decimal meters under 1 km are truncated to int', () {
      // 750.9 → "750 m" (toInt() truncates)
      expect(formatDistanceFromMeters(750.9), equals('750 m'));
    });

    test('km result is fixed to 1 decimal place', () {
      // 2333 m → 2.333 km → "2.3 km"
      expect(formatDistanceFromMeters(2333), equals('2.3 km'));
    });
  });

  // =========================================================================
  // _sortByDistance – ordering logic (pure / without Geolocator)
  // =========================================================================
  group('_sortByDistance – station ordering', () {
    /// Simulates the distance sort by pre-computing straight-line distance
    /// using the Haversine-like approximation used inside _sortByDistance.
    /// Here we test the *sorting contract* without touching Geolocator.

    double stubDistance(double userLat, double userLng,
        double stationLat, double stationLng) {
      // Simple Euclidean approximation — good enough to test ordering.
      final dLat = stationLat - userLat;
      final dLng = stationLng - userLng;
      return dLat * dLat + dLng * dLng; // squared distance
    }

    List<Map<String, dynamic>> sortStationsByDistance(
      double userLat,
      double userLng,
      List<Map<String, dynamic>> stations,
    ) {
      final sorted = List<Map<String, dynamic>>.from(stations);
      sorted.sort((a, b) {
        final distA = stubDistance(
            userLat, userLng, toDouble(a['lat'], 0), toDouble(a['lng'], 0));
        final distB = stubDistance(
            userLat, userLng, toDouble(b['lat'], 0), toDouble(b['lng'], 0));
        return distA.compareTo(distB);
      });
      return sorted;
    }

    final stations = [
      {'title': 'Far Station', 'lat': 25.0, 'lng': 40.0},
      {'title': 'Near Station', 'lat': 21.55, 'lng': 39.18},
      {'title': 'Mid Station', 'lat': 22.0, 'lng': 39.5},
    ];

    const userLat = 21.5433;
    const userLng = 39.1728;

    test('nearest station appears first', () {
      final sorted = sortStationsByDistance(userLat, userLng, stations);
      expect(sorted.first['title'], equals('Near Station'));
    });

    test('farthest station appears last', () {
      final sorted = sortStationsByDistance(userLat, userLng, stations);
      expect(sorted.last['title'], equals('Far Station'));
    });

    test('middle station is second', () {
      final sorted = sortStationsByDistance(userLat, userLng, stations);
      expect(sorted[1]['title'], equals('Mid Station'));
    });

    test('single station list stays unchanged', () {
      final single = [stations[0]];
      final sorted = sortStationsByDistance(userLat, userLng, single);
      expect(sorted.length, equals(1));
      expect(sorted.first['title'], equals('Far Station'));
    });

    test('empty list stays empty', () {
      final sorted =
          sortStationsByDistance(userLat, userLng, []);
      expect(sorted, isEmpty);
    });

    test('null coordinates fall back to 0,0 and sort accordingly', () {
      final withNull = [
        {'title': 'A', 'lat': null, 'lng': null},
        {'title': 'B', 'lat': 21.54, 'lng': 39.17},
      ];
      // Station B is very close to user; A has fallback 0,0 (far from Jeddah)
      final sorted = sortStationsByDistance(userLat, userLng, withNull);
      expect(sorted.first['title'], equals('B'));
    });
  });
}
