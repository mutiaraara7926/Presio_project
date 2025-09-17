import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff8A2D3B),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Back button
            // Row(
            //   children: [
            //     IconButton(
            //       icon: const Icon(Icons.arrow_back, color: Colors.black54),
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //     ),
            //   ],
            // ),
            const SizedBox(height: 10),

            // Foto Profil
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 15),

            // Nama
            const Text(
              "Stephanie Milton",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 238, 211, 211),
              ),
            ),

            const SizedBox(height: 6),

            // Badge Favorite
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: Color.fromARGB(255, 238, 211, 211),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: const Text(
            //     "Favorite",
            //     style: TextStyle(
            //       color: Color(0xff8A2D3B),
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 30),

            // List menu
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
                    SizedBox(height: 20),
                    _buildMenuItem(
                      Icons.chat_bubble_outline,
                      "Start a chat",
                      onTap: () {},
                    ),
                    SizedBox(height: 20),
                    _buildMenuItem(
                      Icons.person_outline,
                      "Expert replies",
                      onTap: () {},
                    ),
                    SizedBox(height: 20),
                    _buildMenuItem(
                      Icons.star_border,
                      "Review ratings",
                      onTap: () {},
                    ),
                    SizedBox(height: 20),
                    _buildMenuItem(
                      Icons.help_outline,
                      "Asked questions",
                      onTap: () {},
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

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
