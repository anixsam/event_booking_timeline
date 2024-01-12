import 'dart:developer';

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
              // Timeline with current booking slot
              Expanded(
                child: EventBookingTimeline.withCurrentBookingSlot(
                  booked: [
                    Booking(startTime: "00:00", endTime: "01:00"),
                    Booking(startTime: "01:00", endTime: "02:00"),
                    Booking(startTime: "08:00", endTime: "09:00"),
                  ],
                  startTime: "00:00",
                  endTime: "24:00",
                  is12HourFormat: true,
                  moveToFirstAvailableTime: false,
                  numberOfSubdivision: 5,
                  widthOfSegment: 100,
                  widthOfTimeDivisionBar: 3,
                  availableColor: Colors.green,
                  bookedColor: Colors.red,
                  moveToNextPrevSlot: true,
                  durationToBlock: 1,
                  showCurrentBlockedSlot: true,
                  currentBlockedColor: Colors.blue,
                  blockUntilCurrentTime: true,
                  onError: (error) {
                    log("Error: $error");
                  },
                  onTimeSelected: (String time) {
                    setState(
                      () {
                        text = time;
                      },
                    );
                  },
                  onTimeLineEnd: () {
                    log("TimeLine Ended");
                  },
                ),
              ),
              // Normal Timeline with no current booking slot
              Expanded(
                child: EventBookingTimeline(
                  booked: [
                    Booking(startTime: "00:00", endTime: "01:00"),
                    Booking(startTime: "01:00", endTime: "02:00"),
                    Booking(startTime: "08:00", endTime: "09:00"),
                  ],
                  startTime: "00:00",
                  endTime: "24:00",
                  is12HourFormat: true,
                  moveToFirstAvailableTime: false,
                  numberOfSubdivision: 5,
                  widthOfSegment: 100,
                  widthOfTimeDivisionBar: 3,
                  availableColor: Colors.green,
                  bookedColor: Colors.red,
                  moveToNextPrevSlot: true,
                  durationToBlock: 1,
                  blockUntilCurrentTime: true,
                  onError: (error) {
                    log("Error: $error");
                  },
                  onTimeSelected: (String time) {
                    setState(
                      () {
                        text = time;
                      },
                    );
                  },
                  onTimeLineEnd: () {
                    log("TimeLine Ended");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
