// To parse this JSON data, do
//
//     final getUserModel = getUserModelFromJson(jsonString);

import 'dart:convert';

GetUserModel getUserModelFromJson(String str) =>
    GetUserModel.fromJson(json.decode(str));

String getUserModelToJson(GetUserModel data) => json.encode(data.toJson());

class GetUserModel {
  String message;
  GetData data;

  GetUserModel({required this.message, required this.data});

  factory GetUserModel.fromJson(Map<String, dynamic> json) => GetUserModel(
    message: json["message"],
    data: GetData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class GetData {
  int id;
  String name;
  String email;
  dynamic emailVerifiedAt;
  DateTime createdAt;
  DateTime updatedAt;

  GetData({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GetData.fromJson(Map<String, dynamic> json) => GetData(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
