import 'package:absensi/api/profile.dart';
import 'package:absensi/model/get_profile.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/edit_profille.dart';
import 'package:absensi/view/page_awal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final GetUser? userData;
  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String? userName;
  GetUser? _user;
  // Base URL server untuk path relatif

  @override
  void initState() {
    super.initState();
    _user = widget.userData;
    _loadUserProfile();
  }

  // Helper untuk bikin full URL foto

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final name = await PreferenceHandler.getUserName();
      final profile = await ProfileAPI.getProfile();

      setState(() {
        userName = name;
        _user = profile;
        isLoading = false;
      });
    } catch (e) {
      print("Error load profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {});

      // Upload ke server
      try {
        setState(() {});
      } catch (e) {
        print("Error upload photo: $e");
      }
    }
  }

  Future<void> _logout() async {
    await PreferenceHandler.clearAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PageAwal()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8A2D3B),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Foto Profil
            ClipOval(
              child: SizedBox(
                width: 110, // lebar maksimum (adjust sesuai kebutuhan)
                height: 110, // tinggi maksimum
                child: (_user?.data?.profilePhotoUrl?.isNotEmpty ?? false)
                    ? Image.network(
                        _user!.data!.profilePhotoUrl!,
                        fit: BoxFit.cover, // supaya proporsional
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              isLoading
                  ? "Memuat data..."
                  : (userName ?? "Nama tidak tersedia"),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Tentang Aplikasi
                    Card(
                      color: Color(0xff8A2D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                "Tentang Aplikasi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff8A2D3B),
                                ),
                              ),
                              content: const Text(
                                "Aplikasi absensi ini tidak hanya memudahkan pengguna untuk melakukan "
                                "Check In dan Check Out berbasis lokasi secara real-time, tetapi juga menyediakan "
                                "fitur riwayat absensi yang menampilkan catatan harian secara lengkap. Selain itu, aplikasi "
                                "ini dilengkapi dengan fitur konversi absensi ke PDF, sehingga laporan kehadiran dapat disimpan "
                                "atau dibagikan dengan lebih mudah. Dengan tampilan sederhana, informatif, dan user-friendly, aplikasi "
                                "ini dirancang untuk membuat proses absensi menjadi lebih praktis, efisien, dan terdokumentasi dengan baik.",
                                textAlign: TextAlign.justify,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Tutup",
                                    style: TextStyle(color: Color(0xff8A2D3B)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Tentang Aplikasi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // kebijakan & privasi
                    Card(
                      color: Color(0xff8A2D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                "Kebijakan Aplikasi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff8A2D3B),
                                ),
                              ),
                              content: const SingleChildScrollView(
                                child: Text(
                                  "Aplikasi absensi ini mengumpulkan dan menyimpan data kehadiran "
                                  "hanya untuk keperluan pencatatan dan pelaporan. "
                                  "Data tidak akan dibagikan kepada pihak ketiga tanpa izin pengguna. "
                                  "Dengan menggunakan aplikasi ini, pengguna dianggap telah menyetujui "
                                  "kebijakan privasi dan aturan penggunaan yang berlaku.",
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    "Mengerti",
                                    style: TextStyle(
                                      color: Color(0xff8A2D3B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.policy, color: Colors.white, size: 40),
                              SizedBox(height: 10),
                              Text(
                                "Kebijakan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Pengaturan Akun
                    Card(
                      color: Color(0xff8A2D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                          _loadUserProfile();
                        },
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Pengaturan Akun",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Logout
                    Card(
                      color: Color(0xff8A2D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Text(
                                "Konfirmasi Logout",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff8A2D3B),
                                ),
                              ),
                              content: const Text(
                                "Apakah kamu yakin ingin keluar?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    "Tidak",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _logout();
                                  },
                                  child: const Text(
                                    "Ya",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, color: Colors.white, size: 40),
                              SizedBox(height: 10),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDefaultAvatar() {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          const Color(0xFF667eea).withOpacity(0.3),
          const Color(0xFF764ba2).withOpacity(0.3),
        ],
      ),
    ),
    child: const Icon(Icons.person, size: 32, color: Colors.white),
  );
}
