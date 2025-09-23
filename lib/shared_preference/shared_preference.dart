import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String tokenKey = "token";
  static const String userIdKey = "user_id";
  static const String userEmailKey = "user_email";
  static const String userNameKey = "user_name";
  static const String batchKey = "batch";
  static const String loginKey = "login";

  static Future<void> saveUserData(
    String token,
    int userId,
    String email,
    String name,
    String batch,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(userIdKey, userId);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userNameKey, name);
    await prefs.setString(batchKey, batch);
    await prefs.setBool(loginKey, true);
  }

  static void saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }

  static Future<String?> getBatch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(batchKey);
  }

  static Future<void> setBatch(String batch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(batchKey, batch);
  }

  static Future<bool?> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userEmailKey);
    await prefs.remove(userNameKey);
    await prefs.setBool(loginKey, false);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> setUserProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  static Future<String?> getUserProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }

  static const String checkInKey = "check_in";
  static const String checkInDateKey = "check_in_date";
  static const String checkInTimeKey = "check_in_time";

  static Future<void> saveCheckIn(String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(checkInKey, true);
    await prefs.setString(checkInDateKey, date);
    await prefs.setString(checkInTimeKey, time);
  }

  static Future<Map<String, String?>> getCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedIn = prefs.getBool(checkInKey) ?? false;
    final date = prefs.getString(checkInDateKey);
    final time = prefs.getString(checkInTimeKey);
    if (!isCheckedIn) return {};
    return {"date": date, "time": time};
  }

  static const String checkOutKey = "check_out";
  static const String checkOutDateKey = "check_out_date";
  static const String checkOutTimeKey = "check_out_time";

  static Future<void> saveCheckOut(String date, String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(checkOutKey, true);
    await prefs.setString(checkOutDateKey, date);
    await prefs.setString(checkOutTimeKey, time);
  }

  static Future<Map<String, String?>> getCheckOut() async {
    final prefs = await SharedPreferences.getInstance();
    final isCheckedOut = prefs.getBool(checkOutKey) ?? false;
    final date = prefs.getString(checkOutDateKey);
    final time = prefs.getString(checkOutTimeKey);
    if (!isCheckedOut) return {};
    return {"date": date, "time": time};
  }

  static const String lastCheckInDateKey = "last_check_in_date";
  static const String isCheckedInKey = "is_checked_in";

  // Method untuk menyimpan status check-in
  static Future<void> setCheckedInStatus(
    bool isCheckedIn, {
    String? date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isCheckedInKey, isCheckedIn);
    if (date != null) {
      await prefs.setString(lastCheckInDateKey, date);
    }
  }

  // Method untuk mendapatkan status check-in
  static Future<bool> getCheckedInStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Cek apakah sudah check-in hari ini
    final lastCheckInDate = prefs.getString(lastCheckInDateKey);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Jika tanggal terakhir check-in bukan hari ini, reset status
    if (lastCheckInDate != today) {
      await setCheckedInStatus(false);
      return false;
    }

    return prefs.getBool(isCheckedInKey) ?? false;
  }

  // Method untuk reset status check-in (saat logout atau hari baru)
  static Future<void> resetCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isCheckedInKey, false);
  }
}
