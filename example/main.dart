import 'dart:developer';

import 'package:event_booking_timeline/controller/timeline_controller.dart';
import 'package:event_booking_timeline/model/booking.dart';
import 'package:flutter/material.dart';
import 'package:event_booking_timeline/event_booking_timeline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.grey[200],
          height: 200,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
                width: 200,
              ),
              SizedBox(
                  height: 50, width: 200, child: Text("Selected Time: $text")),
              const Icon(
                Icons.arrow_drop_down,
                size: 30,
              ),
              // Normal Timeline with no current booking slot
              Expanded(
                child: EventBookingTimeline(
                  onTimeSelected: (time) {},
                  startTime: DateTime(2023, 10, 1, 00, 0),
                  endTime: DateTime(2023, 10, 2, 00, 00),
                  timeDivision: 5,
                  addBuffer: true,
                  autoMoveToFirstAvailableTime: true,
                  availableSlotColor: Colors.green,
                  bookedSlotColor: Colors.red,
                  barColor: Colors.grey,
                  bufferDuration: const Duration(hours: 1),
                  currentBlockedSlotColor: Colors.blue,
                  currentBookings: [
                    Booking(
                      startTime: DateTime(2023, 10, 1, 10, 0),
                      endTime: DateTime(2023, 10, 1, 11, 5),
                    ),
                    Booking(
                      startTime: DateTime(2023, 10, 1, 2, 0),
                      endTime: DateTime(2023, 10, 1, 3, 0),
                    ),
                    Booking(
                      startTime: DateTime(2023, 10, 1, 4, 0),
                      endTime: DateTime(2023, 10, 1, 5, 0),
                    ),
                    Booking(
                      startTime: DateTime(2023, 10, 1, 6, 0),
                      endTime: DateTime(2023, 10, 1, 7, 0),
                    ),
                  ],
                  durationToBlock: const Duration(hours: 1),
                  is12HourFormat: true,
                  moveToNextPrevSlot: true,
                  selectedBarColor: Colors.yellow,
                  onError: (error) {
                    log(error.toString());
                  },
                  onTimeLineEnd: () {
                    print("Time Line Ended");
                  },
                  showCurrentBlockedSlot: true,
                  timelineController: TimelineController(),
                  widthOfSegment: 100,
                  widthOfTimeDivisionBar: 20,
                  textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  selectedTextStyle: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  barLength: 15,
                  barThickness: 4,
                  timelineThickness: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
