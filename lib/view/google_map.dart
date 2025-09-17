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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

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
                      "Check In pada:",
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

                  /// Tombol Swipe
                  SlideAction(
                    text: "Geser untuk Check In",
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    outerColor: Colors.green[400],
                    innerColor: Colors.white,
                    onSubmit: () async {
                      await _getCurrentLocation();

                      /// simpan jam & tanggal sekarang
                      final now = DateTime.now();
                      setState(() {
                        checkInTime = DateFormat('HH:mm:ss').format(now);
                        checkInDate = DateFormat('dd MMMM yyyy').format(now);
                      });

                      /// tampilkan dialog sukses dengan lottie
                      Future.delayed(const Duration(milliseconds: 500), () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                "Check In Berhasil 🎉",
                                textAlign: TextAlign.center,
                              ),
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
                                    "Tanggal: $checkInDate\nJam: $checkInTime",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      });

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
}
