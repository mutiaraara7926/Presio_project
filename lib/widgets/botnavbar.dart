import 'package:absensi/view/history.dart';
import 'package:absensi/view/home.dart';
import 'package:absensi/view/profille.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';

class Botnavbar extends StatefulWidget {
  const Botnavbar({super.key});

  @override
  State<Botnavbar> createState() => _BotnavbarState();
}

class _BotnavbarState extends State<Botnavbar> {
  int currentIndex = 0;
  static const List<Widget> widgetOptions = <Widget>[
    HomePage(),
    HistoryPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: widgetOptions[currentIndex]),
      bottomNavigationBar: CrystalNavigationBar(
        currentIndex: currentIndex,
        height: 10,
        unselectedItemColor: Colors.black,
        // selectedItemColor: Color(0xff8A2D3B),
        // borderWidth: 1,
        outlineBorderColor: Color(0xff8A2D3B),
        backgroundColor: const Color.fromARGB(
          255,
          255,
          161,
          161,
        ).withValues(alpha: 0.5),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          CrystalNavigationBarItem(
            icon: Icons.home,
            unselectedIcon: Icons.home_outlined,
            selectedColor: Color(0xff8A2D3B),
            // badge: Badge(
            //   label: Text("Home", style: TextStyle(color: Colors.white)),
            // ),
          ),
          CrystalNavigationBarItem(
            icon: Icons.bar_chart,
            unselectedIcon: Icons.bar_chart_outlined,
            selectedColor: Color(0xff8A2D3B),
            // badge: Badge(
            //   label: Text("Home", style: TextStyle(color: Colors.white)),
            // ),
          ),
          CrystalNavigationBarItem(
            icon: Icons.person,
            unselectedIcon: Icons.person_outline,
            selectedColor: Color(0xff8A2D3B),
            // badge: Badge(
            //   label: Text("Home", style: TextStyle(color: Colors.white)),
            // ),
          ),
        ],
      ),
    );
  }
}
