import 'dart:convert';

import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DateTime> selectedDates = [];
  Map<String, dynamic>? absenData;
  List<dynamic> historyData = [];
  bool isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchAbsenToday();
  }

  Future<void> fetchAbsenToday() async {
    try {
      final response = await http.get(
        Uri.parse("https://appabsensi.mobileprojp.com/api/absen/today"),
        headers: {
          "Accept": "application/json",
          // tambahkan authorization jika diperlukan
          // "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          absenData = result['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetch absen today: $e");
    }
  }

  Future<void> fetchHistoryByDate(DateTime date) async {
    setState(() {
      isLoading = true;
      selectedDate = date;
    });

    try {
      // Format tanggal untuk API (YYYY-MM-DD)
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await http.get(
        Uri.parse(
          "https://appabsensi.mobileprojp.com/api/absen/history?date=$formattedDate",
        ),
        headers: {
          "Accept": "application/json",
          // "Authorization": "Bearer $token", // uncomment jika perlu auth
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          historyData = result['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          historyData = [];
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        historyData = [];
      });
      debugPrint("Error fetch history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff8A2D3B),
        centerTitle: true,
        title: const Text(
          "Absensi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color.fromARGB(255, 238, 211, 211),
          ),
        ),
      ),
      body: Column(
        children: [
          // Kalender
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 211, 211),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CleanCalendar(
              enableDenseViewForDates: true,
              enableDenseSplashForDates: true,
              datesForStreaks: const [],
              currentDateProperties: DatesProperties(
                datesDecoration: DatesDecoration(
                  datesBorderRadius: 1000,
                  datesBackgroundColor: Color.fromARGB(255, 255, 150, 150),
                  datesBorderColor: Color.fromARGB(255, 8, 5, 6),
                  datesTextColor: Colors.black,
                ),
              ),
              streakDatesProperties: DatesProperties(
                datesDecoration: DatesDecoration(
                  datesBorderRadius: 1000,
                  datesBackgroundColor: Color.fromARGB(255, 255, 129, 215),
                  datesBorderColor: Color.fromARGB(255, 8, 5, 6),
                  datesTextColor: Colors.black,
                ),
              ),
              dateSelectionMode: DatePickerSelectionMode.singleOrMultiple,
              startWeekday: WeekDay.monday,
              selectedDates: selectedDates,
              onCalendarViewDate: (DateTime calendarViewDate) {},
              onSelectedDates: (List<DateTime> value) {
                setState(() {
                  selectedDates = value;
                  if (value.isNotEmpty) {
                    fetchHistoryByDate(value.first);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 12),
          Text(
            selectedDate != null
                ? "Absensi tanggal ${DateFormat('dd MMMM yyyy').format(selectedDate!)}"
                : "Absensi hari ini",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff8A2D3B),
            ),
          ),
          const SizedBox(height: 12),

          // List Absensi
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedDate == null
                ? _buildTodayAbsen()
                : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAbsen() {
    return absenData == null
        ? const Center(
            child: Text(
              "Belum ada data absensi hari ini",
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAbsenCard(
                checkInTime: absenData?['check_in_time'],
                checkOutTime: absenData?['check_out_time'],
                checkInAddress: absenData?['check_in_address'],
                checkOutAddress: absenData?['check_out_address'],
              ),
            ],
          );
  }

  Widget _buildHistoryList() {
    return historyData.isEmpty
        ? const Center(
            child: Text(
              "Tidak ada data absensi untuk tanggal ini",
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              final absen = historyData[index];
              return _buildAbsenCard(
                checkInTime: absen['check_in_time'],
                checkOutTime: absen['check_out_time'],
                checkInAddress: absen['check_in_address'],
                checkOutAddress: absen['check_out_address'],
              );
            },
          );
  }

  Widget _buildAbsenCard({
    required String? checkInTime,
    required String? checkOutTime,
    required String? checkInAddress,
    required String? checkOutAddress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Check In",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                checkInTime ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                checkInAddress ?? "-",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Check Out",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                checkOutTime ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                checkOutAddress ?? "-",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
