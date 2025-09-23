import 'dart:io';

import 'package:absensi/api/profile.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/edit_profille.dart';
import 'package:absensi/view/page_awal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  String? _networkImageUrl;
  bool isLoading = true;
  String? userName;

  // Base URL server untuk path relatif
  final String baseUrl = "https://appabsensi.mobileprojp.com";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Helper untuk bikin full URL foto
  String? _getFullPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    if (photo.startsWith("http")) {
      return photo;
    } else {
      final path = photo.startsWith('/') ? photo.substring(1) : photo;
      return "$baseUrl/$path";
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final name = await PreferenceHandler.getUserName();
      final profile = await ProfileAPI.getProfile();

      setState(() {
        userName = name;
        _networkImageUrl = _getFullPhotoUrl(profile.data?.profilePhoto);
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
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload ke server
      try {
        final result = await ProfileAPI.updateProfilePhoto(image: _image);
        _networkImageUrl = _getFullPhotoUrl(result.data?.profilePhoto);
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
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (_networkImageUrl != null
                          ? NetworkImage(_networkImageUrl!)
                          : null),
                child: (_image == null && _networkImageUrl == null)
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
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
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Tentang Aplikasi
                    Card(
                      color: Colors.red.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: Colors.black54,
                        ),
                        title: const Text("Tentang Aplikasi"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pengaturan Akun
                    Card(
                      color: Colors.red.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: Colors.black54,
                        ),
                        title: const Text("Pengaturan Akun"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout
                    Card(
                      color: Colors.red.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Color(0xff8A2D3B),
                        ),
                        title: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Color(0xff8A2D3B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Text(
                                "Konfirmasi Logout",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
