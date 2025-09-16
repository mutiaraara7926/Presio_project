import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const id = "/register";

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController trainingController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedTraining;
  bool isLoading = false;
  String? errorMessage;

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email, Password, dan Nama tidak boleh kosong"),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    // try{
    //   final result = await AuthenticationAPI.registerUser(
    //     email: email,
    //     password: password,
    //     name: name,
    //   );
    //   setState(() {
    //     User = result;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //      SnackBar(content: Text("Pendaftaran berhasil! Silakan login.")),
    //   );
    //   print(User?.toJson());
    // }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Judul
              const Text(
                "Daftar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xff8A2D3B),
                ),
              ),
              const SizedBox(height: 32),

              // Nama
              _buildLabel("Nama"),
              _buildTextField(
                controller: nameController,
                hint: "Masukkan nama lengkap",
              ),

              const SizedBox(height: 20),

              // Email
              _buildLabel("Email"),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Masukkan email anda"),
                ),
              ),
              const SizedBox(height: 20),

              // Training
              _buildLabel("Training"),
              DropdownButtonFormField<String>(
                initialValue: selectedTraining,
                decoration: _inputDecoration("Pilih Training"),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: "Mobile Programming",
                    child: Text("Mobile Programming"),
                  ),
                  DropdownMenuItem(
                    value: "Web Programming",
                    child: Text("Web Programming"),
                  ),
                  DropdownMenuItem(
                    value: "Perhotelan",
                    child: Text("Perhotelan"),
                  ),
                  DropdownMenuItem(
                    value: "Tata Boga",
                    child: Text("Tata Boga"),
                  ),
                  DropdownMenuItem(
                    value: "Content Creator",
                    child: Text("Content Creator"),
                  ),
                  DropdownMenuItem(
                    value: "Make Up Artist",
                    child: Text("Make Up Artist"),
                  ),
                  DropdownMenuItem(
                    value: "Multi Media",
                    child: Text("Multi Media"),
                  ),
                  DropdownMenuItem(
                    value: "Design Grafis Madya",
                    child: Text("Design Grafis Madya"),
                  ),
                  DropdownMenuItem(
                    value: "Data Manajemen Staff",
                    child: Text("Data Manajemen Staff"),
                  ),
                  DropdownMenuItem(
                    value: "Akuntansi Junior",
                    child: Text("Akuntansi Junior"),
                  ),
                  DropdownMenuItem(value: "Barista", child: Text("Barista")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTraining = value;
                    trainingController.text = value ?? "";
                  });
                },
              ),
              const SizedBox(height: 20),

              // Batch
              _buildLabel("Batch"),
              _buildTextField(controller: batchController, hint: "Batch"),
              const SizedBox(height: 20),

              // Password
              _buildLabel("Buat Password"),
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: _inputDecoration("Masukkan password anda").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password wajib diisi";
                  }
                  if (value.length < 6) {
                    return "Password minimal 6 karakter";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _buildLabel("Konfirmasi Password"),
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: _inputDecoration("Masukkan password anda").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password wajib diisi";
                  }
                  if (value != passwordController.text) {
                    return "Password tidak cocok";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8A2D3B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await registerUser();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // === Helper Widget ===
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xff8A2D3B),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: Colors.grey.shade300,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
    );
  }
}
