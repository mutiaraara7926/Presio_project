import 'package:absensi/extensions/navigation.dart';
import 'package:absensi/shared_preference/shared_preference.dart';
import 'package:absensi/view/home.dart';
import 'package:absensi/view/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const id = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    isLogin();
  }

  void isLogin() async {
    bool? isLogin = await PreferenceHandler.getLogin();

    Future.delayed(Duration(seconds: 3)).then((value) async {
      print(isLogin);
      if (isLogin == true) {
        context.pushReplacementNamed(HomePage.id);
      } else {
        context.push(Login());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            SizedBox(height: 20),
            // Text("Welcome"),
          ],
        ),
      ),
    );
  }
}
