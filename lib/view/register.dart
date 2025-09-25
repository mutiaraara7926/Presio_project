import 'dart:io';

import 'package:absensi/api/authentic_api.dart';
import 'package:absensi/extensions/navigation.dart';
import 'package:absensi/model/get_batch_model.dart';
import 'package:absensi/model/get_list_training_model.dart';
import 'package:absensi/model/register_model.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = "/login";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool hidePassword = true;
  bool isLoading = false;
  String? errorMessage;
  RegisterModel? user;

  String? selectedGender;
  Batches? selectedBatch;
  Datum? selectedTraining;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  List<String> genderList = ["L", "P"];
  List<Batches> batchList = [];
  List<Datum> trainingList = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      final batchResponse = await AuthenticationAPI.getListBatch();
      final trainingResponse = await AuthenticationAPI.getListTraining();
      setState(() {
        batchList = batchResponse.data ?? [];
        trainingList = trainingResponse.data ?? [];
      });
    } catch (e) {
      print("Error fetch dropdown: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal load data dropdown: $e")));
    }
  }

  Future<void> pickFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedFile = image;
    });
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }
    PreferenceHandlerAsli.saveToken(user?.data?.token.toString() ?? "");

    if (selectedGender == null ||
        selectedBatch == null ||
        selectedTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gender, batch, dan training")),
      );
      return;
    }
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil belum dipilih")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      RegisterModel result = await AuthenticationAPI.registerUser(
        name: name,
        email: email,
        password: pass,
        jenisKelamin: selectedGender!,
        profilePhoto: File(pickedFile!.path),
        batchId: selectedBatch!.id!,
        trainingId: selectedTraining!.id!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Register berhasil")),
      );
      context.pushNamed(Login.id);
    } catch (e) {
      setState(() => errorMessage = e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal daftar: $errorMessage")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff8A2D3B),
        automaticallyImplyLeading: false,
        title: Text(
          "Registrasi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 238, 211, 211),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: pickedFile != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(File(pickedFile!.path)),
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: pickFoto,
                  icon: Icon(Icons.camera_alt, color: Color(0xff8A2D3B)),
                  label: Text(
                    "Pilih Foto Profil",
                    style: TextStyle(color: Color(0xff8A2D3B), fontSize: 14),
                  ),
                ),
                SizedBox(height: 32),
                Text("Nama", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration("Masukkan Nama"),
                ),
                SizedBox(height: 16),
                Text("Email", style: TextStyle(fontSize: 16)),

                SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: _inputDecoration("Masukkan Email"),
                ),
                SizedBox(height: 16),

                Text("Password", style: TextStyle(fontSize: 16)),

                SizedBox(height: 10),
                TextField(
                  controller: passController,
                  obscureText: hidePassword,
                  decoration: _inputDecoration("Masukkan Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Row(
                  children: [
                    // Jenis Kelamin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jenis Kelamin", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedGender,
                            items: genderList
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedGender = val),
                            decoration: _inputDecoration("Pilih "),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pilih Batch", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<Batches>(
                            initialValue: selectedBatch,
                            items: batchList
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(b.batchKe ?? "Batch ${b.id}"),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedBatch = val),
                            decoration: _inputDecoration("Pilih Batch"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Text("Pilih Pelatihan", style: TextStyle(fontSize: 16)),

                SizedBox(height: 10),
                DropdownButtonFormField<Datum>(
                  initialValue: selectedTraining,
                  items: trainingList
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: SizedBox(
                            width: 220,
                            child: Text(
                              t.title ?? "Pelatihan ${t.id}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedTraining = val),
                  decoration: _inputDecoration("Pilih Pelatihan"),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8A2D3B),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : Text(
                          "Buat Akun",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "Sudah punya akun? ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),

                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(Login());
                            },
                          text: " Masuk",
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color.fromARGB(255, 11, 39, 164),
                            // fontFamily: "StageGrotesk_Bold",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
