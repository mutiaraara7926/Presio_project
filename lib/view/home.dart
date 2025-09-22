import 'package:absensi/api/absensi.dart';
import 'package:absensi/api/profile.dart';
import 'package:absensi/model/get_profile.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/google_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const id = "/home";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GetProfileModel? user; // simpan nama user
  bool isLoading = true;
  String userName = "";
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final userData = await ProfileAPI.getProfile();
      setState(() {
        user = userData;
        userName = userData.data?.name ?? "";
      });
      await PreferenceHandler.setUserName(userName);
    } catch (e) {
      setState(() => errorMessage = e.toString());
      print("Error loading user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Pagi";
    } else if (hour < 17) {
      return "Siang";
    } else {
      return "Malam";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey, // background lembut
                  borderRadius: BorderRadius.circular(20), // sudut membulat
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff8A2D3B).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/Location.png",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Greeting Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                // decoration: BoxDecoration(
                //   color: const Color(0xff8A2D3B),
                //   borderRadius: BorderRadius.circular(20),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.3),
                //       blurRadius: 10,
                //       offset: const Offset(0, 10),
                //     ),
                //   ],
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading
                          ? "Memuat data..."
                          : "Selamat ${_greeting()}, ${userName}!",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff8A2D3B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Floating Card tambahan biar nggak sepi
              Card(
                elevation: 80,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.black.withOpacity(0.4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xff8A2D3B),
                  ),
                  child: Column(
                    children: [
                      // Bagian Motivasi
                      const Icon(Icons.star, size: 50, color: Colors.yellow),
                      const SizedBox(height: 12),
                      const Text(
                        "Tetap semangat hari ini!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Check In / Out Section
                      const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Sudah Absen Hari Ini?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Card Check In
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GoogleMapsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Check In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Card Check Out
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _showCheckOutDialog(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Check Out",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckOutDialog(BuildContext context) async {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id').format(now);

    // cek status check-out
    final checkOutData = await PreferenceHandler.getCheckOut();
    bool isCheckedOut = checkOutData.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                "Konfirmasi Check Out",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text("Jam: $formattedTime"),
              Text("Tanggal: $formattedDate"),
              const SizedBox(height: 16),
              const Text(
                "Apakah kamu yakin ingin Check Out sekarang?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // jika sudah check-out tampilkan container, kalau belum tampilkan slide
              isCheckedOut
                  ? Container(
                      width: double.infinity,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Sudah Check Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : SlideAction(
                      text: "Swipe untuk Check Out",
                      outerColor: Colors.redAccent,
                      innerColor: Colors.white,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmit: () async {
                        Navigator.pop(context); // tutup dialog

                        try {
                          // ambil lokasi user
                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          double lat = position.latitude;
                          double lng = position.longitude;
                          String location = "$lat, $lng";
                          String address =
                              "Lokasi saat ini"; // bisa diganti pakai geocoding

                          final result = await AbsensiAPI.checkOut(
                            checkOutLat: lat,
                            checkOutLng: lng,
                            checkOutLocation: location,
                            checkOutAddress: address,
                          );

                          // simpan status ke SharedPreferences
                          await PreferenceHandler.saveCheckOut(
                            formattedDate,
                            formattedTime,
                          );

                          if (result != null && result.message != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message!),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Check Out gagal, coba lagi."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }

                        return null;
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
