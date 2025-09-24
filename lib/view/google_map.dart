import 'package:absensi/api/absensi.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:slide_to_act/slide_to_act.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  String _currentAddress = "Alamat tidak ditemukan";
  Marker? _marker;

  String? checkInTime;
  String? checkInDate;
  bool isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    // _loadCheckInStatus();
    _loadAbsenToday();
    _getCurrentLocation();
  }

  Future<void> _loadAbsenToday() async {
    final result = await AbsensiAPI.getAbsenToday();
    if (result != null && result.data != null) {
      setState(() {
        checkInDate = DateFormat(
          'dd MMMM yyyy',
        ).format(result.data!.attendanceDate!);
        checkInTime = result.data!.checkInTime;
        isCheckedIn = result.data!.checkInTime != null;
      });
    }
  }

  Future<void> _loadCheckInStatus() async {
    final checkInData = await PreferenceHandler.getCheckIn();
    if (checkInData.isNotEmpty) {
      setState(() {
        // isCheckedIn = true;
        checkInDate = checkInData["date"];
        checkInTime = checkInData["time"];
      });
    }
  }

  Future<void> _handleCheckIn() async {
    await _getCurrentLocation();

    final now = DateTime.now();
    final date = DateFormat('dd MMMM yyyy').format(now);
    final time = DateFormat('HH:mm:ss').format(now);

    final result = await AbsensiAPI.checkIn(
      lat: _currentPosition.latitude,
      lng: _currentPosition.longitude,
      address: _currentAddress,
    );

    if (result != null) {
      _showResultDialog(
        title: "Masuk",
        message: "Berhasil",
        date: date,
        time: time,
      );
      await _loadAbsenToday();
    } else {
      _showResultDialog(
        title: "Masuk",
        message: "Terjadi kesalahan",
        date: date,
        time: time,
      );
    }
  }

  // Future<void> _handleCheckIn() async {
  //   await _getCurrentLocation();

  //   final now = DateTime.now();
  //   final date = DateFormat('dd MMMM yyyy').format(now);
  //   final time = DateFormat('HH:mm:ss').format(now);

  //   setState(() {
  //     checkInDate = date;
  //     checkInTime = time;
  //     isCheckedIn = true;
  //   });

  //   // Simpan ke SharedPreferences
  //   await PreferenceHandler.saveCheckIn(date, time);

  //   final result = await AbsensiAPI.checkIn(
  //     lat: _currentPosition.latitude,
  //     lng: _currentPosition.longitude,
  //     address: _currentAddress,
  //   );

  //   _showResultDialog(
  //     title: "Check In",
  //     message: result?["message"] ?? "Terjadi kesalahan",
  //     date: date,
  //     time: time,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 12,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              markers: _marker != null ? {_marker!} : {},
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
          ),

          /// Panel bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lokasi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentAddress,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  /// Info Check In
                  if (checkInTime != null && checkInDate != null) ...[
                    Text(
                      "Absen pada:",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      "$checkInDate - $checkInTime",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  /// SlideAction atau Sudah Check In
                  isCheckedIn
                      ? Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Sudah Masuk",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : SlideAction(
                          text: "Geser ",
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          outerColor: Colors.green[400],
                          innerColor: Colors.white,
                          onSubmit: () async {
                            await _handleCheckIn();
                            return null;
                          },
                        ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _marker = Marker(
        markerId: const MarkerId("lokasi_saya"),
        position: _currentPosition,
        infoWindow: InfoWindow(
          title: 'Lokasi Anda',
          snippet: "${place.street}, ${place.locality}",
        ),
      );
      _currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}";

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }

  void _showResultDialog({
    required String title,
    required String message,
    required String date,
    required String time,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text("$title Berhasil ", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  "assets/lottie/absen_sukses.json",
                  width: 120,
                  height: 120,
                  repeat: false,
                ),
                const SizedBox(height: 12),
                Text(
                  "$message\nTanggal: $date\nJam: $time",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      );
    });
  }
}
