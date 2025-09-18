import 'package:absensi/api/profile.dart';
import 'package:absensi/model/get_profile.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/google_map.dart';
import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  "assets/images/Location.png",
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 50),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff8A2D3B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading
                          ? "Memuat data..."
                          : "Selamat ${_greeting()}, ${userName}!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff8A2D3B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today, size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Sudah Absen Hari Ini?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // pindah ke halaman CheckInPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GoogleMapsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Check In",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showCheckOutDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Check Out",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckOutDialog(BuildContext context) {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(now);
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id').format(now);

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
              SlideAction(
                text: "Swipe untuk Check Out",
                outerColor: Colors.redAccent,
                innerColor: Colors.white,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSubmit: () {
                  Navigator.pop(context);
                  print("Check Out berhasil!");
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
