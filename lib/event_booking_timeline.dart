library event_booking_timeline;

// import 'dart:math';
import 'package:event_booking_timeline/widget/horizontal_wheel_scroll_view.dart.dart';
import 'package:flutter/material.dart';

class Booking {
  final String startTime;
  final String endTime;

  Booking({required this.startTime, required this.endTime});
}

class EventBookingTimeline extends StatefulWidget {
  const EventBookingTimeline({
    super.key,
    required this.onTimeSelected,
    required this.startTime,
    required this.endTime,
    required this.numberOfSubdivision,
    required this.widthOfSegment,
    required this.widthOfTimeDivisionBar,
    required this.booked,
    required this.moveToFirstAvailableTime,
    required this.is12HourFormat,
    required this.availableColor,
    required this.bookedColor,
  });

  final Function(String time) onTimeSelected;
  final String startTime;
  final String endTime;

  final int numberOfSubdivision;
  final double widthOfSegment;
  final double widthOfTimeDivisionBar;
  final List<Booking> booked;
  final bool moveToFirstAvailableTime;
  final bool is12HourFormat;

  final Color availableColor;
  final Color bookedColor;

  @override
  State<EventBookingTimeline> createState() => _EventBookingTimelineState();
}

class _EventBookingTimelineState extends State<EventBookingTimeline> {
  late FixedExtentScrollController scrollController =
      FixedExtentScrollController(
    initialItem: 0,
  );

  Color bookedColor = Colors.red;
  Color availableColor = Colors.green;

  // int currentScale = 1;

  late List<Booking> booked;

  List<String> timeSegments = [];

  int currentIndex = 0;
  late int numberOfSubdivision;

  late double totalWidth;
  late double width;
  late double timeDivisionBarHeight;
  late bool is12HourFormat;

  double eventBarHeight = 8;

  @override
  void initState() {
    super.initState();

    width = widget.widthOfSegment;
    numberOfSubdivision = widget.numberOfSubdivision;
    totalWidth = (numberOfSubdivision + 1) * width;
    timeDivisionBarHeight = widget.widthOfTimeDivisionBar;
    timeSegments = getTimes();
    is12HourFormat = widget.is12HourFormat;

    bookedColor = widget.bookedColor;
    availableColor = widget.availableColor;

    booked = widget.booked;

    // finding first available slot
    int firstAvailableSlot = widget.moveToFirstAvailableTime
        ? getNextAvailableTime(0, timeSegments.length)
        : 0;

    scrollController =
        FixedExtentScrollController(initialItem: firstAvailableSlot);
  }

  List<String> getTimes() {
    List<String> timeStrings = [];

    String startTime = widget.startTime;
    String endTime = widget.endTime;

    int totalTime = int.parse(endTime.split(":")[0]) -
        int.parse(startTime.split(":")[0]) +
        1;

    int totalDivision = (totalTime * (widget.numberOfSubdivision + 1)) -
        widget.numberOfSubdivision;

    for (int i = 0; i < totalDivision; i++) {
      String time = startTime;
      timeStrings.add(time);

      int hour = int.parse(time.split(":")[0]);
      int minute = int.parse(time.split(":")[1]);

      int newMinute = minute + 60 ~/ (numberOfSubdivision + 1);

      if (newMinute >= 60) {
        hour += 1;
        minute = newMinute - 60;
      } else {
        minute = newMinute;
      }

      startTime =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    return timeStrings;
  }

  String getTimeText(String time) {
    int hour = int.parse(time.split(":")[0]);
    int minute = int.parse(time.split(":")[1]);

    String ampm = "AM";

    if (hour == 24) {
      ampm = "AM";
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
      ampm = "PM";
    } else if (hour == 12) {
      ampm = "PM";
    } else if (hour == 0) {
      hour = 12;
    }

    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm";
  }

  int getNextAvailableTime(int start, int end) {
    List<String> availableTimeSegments = [];

    for (int i = start; i < end; i++) {
      availableTimeSegments.add(timeSegments[i]);
    }

    for (int i = start; i < end; i++) {
      List<Booking> bookedTimes = booked;

      if (bookedTimes.isNotEmpty) {
        for (var element in bookedTimes) {
          // getting range of time between start and end time
          int startIndex = timeSegments.indexOf(element.startTime);
          int endIndex = timeSegments.indexOf(element.endTime);

          for (int i = startIndex; i < endIndex; i++) {
            availableTimeSegments.remove(timeSegments[i]);
          }
        }
      }
    }

    int firstAvailableSlot = timeSegments.indexOf(availableTimeSegments.first);

    setState(() {
      currentIndex = firstAvailableSlot;
    });

    return firstAvailableSlot;
  }

  int getBarHeight(int i) {
    // Checking if the time is the correctBar
    String time = timeSegments[i];

    if (time.split(":")[1] == "00") {
      return 20;
    } else {
      if (isAlternateBars(i)) {
        return 20;
      } else {
        return 15;
      }
    }
  }

  bool isAlternateBars(int i) {
    // Checking if the time is the correctBar
    String time = timeSegments[i];

    if (time.split(":")[1] == "00") {
      return true;
    } else {
      if (numberOfSubdivision % 2 == 0) {
        return false;
      } else {
        // Checking if the time is the alternate bar
        int minute = int.parse(time.split(":")[1]);

        for (int i = 1; i <= numberOfSubdivision; i++) {
          if (i % 2 == 0) {
            if (minute == (60 ~/ (numberOfSubdivision + 1)) * i) {
              return true;
            }
          }
        }

        return false;
      }
    }
  }

  Widget getTimeline(Color firstColor, Color secondColor, int i) {
    Widget timelineContainer;
    if (i == 0) {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: eventBarHeight,
            width: (width / 2) + 5,
            decoration: BoxDecoration(
              color: secondColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
          )
        ],
      );
    } else if (i == timeSegments.length - 1) {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: eventBarHeight,
            width: (width / 2) + 5,
            decoration: BoxDecoration(
              color: firstColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          )
        ],
      );
    } else {
      timelineContainer = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: eventBarHeight,
            width: (width / 2),
            color: firstColor,
          ),
          Container(
            height: eventBarHeight,
            width: (width / 2),
            color: secondColor,
          )
        ],
      );
    }
    Widget widget = SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          timelineContainer,
          Container(
            margin: const EdgeInsets.all(5),
            width: timeDivisionBarHeight,
            height: getBarHeight(i).toDouble(),
            decoration: BoxDecoration(
              color: i == currentIndex ? Colors.black : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Text(
            is12HourFormat ? getTimeText(timeSegments[i]) : timeSegments[i],
            style: TextStyle(
              fontWeight:
                  i == currentIndex ? FontWeight.bold : FontWeight.normal,
              color:
                  (timeSegments[i].split(":")[1] == "00") || isAlternateBars(i)
                      ? Colors.black
                      : Colors.transparent,
              fontSize: (timeSegments[i].split(":")[1] == "00") ||
                      (isAlternateBars(i))
                  ? 15
                  : 0,
            ),
          ),
        ],
      ),
    );

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timeList = [];

    Map<String, Widget> timeListMap = {};

    for (var element in booked) {
      String startTime = element.startTime;
      String endTime = element.endTime;

      int startIndex = timeSegments.indexOf(startTime);
      int endIndex = timeSegments.indexOf(endTime);

      for (int i = startIndex + 1; i < endIndex; i++) {
        timeListMap[timeSegments[i]] = getTimeline(bookedColor, bookedColor, i);
      }

      // Checking if start time is already end time of some other booking
      List<Booking> bookedTimes =
          booked.where((element) => element.endTime == startTime).toList();

      if (bookedTimes.isNotEmpty) {
        timeListMap[startTime] =
            getTimeline(bookedColor, bookedColor, startIndex);
      } else {
        timeListMap[startTime] =
            getTimeline(availableColor, bookedColor, startIndex);
      }

      // Checking if end time is already start time of some other booking
      bookedTimes =
          booked.where((element) => element.startTime == endTime).toList();

      if (bookedTimes.isNotEmpty) {
        timeListMap[endTime] = getTimeline(bookedColor, bookedColor, endIndex);
      } else {
        timeListMap[endTime] =
            getTimeline(bookedColor, availableColor, endIndex);
      }
    }

    timeList = timeSegments.map(
      (e) {
        if (timeListMap.containsKey(e)) {
          return timeListMap[e]!;
        } else {
          return getTimeline(
              availableColor, availableColor, timeSegments.indexOf(e));
        }
      },
    ).toList();

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        // Disabled zooming feature
        // onScaleUpdate: (details) {
        // setState(
        //   () {
        //     currentScale = details.scale.toInt();
        //     if (currentScale % 2 == 0) {
        //       return;
        //     }
        //     if (currentScale > 0) {
        //       numberOfSubdivision = min(5, currentScale);
        //     } else {
        //       numberOfSubdivision = 1;
        //     }
        //     totalWidth = (numberOfSubdivision + 1) * width;
        //     timeSegments = getTimes();

        //     widget.onTimeSelected(is24HourFormat ? getTimeText(timeSegments[i]) : timeSegments[i]);
        //   },
        // );
        // },
        child: HorizontalListWheelScrollView(
          controller: scrollController,
          physics: const FixedExtentScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemExtent: totalWidth / (numberOfSubdivision + 1),
          diameterRatio: 100,
          perspective: 0.01,
          onSelectedItemChanged: (index) {
            setState(() {
              currentIndex = index;
              widget.onTimeSelected(
                is12HourFormat
                    ? getTimeText(timeSegments[index])
                    : timeSegments[index],
              );
            });
          },
          children: timeList,
        ),
      ),
    );
  }
}
