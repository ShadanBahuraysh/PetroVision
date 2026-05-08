import 'dart:convert';
import 'package:http/http.dart' as http;

class LoyaltyApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<int> getPoints(String userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/loyalty/points/$userId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["current_points"] ?? 0;
      }
    } catch (e) {
      print("getPoints error: $e");
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
      print("getMembership error: $e");
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
      print("getTransactions error: $e");
    }
    return [];
  }

  static Future<List<dynamic>> getAllOffers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/offers/"));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print("getAllOffers error: $e");
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
      print("earnPoints error: $e");
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
      print("redeemPoints failed: ${res.statusCode} ${res.body}");
    } catch (e) {
      print("redeemPoints error: $e");
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
    print("scanEarnQr error: $e");
    return {"error": true, "detail": "Connection error. Please try again."};
  }
}

}