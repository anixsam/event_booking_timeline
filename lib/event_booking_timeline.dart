library event_booking_timeline;

// import 'dart:math';

/// import necessary packages from files;
import 'package:event_booking_timeline/exceptions/exception.dart';
import 'package:event_booking_timeline/widget/horizontal_wheel_scroll_view.dart.dart';
import 'package:flutter/material.dart';

/// Booking class to store the start and end time of the booking
class Booking {
  /// Start time of the booking
  final String startTime;

  /// End time of the booking
  final String endTime;

  /// Constructor
  Booking({required this.startTime, required this.endTime});
}

// ignore: must_be_immutable
class EventBookingTimeline extends StatefulWidget {
  /// Constructor without current booking slot highlight feature
  EventBookingTimeline({
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
    required this.moveToNextPrevSlot,
    required this.onError,
    required this.onTimeLineEnd,
    required this.blockUntilCurrentTime,
    required this.durationToBlock,
    required this.selectedBarColor,
    required this.selectedTextColor,
    required this.textColor,
    required this.barColor,
  });

  /// Constructor with current booking slot highlight feature
  EventBookingTimeline.withCurrentBookingSlot({
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
    required this.moveToNextPrevSlot,
    required this.onError,
    required this.onTimeLineEnd,
    required this.blockUntilCurrentTime,
    required this.durationToBlock,
    required this.showCurrentBlockedSlot,
    required this.currentBlockedColor,
    required this.selectedBarColor,
    required this.selectedTextColor,
    required this.textColor,
    required this.barColor,
  });

  /// Callback function to get the selected time
  final Function(String time) onTimeSelected;

  /// Callback function to get the error - like if the next x hours are not available, etc
  final Function(dynamic error) onError;

  /// Callback function to get the end of the timeline - like if the timeline reaches the end of the day, etc
  final Function() onTimeLineEnd;

  /// Starting time of the timeline (24 Hour Format)
  final String startTime;

  /// Ending time of the timeline
  final String endTime;

  /// The number of subdivisions between the main divisions
  final int numberOfSubdivision;

  /// The width of each time segments
  final double widthOfSegment;

  /// The thickness of each division
  final double widthOfTimeDivisionBar;

  /// List of booked slots
  final List<Booking> booked;

  /// To move the timeline to the next available slot
  final bool moveToFirstAvailableTime;

  /// The time to be displayed on the timeline
  final bool is12HourFormat;

  /// Should the timeline skip the blocked slots
  final bool moveToNextPrevSlot;

  /// Whether the current blocked state should be shown or not.
  late bool showCurrentBlockedSlot;

  ///  Color to indicate available slot
  final Color availableColor;

  /// Color to indicate booked slot
  final Color bookedColor;

  /// Color to indicate current blocked slot
  late Color currentBlockedColor;

  /// Duration to block
  final double durationToBlock;

  /// State to block the timeline until the current time
  final bool blockUntilCurrentTime;

  /// Color of the current selected bar
  final Color selectedBarColor;

  /// Color of the current selected text
  final Color selectedTextColor;

  /// Color of the text
  final Color textColor;

  /// Color of the bar
  final Color barColor;

  @override
  State<EventBookingTimeline> createState() => _EventBookingTimelineState();
}

class _EventBookingTimelineState extends State<EventBookingTimeline> {
  /// Scrollcontroller for the timeline to scroll programmatically. [FixedExtentScrollController] is used to scroll to the exact item.
  late FixedExtentScrollController scrollController =
      FixedExtentScrollController(
    initialItem: 0,
  );

  /// Colors for the timeline
  Color bookedColor = Colors.red;
  Color availableColor = Colors.green;
  Color currentBlockedColor = Colors.yellow;

  // Colors of text and bar
  late Color selectedBarColor = Colors.black;
  late Color selectedTextColor = Colors.black;
  late Color textColor = Colors.grey;
  late Color barColor = Colors.grey;

  // int currentScale = 1;

  late List<Booking> booked;

  List<String> timeSegments = [];

  int currentIndex = 0;
  int prevIndex = -1;

  late int numberOfSubdivision;

  late double totalWidth;
  late double width;
  late double timeDivisionBarHeight;
  late bool is12HourFormat;

  double eventBarHeight = 8;

  @override
  void initState() {
    super.initState();

    // Initializing the timeline
    setState(() {
      width = widget.widthOfSegment;
      numberOfSubdivision = widget.numberOfSubdivision;
      totalWidth = (numberOfSubdivision + 1) * width;
      timeDivisionBarHeight = widget.widthOfTimeDivisionBar;
      timeSegments = getTimes();
      is12HourFormat = widget.is12HourFormat;

      bookedColor = widget.bookedColor;
      availableColor = widget.availableColor;
      currentBlockedColor = widget.currentBlockedColor;

      selectedBarColor = widget.selectedBarColor;
      selectedTextColor = widget.selectedTextColor;
      textColor = widget.textColor;
      barColor = widget.barColor;

      booked = widget.booked;
    });

    if (widget.blockUntilCurrentTime) {
      blockUntilCurrentTime();
    }

    // finding first available slot
    int firstAvailableSlot = widget.booked.isEmpty
        ? 0
        : widget.moveToFirstAvailableTime
            ? getNextAvailableTime(0, timeSegments.length)
            : 0;

    setState(() {
      currentIndex = firstAvailableSlot;
    });

    scrollController =
        FixedExtentScrollController(initialItem: firstAvailableSlot);
  }

  /// Blocking the timeline until the current time
  void blockUntilCurrentTime() {
    DateTime now = DateTime.now();
    // Round off to nearest hour according to the numberOfSubdivision
    int hour = now.hour;

    int minute = now.minute;

    int maxMinutes = 60;

    if ((minute).toInt() > (maxMinutes ~/ (numberOfSubdivision + 1))) {
      minute = 0;
      if (hour == 23) {
        hour = 0;
      } else {
        hour += 1;
      }
    } else {
      minute = 30;
    }

    String time =
        "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

    // Checking if booking containes the time in between the start and current time

    List<Booking> bookingList = booked;

    if (bookingList.isNotEmpty) {
      bookingList = bookingList.map((e) {
        String startTime = e.startTime;

        String endTime = e.endTime;

        if (timeSegments.indexOf(startTime) < timeSegments.indexOf(time)) {
          startTime = time;
        }

        if (timeSegments.indexOf(endTime) > timeSegments.indexOf(time)) {
          endTime = time;
        }

        return Booking(startTime: startTime, endTime: e.endTime);
      }).toList();

      booked = bookingList;
    }
    // Adding to booking
    booked.add(Booking(startTime: timeSegments.first, endTime: time));
  }

  /// Getting the list of time segments.
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

  /// Generating the text time according to the format.
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

  /// Getting the next available slot
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

    return firstAvailableSlot;
  }

  /// Moving to the next/previous available slot according to scroll direction
  void jumpToNextPrevSlot() {
    // finding first available slot
    int firstAvailableSlot =
        getNextAvailableTime(currentIndex, timeSegments.length);
    int prevAvailableSlot = getPrevAvailableTime(0, currentIndex);

    // Checking scroll direction
    if (currentIndex > prevIndex) {
      if (currentIndex != firstAvailableSlot) {
        widget.onTimeSelected(getTimeText(timeSegments[firstAvailableSlot]));
        scrollController.jumpToItem(firstAvailableSlot);
        setState(() {
          currentIndex = firstAvailableSlot;
        });
      }
    } else {
      if (currentIndex != prevAvailableSlot) {
        widget.onTimeSelected(getTimeText(timeSegments[prevAvailableSlot]));
        scrollController.jumpToItem(prevAvailableSlot);
        setState(() {
          currentIndex = prevAvailableSlot;
        });
      }
    }
  }

  /// Getting the previous available slot
  int getPrevAvailableTime(int start, int end) {
    List<String> availableTimeSegments = [];

    for (int i = start; i <= end; i++) {
      availableTimeSegments.add(timeSegments[i]);
    }

    for (int i = start; i < end; i++) {
      List<Booking> bookedTimes = booked;
      if (bookedTimes.isNotEmpty) {
        for (var element in bookedTimes) {
          // getting range of time between start and end time
          int startIndex = timeSegments.indexOf(element.startTime);
          int endIndex = timeSegments.indexOf(element.endTime);

          for (int i = startIndex + 1; i <= endIndex; i++) {
            availableTimeSegments.remove(timeSegments[i]);
          }
        }
      }
    }
    int lastAvailableSlot = timeSegments.indexOf(availableTimeSegments.last);

    return lastAvailableSlot;
  }

  /// Getting the height of the bar - Timeline bars.
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

  /// Checking if the time is the alternate bar
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

  /// Getting the timeline bar - Widget
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
              color: i == currentIndex ? selectedBarColor : barColor,
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
                      ? i == currentIndex
                          ? selectedTextColor
                          : textColor
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

  /// Checking if the next x hours are booked or not
  bool checkIfNextXDurationBooked() {
    int startIndex = currentIndex;

    String endTime = calculateEndTimeWithDuration();

    int endIndex = timeSegments.indexOf(endTime);

    List<String> availableTimeSegments = [];

    for (int i = startIndex; i <= endIndex; i++) {
      availableTimeSegments.add(timeSegments[i]);
    }

    int numberOfSlots = availableTimeSegments.length;

    for (int i = startIndex; i < endIndex; i++) {
      List<Booking> bookingList = booked;

      if (bookingList.isNotEmpty) {
        for (var element in bookingList) {
          // getting range of time between start and end time
          int startIndex = timeSegments.indexOf(element.startTime);
          int endIndex = timeSegments.indexOf(element.endTime);

          for (int i = startIndex + 1; i < endIndex; i++) {
            availableTimeSegments.remove(timeSegments[i]);
          }
        }
      }
    }

    if (availableTimeSegments.length < numberOfSlots ||
        availableTimeSegments.isEmpty) {
      return true;
    }

    return false;
  }

  /// Calculating the end time with the duration
  String calculateEndTimeWithDuration() {
    int startIndex = currentIndex;

    String startTime = timeSegments[startIndex];

    String endTime = "";

    if (int.parse(widget.durationToBlock.toString().split(".")[1]) == 0) {
      int hour =
          int.parse(startTime.split(":")[0]) + widget.durationToBlock.toInt();
      int minute = int.parse(startTime.split(":")[1]);

      endTime =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } else {
      int hour =
          int.parse(startTime.split(":")[0]) + widget.durationToBlock.toInt();
      int minute = int.parse(startTime.split(":")[1]);

      int newMinute = minute + 60 ~/ (numberOfSubdivision + 1);

      if (newMinute >= 60) {
        hour += 1;
        minute = newMinute - 60;
      } else {
        minute = newMinute;
      }

      endTime =
          "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }

    return endTime;
  }

  /// Error callback to the parent widget.
  void errorCallback() {
    widget.onError(
      DurationException(
        "Next ${widget.durationToBlock} hours are not available",
      ),
    );
  }

  /// Callback to detect the end of timeLine and user can either reset the timeline or show the error.
  void timeLineEndCallback() {
    widget.onTimeLineEnd();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timeList = [];

    Map<String, Widget> timeListMap = {};

    timeSegments = getTimes();

    timeList = timeSegments.map(
      (e) {
        if (timeListMap.containsKey(e)) {
          return timeListMap[e]!;
        } else {
          return getTimeline(
            availableColor,
            availableColor,
            timeSegments.indexOf(e),
          );
        }
      },
    ).toList();

    if (widget.booked != booked) {
      booked = widget.booked;
    }

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

    if (widget.showCurrentBlockedSlot) {
      if (!checkIfNextXDurationBooked()) {
        String startTime = timeSegments[currentIndex];
        String endTime = calculateEndTimeWithDuration();

        int startIndex = timeSegments.indexOf(startTime);
        int endIndex = timeSegments.indexOf(endTime);

        for (int i = startIndex + 1; i < endIndex; i++) {
          timeListMap[timeSegments[i]] =
              getTimeline(currentBlockedColor, currentBlockedColor, i);
        }

        // Checking if start time is already end time of some other booking
        List<Booking> bookedTimes =
            booked.where((element) => element.endTime == startTime).toList();

        if (bookedTimes.isNotEmpty) {
          timeListMap[startTime] =
              getTimeline(bookedColor, currentBlockedColor, startIndex);
        } else {
          timeListMap[startTime] =
              getTimeline(availableColor, currentBlockedColor, startIndex);
        }

        // Checking if end time is already start time of some other booking

        bookedTimes =
            booked.where((element) => element.startTime == endTime).toList();

        if (bookedTimes.isNotEmpty) {
          timeListMap[endTime] =
              getTimeline(currentBlockedColor, bookedColor, endIndex);
        } else {
          timeListMap[endTime] =
              getTimeline(currentBlockedColor, availableColor, endIndex);
        }
      }
    }

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
              if (prevIndex != currentIndex) {
                prevIndex = currentIndex;
                currentIndex = index;
              }
              if (currentIndex == timeSegments.length - 1) {
                timeLineEndCallback();
                return;
              }
              if (widget.moveToNextPrevSlot) {
                jumpToNextPrevSlot();
              }
              widget.onTimeSelected(getTimeText(timeSegments[currentIndex]));
              final bool isBooked = checkIfNextXDurationBooked();
              if (isBooked) {
                errorCallback();
              }
            });
          },
          children: timeList,
        ),
      ),
    );
  }
}
