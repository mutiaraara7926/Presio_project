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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff8A2D3B),
        centerTitle: true,
        title: const Text(
          "Absensi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color.fromARGB(255, 238, 211, 211),
          ),
        ),
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16.0),
        //     child: Icon(Icons.add, color: Colors.black),
        //   ),
        // ],
        // leading: const Padding(
        //   padding: EdgeInsets.only(left: 16.0),
        //   child: Icon(Icons.menu, color: Colors.black),
        // ),
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
              boxShadow: [
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
                  datesBackgroundColor: const Color.fromARGB(
                    255,
                    255,
                    150,
                    150,
                  ),
                  datesBorderColor: const Color.fromARGB(255, 8, 5, 6),
                  datesTextColor: Colors.black,
                ),
              ),
              streakDatesProperties: DatesProperties(
                datesDecoration: DatesDecoration(
                  datesBorderRadius: 1000,
                  datesBackgroundColor: const Color.fromARGB(
                    255,
                    255,
                    129,
                    215,
                  ),
                  datesBorderColor: const Color.fromARGB(255, 8, 5, 6),
                  datesTextColor: Colors.black,
                ),
              ),
              dateSelectionMode: DatePickerSelectionMode.singleOrMultiple,
              startWeekday: WeekDay.monday,
              selectedDates: selectedDates,
              onCalendarViewDate: (DateTime calendarViewDate) {},
              onSelectedDates: (List<DateTime> value) {
                setState(() {
                  if (selectedDates.contains(value.first)) {
                    selectedDates.remove(value.first);
                  } else {
                    selectedDates.add(value.first);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            "Absensi hari ini",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff8A2D3B),
            ),
          ),
          const SizedBox(height: 12),

          // List Appointment langsung di sini
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Card 1
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Appointment",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Whopper",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            "Dr. Morris",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "3:00 p.m.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Card 2
                // Container(
                //   margin: const EdgeInsets.only(bottom: 16),
                //   padding: const EdgeInsets.symmetric(
                //     vertical: 16,
                //     horizontal: 20,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black12,
                //         blurRadius: 6,
                //         offset: Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: const [
                //           Text(
                //             "Appointment",
                //             style: TextStyle(color: Colors.grey, fontSize: 12),
                //           ),
                //           SizedBox(height: 4),
                //           Text(
                //             "Fitzy",
                //             style: TextStyle(
                //               fontWeight: FontWeight.bold,
                //               fontSize: 18,
                //             ),
                //           ),
                //         ],
                //       ),
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.end,
                //         children: const [
                //           Text(
                //             "Dr. Morris",
                //             style: TextStyle(color: Colors.grey, fontSize: 12),
                //           ),
                //           SizedBox(height: 4),
                //           Text(
                //             "3:30 p.m.",
                //             style: TextStyle(
                //               fontWeight: FontWeight.bold,
                //               color: Colors.deepOrange,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
