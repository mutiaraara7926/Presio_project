import 'dart:convert';

import 'package:absensi/api/endpoint/endpoint.dart';
import 'package:absensi/model/history_model.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:http/http.dart' as http;

class HistoryService {
  static Future<HistoryAbsenModel> getHistory() async {
    final url = Uri.parse(Endpoint.history);
    final token = await PreferenceHandlerAsli.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("History Status: ${response.statusCode}");
    print("History Body: ${response.body}");

    if (response.statusCode == 200) {
      return HistoryAbsenModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Gagal mengambil riwayat absensi");
    }
  }
}
