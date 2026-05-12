// ========================================================================================================
// PetroVision Loyalty API Service
// --------------------------------------------------------------------------------------------------------
// This file defines the LoyaltyApiService used
// for handling loyalty-related API communication
// between the Flutter frontend and backend.
//
// Features included:
// - Loading customer loyalty points
// - Loading customer membership information
// - Loading transaction history
// - Loading available loyalty offers
// - Sending earn-points requests
// - Sending redeem-points requests
// - Processing QR-code earning requests
// - Handling API errors and fallback responses
// - Returning structured loyalty data to UI screens
//
// It also centralizes loyalty API calls,
// reward-management operations,
// and backend communication logic
// within the PetroVision application.
// ========================================================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LoyaltyApiService {
  static const String baseUrl = "http://localhost:8000";

  static Future<int> getPoints(String userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/loyalty/points/$userId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["current_points"] ?? 0;
      }
    } catch (e) {
      debugPrint("getPoints error: $e");
    }
    return 0;
  }

  static Future<Map<String, dynamic>?> getMembership(String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/loyalty/membership/$userId"),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("getMembership error: $e");
    }
    return null;
  }

  static Future<List<dynamic>> getTransactions(String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/loyalty/transactions/$userId"),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("getTransactions error: $e");
    }
    return [];
  }

  static Future<List<dynamic>> getAllOffers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/offers/"));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("getAllOffers error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>?> earnPoints({
    required String userId,
    required double amount,
    required String tier,
    String? stationId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/loyalty/earn-points"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "amount": amount,
          "tier": tier,
          if (stationId != null) "station_id": stationId,
        }),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("earnPoints error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> redeemPoints({
    required String userId,
    required int points,
    required String offerId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/loyalty/redeem-points"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "points": points,
          "offer_id": offerId,
        }),
      );

      if (res.statusCode == 200) return jsonDecode(res.body);
      debugPrint("redeemPoints failed: ${res.statusCode} ${res.body}");
    } catch (e) {
      debugPrint("redeemPoints error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> scanEarnQr({
  required String qrCode,
  required String userId,
  required double amount,
  String tier = "Bronze",
  String? stationId,
}) async {
  try {
    final res = await http.post(
      Uri.parse("$baseUrl/loyalty/earn-points"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "qr_code": qrCode,
        "amount": amount,
        "tier": tier,
        if (stationId != null) "station_id": stationId,
      }),
    );

    if (res.statusCode == 200) return jsonDecode(res.body);

    // Return error detail so caller can show the right message
    try {
      final errorData = jsonDecode(res.body);
      return {"error": true, "detail": errorData["detail"] ?? "Something went wrong"};
    } catch (_) {
      return {"error": true, "detail": "Something went wrong"};
    }
  } catch (e) {
    debugPrint("scanEarnQr error: $e");
    return {"error": true, "detail": "Connection error. Please try again."};
  }
}

}
