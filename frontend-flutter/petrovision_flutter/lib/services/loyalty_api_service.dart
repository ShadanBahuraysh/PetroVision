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
      final res = await http.get(Uri.parse("$baseUrl/loyalty/membership/$userId"));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print("getMembership error: $e");
    }
    return null;
  }

  static Future<List<dynamic>> getTransactions(String userId) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/loyalty/transactions/$userId"));
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
}
