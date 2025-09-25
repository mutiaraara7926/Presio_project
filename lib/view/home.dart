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
  GetUser? user;
  bool isLoading = true;
  String userName = "";
  String? errorMessage;
  String? checkOutTime;
  bool isCheckedOut = false;

  Future<void> _loadAbsenToday() async {
    final today = await AbsensiAPI.getAbsenToday();
    if (today != null && today.data != null) {
      setState(() {
        checkOutTime = today.data!.checkOutTime;
        isCheckedOut = today.data!.checkOutTime != null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAbsenToday();
  }

  void _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final userData = await ProfileAPI.getProfile();
      setState(() {
        user = userData;
        userName = userData.data?.name ?? "";
      });
      await PreferenceHandlerAsli.setUserName(userName);
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
      return "Pagi 🌞";
    } else if (hour < 17) {
      return "Siang 🌤️";
    } else {
      return "Malam 🌙";
    }
  }

  final List<String> _motivasi = [
    "Senin: Awali minggu dengan semangat baru 💪",
    "Selasa: Konsistensi kecil hari ini bawa hasil besar 📈",
    "Rabu: Fokus dan jangan lupa bersyukur 🙏",
    "Kamis: Sabar dan tekun adalah kunci sukses 🔑",
    "Jumat: Berikan yang terbaik sebelum beristirahat 🕌",
    "Sabtu: Gunakan waktumu dengan produktif ✨",
    "Minggu: Istirahatlah sejenak, recharge energi ⚡",
  ];

  String _getMotivasiHariIni() {
    final weekday = DateTime.now().weekday;
    return _motivasi[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ilustrasi header
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "assets/images/Location.png",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Greeting
              Text(
                isLoading
                    ? "Memuat data..."
                    : "Selamat ${_greeting()}, $userName!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8A2D3B),
                ),
              ),

              const SizedBox(height: 20),

              // Motivasi Card dengan gradient
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD32F2F), // Maroon soft
                        Color.fromARGB(255, 77, 27, 44), // Pink pastel
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 25,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star, size: 50, color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          _getMotivasiHariIni(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Card Check In / Out
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 77, 27, 44), // Maroon tua
                        Color(0xFFD32F2F), // Merah muda
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  child: Column(
                    children: [
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GoogleMapsScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Card Check Out
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _showCheckOutDialog(context);
                            },
                            child: const Text(
                              "Pulang",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                "Konfirmasi Pulang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text("Jam: $formattedTime"),
              Text("Tanggal: $formattedDate"),
              const SizedBox(height: 16),
              const Text(
                "Apakah kamu yakin ingin pulang sekarang?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

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
                        "Sudah Pulang",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : SlideAction(
                      text: "Geser",
                      outerColor: Colors.redAccent,
                      innerColor: Colors.white,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmit: () async {
                        Navigator.pop(context);

                        try {
                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          double lat = position.latitude;
                          double lng = position.longitude;
                          String location = "$lat, $lng";
                          String address = "Lokasi saat ini";

                          final result = await AbsensiAPI.checkOut(
                            checkOutLat: lat,
                            checkOutLng: lng,
                            checkOutLocation: location,
                            checkOutAddress: address,
                          );

                          if (result != null && result.message != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message!),
                                backgroundColor: Colors.green,
                              ),
                            );
                            await _loadAbsenToday();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Gagal, coba lagi."),
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
