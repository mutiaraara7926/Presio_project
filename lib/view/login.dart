import 'package:absensi/api/authentic_api.dart';
import 'package:absensi/extensions/navigation.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/forgot_pass_page.dart';
import 'package:absensi/view/register.dart';
import 'package:absensi/widgets/botnavbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static const id = "/login";

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isVisibility = false;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final loginResponse = await AuthenticationAPI.loginUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        PreferenceHandler.saveToken(loginResponse.data?.token ?? '');
        context.pushReplacement(Botnavbar());
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Future<void> _saveUserName(String name) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("userName", name);
  // }

  // TODO: nanti aktifin kalau sudah ada API
  // void login() async { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    "assets/images/login.png",
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 50),
                // Judul Login
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Input Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Email",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Masukkan email anda",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email tidak boleh kosong";
                    }
                    if (!value.contains("@")) {
                      return "Email tidak valid";
                    }
                    if (!(value.endsWith("@gmail.com") ||
                        value.endsWith("@yahoo.com"))) {
                      return "Email tidak terdaftar";
                    }
                    if (RegExp('[A-Z]').hasMatch(value)) {
                      return "Email harus huruf kecil";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Password",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isVisibility,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.lock, color: Colors.black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isVisibility ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          isVisibility = !isVisibility;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password tidak boleh kosong";
                    }
                    if (value.length < 6) {
                      return "Password minimal 6 karakter";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff8A2D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Masuk",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // fontFamily: "StageGrotesk_Bold",
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "Belum punya akun? ",
                      style: TextStyle(
                        color: const Color.fromARGB(182, 100, 100, 106),

                        fontWeight: FontWeight.w400,
                      ),

                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(RegisterScreen());
                            },
                          text: " Daftar",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
