import 'dart:convert';
import 'dart:io';

import 'package:absensi/api/endpoint/endpoint.dart';
import 'package:absensi/model/get_batch_model.dart';
import 'package:absensi/model/get_list_training_model.dart';
import 'package:absensi/model/get_profile.dart';
import 'package:absensi/model/login_model.dart' show LoginModel;
import 'package:absensi/model/put_profile_model.dart';
import 'package:absensi/model/put_profile_photo.dart';
import 'package:absensi/model/register_model.dart';
import 'package:absensi/model/reset_password.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:http/http.dart' as http;

class AuthenticationAPI {
  // Register
  static Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required File profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    final readImage = profilePhoto.readAsBytesSync();
    final b64 = base64Encode(readImage);
    final imageWithPrefix = "data:image/png;base64,$b64";

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": imageWithPrefix,
        "batch_id": batchId,
        "training_id": trainingId,
      }),
    );

    if (response.statusCode == 200) {
      return RegisterModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Failed to Register");
    }
  }

  // Login
  /// LOGIN USER
  static Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );

    final result = json.decode(response.body);
    if (response.statusCode == 200) {
      final data = LoginModel.fromJson(result);

      // ✅ Simpan token
      if (data.data?.token != null) {
        await PreferenceHandlerAsli.saveToken(data.data!.token!);
      }
      await PreferenceHandlerAsli.saveLogin();

      return data;
    } else {
      throw Exception(result["message"] ?? "Login gagal");
    }
  }

  // Update profile
  static Future<PutProfileModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandlerAsli.getToken();

    final response = await http.put(
      url,
      body: {"name": name, "email": email},
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return PutProfileModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error["message"] ??
            "Update profile gagal. Status: ${response.statusCode}",
      );
    }
  }

  static Future<PutProfilePhotoModel?> updateProfilePhoto({
    required String token,
    required String base64Photo,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(Endpoint.editProfilePhoto),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token", // kalau pakai JWT / sanctum
        },
        body: jsonEncode({"profile_photo": base64Photo}),
      );

      if (response.statusCode == 200) {
        return putProfilePhotoModelFromJson(response.body);
      } else {
        print("❌ Gagal update foto. Status: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error update foto: $e");
      return null;
    }
  }

  // Get profile
  static Future<GetUser> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandlerAsli.getToken();
    print(token);
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        // "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      return GetUser.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }

  // Get trainings
  static Future<GetListTrainingModel> getListTraining() async {
    final url = Uri.parse(Endpoint.training);
    final token = await PreferenceHandlerAsli.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return GetListTrainingModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengambil data layanan");
    }
  }

  // Get batches
  static Future<GetBatchesModel> getListBatch() async {
    final url = Uri.parse(Endpoint.batches);
    final token = await PreferenceHandlerAsli.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return GetBatchesModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengambil data layanan");
    }
  }

  // Forgot Password: request OTP

  static Future<ResetPasswordModel> requestOtp({required String email}) async {
    final url = Uri.parse(Endpoint.forgotPassword);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return ResetPasswordModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengirim OTP");
    }
  }

  // Reset Password

  static Future<ResetPasswordModel> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return ResetPasswordModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mereset password");
    }
  }
}
