import 'package:absensi/view/history.dart';
import 'package:absensi/view/home.dart';
import 'package:absensi/view/login.dart';
import 'package:absensi/view/register.dart';
import 'package:absensi/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting("id_ID");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      debugShowMaterialGrid: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 3, 3),
        ),
      ),

      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
        '/history': (context) => const HistoryPage(),
      },

      home: const SplashScreen(),
    );
  }
}
