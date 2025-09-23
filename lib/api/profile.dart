import 'dart:convert';
import 'dart:io';

import 'package:absensi/api/endpoint/endpoint.dart';
import 'package:absensi/model/get_profile.dart';
import 'package:absensi/model/put_profile_model.dart';
import 'package:absensi/model/put_profile_photo.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:http/http.dart' as http;

class ProfileAPI {
  static Future<PutProfileModel> updateProfile({
    required String name,
    required String email,
    required File? imageFile,
  }) async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    print("Update Profile URL: $url");
    print("Update Profile Data: {name: $name}");
    String? base64Image;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final body = jsonEncode({
      "name": name,
      "email": email,
      "profile_photo": base64Image, // dikirim dalam base64
    });
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    print("Update Profile Response: ${response.statusCode}");
    print("Update Profile Body: ${response.body}");

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

  static Future<PutProfilePhotoModel> updateProfilePhoto({File? image}) async {
    final url = Uri.parse(Endpoint.editProfilePhoto);
    final token = await PreferenceHandler.getToken();
    String imageBase64 = "";
    if (image != null) {
      final bytes = await image.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    print("Update Profile URL: $url");
    // print("Update Profile Data: {profile_photo: $image}");

    final response = await http.put(
      url,
      body: {"profile_photo": imageBase64},
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Update Profile Response: ${response.statusCode}");
    print("Update Profile Body: ${response.body}");

    if (response.statusCode == 200) {
      return PutProfilePhotoModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error["message"] ??
            "Update profile gagal. Status: ${response.statusCode}",
      );
    }
  }

  static Future<GetUser> getProfile() async {
    final url = Uri.parse(Endpoint.profile);
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("Profile Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      return GetUser.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      print(error);
      throw Exception(error["message"] ?? "Gagal mengambil profil");
    }
  }
}
