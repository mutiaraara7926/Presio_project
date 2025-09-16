import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DateTime> selectedDates = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff8A2D3B),
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Absensi",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CleanCalendar(
              enableDenseViewForDates: true,
              enableDenseSplashForDates: true,
              datesForStreaks: [
                DateTime(2023, 01, 5),
                DateTime(2023, 01, 6),
                DateTime(2023, 01, 7),
                DateTime(2023, 01, 9),
                DateTime(2023, 01, 10),
                DateTime(2023, 01, 11),
                DateTime(2023, 01, 13),
                DateTime(2023, 01, 20),
                DateTime(2023, 01, 21),
                DateTime(2023, 01, 23),
                DateTime(2023, 01, 24),
                DateTime(2023, 01, 25),
              ],
              currentDateProperties: DatesProperties(
                datesDecoration: DatesDecoration(
                  datesBorderRadius: 1000,
                  datesBackgroundColor: Colors.lightGreen.shade100,
                  datesBorderColor: Colors.green,
                  datesTextColor: Colors.black,
                ),
              ),

              streakDatesProperties: DatesProperties(
                datesDecoration: DatesDecoration(
                  datesBorderRadius: 1000,
                  datesBackgroundColor: Colors.green,
                  datesBorderColor: Colors.blue,
                  datesTextColor: Colors.white,
                ),
              ),
              dateSelectionMode: DatePickerSelectionMode.singleOrMultiple,
              startWeekday: WeekDay.wednesday,
              selectedDates: selectedDates,
              onCalendarViewDate: (DateTime calendarViewDate) {
                // print(calendarViewDate);
              },
              onSelectedDates: (List<DateTime> value) {
                setState(() {
                  if (selectedDates.contains(value.first)) {
                    selectedDates.remove(value.first);
                  } else {
                    selectedDates.add(value.first);
                  }
                });
                // print(selectedDates);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
