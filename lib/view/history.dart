import 'package:absensi/api/history_api.dart';
import 'package:absensi/model/history_model.dart';
import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static const id = "/history";

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DateTime> selectedDates = [];
  bool isLoading = true;
  DateTime? selectedDate;

  // pakai model Datum
  Datum? absenToday;
  List<Datum> historyData = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final result =
          await HistoryService.getHistory(); // return HistoryAbsenModel
      setState(() {
        historyData = result.data ?? [];
        // cari data absensi hari ini
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        absenToday = historyData.firstWhere(
          (item) =>
              DateFormat('yyyy-MM-dd').format(item.attendanceDate!) == today,
          orElse: () => Datum(),
        );
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch history: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchHistoryByDate(DateTime date) async {
    setState(() {
      isLoading = true;
      selectedDate = date;
    });
    try {
      final result = await HistoryService.getHistory();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      setState(() {
        historyData = (result.data ?? [])
            .where(
              (item) =>
                  DateFormat('yyyy-MM-dd').format(item.attendanceDate!) ==
                  formattedDate,
            )
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch history by date: $e");
      setState(() {
        historyData = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              onSelectedDates: (List<DateTime> value) {
                setState(() => selectedDates = value);
                if (value.isNotEmpty) {
                  _fetchHistoryByDate(value.first);
                }
              },
            ),
          ),

          const SizedBox(height: 12),
          Text(
            selectedDate != null
                ? "Absensi tanggal ${DateFormat('dd MMMM yyyy').format(selectedDate!)}"
                : "Absensi hari ini",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff8A2D3B),
            ),
          ),
          const SizedBox(height: 12),

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
    return absenToday == null || absenToday!.id == null
        ? const Center(
            child: Text(
              "Belum ada data absensi hari ini",
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [_buildAbsenCard(absenToday!)],
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
              return _buildAbsenCard(absen);
            },
          );
  }

  Widget _buildAbsenCard(Datum absen) {
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
          // check in
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Check In",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                absen.checkInTime ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                absen.checkInAddress ?? "-",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          // check out
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Check Out",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                absen.checkOutTime ?? "-",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                absen.checkOutAddress ?? "-",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
