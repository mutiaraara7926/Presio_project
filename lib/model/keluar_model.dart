// To parse this JSON data, do
//
//     final absenCheckOutModel = absenCheckOutModelFromJson(jsonString);

import 'dart:convert';

AbsenCheckOutModel absenCheckOutModelFromJson(String str) =>
    AbsenCheckOutModel.fromJson(json.decode(str));

String absenCheckOutModelToJson(AbsenCheckOutModel data) =>
    json.encode(data.toJson());

class AbsenCheckOutModel {
  String? message;
  Data? data;

  AbsenCheckOutModel({this.message, this.data});

  factory AbsenCheckOutModel.fromJson(Map<String, dynamic> json) =>
      AbsenCheckOutModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};

  void operator [](String other) {}
}

class Data {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  String? checkInAddress;
  String? checkOutAddress;
  String? checkInLocation;
  String? checkOutLocation;
  String? status;
  dynamic alasanIzin;

  Data({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    this.status,
    this.alasanIzin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    checkInLocation: json["check_in_location"],
    checkOutLocation: json["check_out_location"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
