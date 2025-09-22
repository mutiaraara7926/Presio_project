import 'dart:io';

import 'package:absensi/api/history_api.dart';
import 'package:absensi/model/history_model.dart';
import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static const id = "/history";

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DateTime> selectedDates = [];
  bool isLoading = true;
  bool isPdfLoading = false; // Loading PDF
  DateTime? selectedDate;

  Datum? absenToday;
  List<Datum> historyData = [];

  String selectedFilter = "hari";

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final result = await HistoryService.getHistory();
      setState(() {
        historyData = result.data ?? [];
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

  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd-MM-yyyy").format(date);
  }

  Future<void> _createAndExportPdf() async {
    setState(() => isPdfLoading = true);
    try {
      final pdf = pw.Document();
      final headers = ['Tanggal', 'Check-in', 'Check-out'];

      final data = historyData.map((history) {
        return [
          formatDate(history.attendanceDate),
          history.checkInTime ?? '-',
          history.checkOutTime ?? '-',
        ];
      }).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Riwayat Absensi',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: headers,
                  data: data,
                  cellAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  border: pw.TableBorder.all(color: PdfColors.black),
                ),
              ],
            );
          },
        ),
      );

      // Request permission
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin penyimpanan ditolak")),
        );
        setState(() => isPdfLoading = false);
        return;
      }

      final downloadsPath = "/storage/emulated/0/Download";
      final file = File('$downloadsPath/riwayat_absen.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF berhasil disimpan di folder: $downloadsPath"),
        ),
      );

      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan file: $e")));
    }
    setState(() => isPdfLoading = false);
  }

  Future<void> _confirmAndExportPdf() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi PDF"),
        content: const Text(
          "Apakah kamu yakin ingin mengekspor riwayat absensi ke PDF?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Ya",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _createAndExportPdf();
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
        actions: [
          isPdfLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  onPressed: _confirmAndExportPdf,
                ),
        ],
      ),
      body: Column(
        children: [
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
                  datesBackgroundColor: Colors.grey,
                  datesBorderColor: Colors.black,
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
              selectedDatesProperties: DatesProperties(
                datesDecoration: DatesDecoration(
                  datesBorderRadius: 1000,
                  datesBackgroundColor: Colors.grey,
                  datesBorderColor: Colors.black,
                  datesTextColor: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: selectedFilter,
            underline: const SizedBox(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff8A2D3B),
              fontSize: 16,
            ),
            items: const [
              DropdownMenuItem(value: "hari", child: Text("Absensi Hari Ini")),
              DropdownMenuItem(
                value: "bulan",
                child: Text("Absensi Bulan Ini"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedFilter == "hari"
                ? (selectedDate == null
                      ? _buildTodayAbsen()
                      : _buildHistoryList())
                : _buildMonthlyReport(
                    DateTime.now().month,
                    DateTime.now().year,
                  ),
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

  Widget _buildMonthlyReport(int month, int year) {
    final monthlyData = historyData.where((item) {
      if (item.attendanceDate == null) return false;
      return item.attendanceDate!.month == month &&
          item.attendanceDate!.year == year;
    }).toList();

    if (monthlyData.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada data absensi bulan ini",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: monthlyData.length,
      itemBuilder: (context, index) {
        final absen = monthlyData[index];
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
