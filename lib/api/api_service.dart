// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:projek_ara/api/endpoint/endpoint.dart';
// import 'package:projek_ara/model/get_user.dart';
// import 'package:projek_ara/model/menu_model.dart';
// import 'package:projek_ara/model/register_model.dart';
// import 'package:projek_ara/shared_preference/shared_preference.dart';

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
//       return RegisterUserModel.fromJson(json.decode(response.body));
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Request gagal");
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
//       return RegisterUserModel.fromJson(json.decode(response.body));
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Login gagal");
//     }
//   }

//   static Future<GetUserModel> updateUser({required String name}) async {
//     final url = Uri.parse(Endpoint.profile);
//     final token = await PreferenceHandler.getToken();

//     if (token == null) {
//       throw Exception("Token tidak ditemukan, silakan login ulang");
//     }

//     final response = await http.put(
//       url,
//       body: {"name": name},
//       headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//     );

//     if (response.statusCode == 200) {
//       return GetUserModel.fromJson(json.decode(response.body));
//     } else {
//       final error = json.decode(response.body);
//       throw Exception(error["message"] ?? "Update profil gagal");
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
//       throw Exception(error["message"] ?? "Get data is not valid");
//     }
//   }

//   static Future<List<MenuModel>> getMenus() async {
//     final url = Uri.parse(Endpoint.menus);
//     final token = await PreferenceHandler.getToken();

//     if (token == null) {
//       throw Exception("Token tidak ditemukan, silakan login ulang");
//     }

//     final response = await http.get(
//       url,
//       headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//     );

//     print("DEBUG STATUS: ${response.statusCode}");
//     print("DEBUG BODY: ${response.body}");

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return (data['data'] as List).map((e) => MenuModel.fromJson(e)).toList();
//     } else if (response.statusCode == 401) {
//       throw Exception("Unauthenticated");
//     } else {
//       throw Exception("Error ${response.statusCode}: ${response.body}");
//     }
//   }

//   static Future<String> addMenu(
//     String name,
//     String description,
//     String price,
//     File? image,
//   ) async {
//     final url = Uri.parse(Endpoint.menus);
//     final token = await PreferenceHandler.getToken();

//     if (token == null) {
//       throw Exception("Token tidak ditemukan, silakan login ulang");
//     }

//     var request = http.MultipartRequest('POST', url);

//     request.headers['Authorization'] = 'Bearer $token';
//     request.headers['Accept'] = 'application/json';

//     request.fields['name'] = name;
//     request.fields['description'] = description;
//     request.fields['price'] = price;

//     if (image != null) {
//       var imageFile = await http.MultipartFile.fromPath(
//         'image',
//         image.path,
//         filename: 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg',
//       );
//       request.files.add(imageFile);
//     }

//     try {
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = jsonDecode(responseBody);

//       print("Add Menu Response: ${response.statusCode}");
//       print("Add Menu Body: $responseBody");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return data['message'] ?? "Menu berhasil ditambahkan";
//       } else {
//         throw Exception(data['message'] ?? "Gagal menambahkan menu");
//       }
//     } catch (e) {
//       print("Error in addMenu: $e");
//       throw Exception("Gagal menambahkan menu: $e");
//     }
//   }

//   static Future<String> updateMenu(
//     int id,
//     String name,
//     String description,
//     String price,
//     File? image,
//   ) async {
//     final token = await PreferenceHandler.getToken();

//     if (token == null) {
//       throw Exception("Token tidak ditemukan, silakan login ulang");
//     }

//     String? imageBase64;
//     if (image != null) {
//       final bytes = await image.readAsBytes();
//       imageBase64 = base64Encode(bytes);
//     }

//     final url = Uri.parse("${Endpoint.menus}/$id");
//     final res = await http.put(
//       url,
//       headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//       body: {
//         "name": name,
//         "description": description,
//         "price": price,
//         if (imageBase64 != null) "image": imageBase64,
//       },
//     );

//     final data = jsonDecode(res.body);
//     if (res.statusCode == 200) {
//       return data['message'] ?? "Menu berhasil diperbarui";
//     } else {
//       throw Exception(data['message'] ?? "Gagal update menu");
//     }
//   }

//   // Hapus menu
//   static Future<String> deleteMenu(int id) async {
//     final token = await PreferenceHandler.getToken();
//     if (token == null) throw Exception("Token tidak ditemukan");

//     final url = Uri.parse("${Endpoint.menus}/$id");
//     final response = await http.delete(
//       url,
//       headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
//     );

//     final data = jsonDecode(response.body);
//     if (response.statusCode == 200) return "success";
//     throw Exception(data['message'] ?? "Gagal menghapus menu");
//   }
// }
