import 'package:absensi/api/authentic_api.dart';
import 'package:absensi/model/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String otpCode = "";
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    final password = passwordController.text.trim();

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP harus 6 digit")));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru tidak boleh kosong")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final ResetPasswordModel result = await AuthenticationAPI.resetPassword(
        email: widget.email,
        otp: otpCode,
        password: password,
        passwordConfirmation: password,
      );

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Password berhasil diubah")),
      );

      Navigator.pop(context); // Kembali ke halaman login
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verifikasi OTP",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: 180,
                child: Image.asset("assets/images/forgot.png"),
              ),
              const SizedBox(height: 30),
              OtpTextField(
                numberOfFields: 6,
                borderRadius: BorderRadius.circular(8),
                borderWidth: 2,
                focusedBorderColor: const Color(0xff8A2D3B),
                cursorColor: const Color(0xff8A2D3B),
                showFieldAsBox: true,
                onSubmit: (String verificationCode) {
                  otpCode = verificationCode;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Masukkan password baru",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8A2D3B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Konfirmasi",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
