import 'dart:convert';

import 'package:absensi/api/endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiAPI {
  /// Check In
  static Future<Map<String, dynamic>?> checkIn({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return {"message": "Token tidak ditemukan"};

    try {
      final response = await http.post(
        Uri.parse(Endpoint.checkIn),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "latitude": lat.toString(),
          "longitude": lng.toString(),
          "address": address,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Error: $e"};
    }
  }

  /// Check Out
  static Future<Map<String, dynamic>?> checkOut({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return {"message": "Token tidak ditemukan"};

    try {
      final response = await http.post(
        Uri.parse(Endpoint.checkOut),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "latitude": lat.toString(),
          "longitude": lng.toString(),
          "address": address,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Error: $e"};
    }
  }
}
