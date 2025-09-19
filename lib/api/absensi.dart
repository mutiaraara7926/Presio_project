import 'dart:convert';

import 'package:absensi/api/endpoint/endpoint.dart';
import 'package:absensi/model/keluar_model.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
    // ambil waktu sekarang
    final now = DateTime.now();

    // format tanggal (yyyy-MM-dd)
    final String attendanceDate = DateFormat('yyyy-MM-dd').format(now);

    // format jam (HH:mm)
    final String checkInTime = DateFormat('HH:mm').format(now);
    try {
      final response = await http.post(
        Uri.parse(Endpoint.checkIn),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: {
          "attendance_date": attendanceDate,
          "check_in": checkInTime,
          "check_in_lat": lat.toString(),
          "check_in_lng": lng.toString(),
          "check_in_location": "${lat.toString()}, ${lng.toString()}",
          "check_in_address": "Jakarta",
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Error: $e"};
    }
  }

  /// Check Out
  static Future<AbsenCheckOutModel?> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutLocation,
    required String checkOutAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();

      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkOutTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(Endpoint.checkOut),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "attendance_date": attendanceDate,
          "check_out": checkOutTime,
          "check_out_lat": checkOutLat.toString(),
          "check_out_lng": checkOutLng.toString(),
          "check_out_location": checkOutLocation,
          "check_out_address": checkOutAddress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return AbsenCheckOutModel.fromJson(jsonResponse);
      } else {
        print("CheckOut Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error CheckOut: $e");
      return null;
    }
  }
  // static Future<Map<String, dynamic>?> checkOut({
  //   required double lat,
  //   required double lng,
  //   required String address,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString("token");

  //   if (token == null) return {"message": "Token tidak ditemukan"};

  //   try {
  //     final response = await http.post(
  //       Uri.parse(Endpoint.checkOut),
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Accept": "application/json",
  //       },
  //       body: {
  //         "latitude": lat.toString(),
  //         "longitude": lng.toString(),
  //         "address": address,
  //       },
  //     );

  //     return jsonDecode(response.body);
  //   } catch (e) {
  //     return {"message": "Error: $e"};
  //   }
  // }

  /// Get Absen Today

  static Future<Map<String, dynamic>?> getAbsenToday() async {
    try {
      final response = await http.get(Uri.parse(Endpoint.absenToday));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Gagal load absen today: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error API getAbsenToday: $e");
      return null;
    }
  }
}
