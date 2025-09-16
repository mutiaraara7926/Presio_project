// import 'dart:convert';

// import 'package:absensi/api/endpoint.dart';
// import 'package:absensi/model/get_user.dart';
// import 'package:absensi/model/register_model.dart';
// import 'package:absensi/shared_preference/shared_preference.dart';
// import 'package:http/http.dart' as http;

// class AuthenticationAPI {
//   static Future<RegisterUserModel> registerUser({
//     required String email,
//     required String password,
//     required String name,
//   }) async {
//     final url = Uri.parse(Endpoint.register);

//     final response = await http.post(
//       url,
//       body: {"name": name, "email": email, "password": password},
//       headers: {"Accept": "application/json"},
//     );
//     if (response.statusCode == 200) {
//       return RegisterUserModel.fromJson.(json.decode(response.body));
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Register gagal");
//     }
//   }

//   static Future<RegisterUserModel> loginUser({
//     required String email,
//     required String password,
//   }) async {
//     final url = Uri.parse(Endpoint.login);
//     final response = await http.post(
//       url,
//       body: {"email": email, "password": password},
//       headers: {"Accept": "application/json"},
//     );
//     if (response.statusCode == 200) {
//       final data = RegisterUserModel.fromJson(json.decode(response.body));
//       await PreferenceHandler.saveToken(data.data.token);
//       await PreferenceHandler.saveLogin();
//       return data;
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Something went wrong");
//     }
//   }

//   static Future<GetUserModel> updateUser({required String name}) async {
//     final url = Uri.parse(Endpoint.profile);
//     final token = await PreferenceHandler.getToken();
//     final response = await http.put(
//       url,
//       body: {"name": name},
//       headers: {
//         "Accept": "application/json",
//         // "Content-Type": "application/json",
//         "Authorization": "Bearer $token",
//       },
//     );
//     if (response.statusCode == 200) {
//       return GetUserModel.fromJson(json.decode(response.body));
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Register gagal");
//     }
//   }

//   static Future<GetUserModel> getProfile() async {
//     final url = Uri.parse(Endpoint.profile);
//     final token = await PreferenceHandler.getToken();
//     final response = await http.get(
//       url,
//       headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//     );
//     if (response.statusCode == 200) {
//       return GetUserModel.fromJson(json.decode(response.body));
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Register gagal");
//     }
//   }
// }
