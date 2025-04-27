library event_booking_timeline;

import 'package:event_booking_timeline/controller/timeline_controller.dart';
import 'package:event_booking_timeline/error_codes.dart';
import 'package:event_booking_timeline/exceptions/exception.dart';
import 'package:event_booking_timeline/model/booking.dart';
import 'package:event_booking_timeline/model/timeslot.dart';
import 'package:event_booking_timeline/widget/horizontal_wheel_scroll_view.dart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventBookingTimeline extends StatefulWidget {
  /// [timelineController] is the controller for the timeline
  final TimelineController timelineController;

  /// The start time of the timeline
  final DateTime startTime;

  /// The end time of the timeline
  final DateTime endTime;

  /// The time division in minutes
  final int timeDivision;

  /// Width of a time segment
  final double widthOfSegment;

  /// Width of the time division bar
  final double widthOfTimeDivisionBar;

  /// List of currently booked slots
  /// [Booking] is a model class that contains start and end time of the booking
  /// e.g. Booking(startTime: "00:00", endTime: "01:00")
  final List<Booking> currentBookings;

  /// Colors
  /// [bookedSlotColor] is the color of the booked time slots
  /// [availableSlotColor] is the color of the available time slots
  /// [currentBlockedSlotColor] is the color of the current blocked time slots
  /// [selectedBarColor] is the color of the selected time slot
  /// [barColor] is the color of the time division bar

  final Color availableSlotColor;
  final Color bookedSlotColor;
  final Color currentBlockedSlotColor;
  final Color selectedBarColor;
  final Color barColor;

  /// [autoMoveToFirstAvailableTime] is a boolean value that indicates whether to move to the first available time slot
  /// [moveToNextPrevSlot] is a boolean value that indicates whether to move to the next or previous slot
  /// [is12HourFormat] is a boolean value that indicates whether to use 12 hour format or not
  /// [showCurrentBlockedSlot] is a boolean value that indicates whether to show the current blocked time slots
  /// [durationToBlock] is the duration to block the time slots
  /// [addBuffer] is a boolean value that indicates whether to add buffer time or not
  /// [bufferDuration] is the duration of the buffer time

  final bool autoMoveToFirstAvailableTime;
  final bool moveToNextPrevSlot;
  final bool is12HourFormat;
  final bool showCurrentBlockedSlot;

  final Duration durationToBlock;

  final bool addBuffer;

  final Duration? bufferDuration;

  /// [textStyle] is the text style of the time slots
  /// [selectedTextStyle] is the text style of the selected time slot
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;

  /// [barThickness] is the thickness of the time division bar
  /// [barLength] is the length of the time division bar
  /// [timelineThickness] is the thickness of the timeline

  final double barThickness;
  final double barLength;
  final double timelineThickness;

  final void Function(dynamic error)? onError;
  final void Function()? onTimelineEnd;
  final void Function(DateTime time)? onTimeSelected;

  EventBookingTimeline({
    super.key,
    required this.timelineController,
    required this.startTime,
    required this.endTime,
    required this.timeDivision,
    required this.widthOfSegment,
    required this.widthOfTimeDivisionBar,
    required this.currentBookings,
    required this.availableSlotColor,
    required this.bookedSlotColor,
    required this.currentBlockedSlotColor,
    required this.selectedBarColor,
    required this.barColor,
    required this.autoMoveToFirstAvailableTime,
    required this.moveToNextPrevSlot,
    required this.is12HourFormat,
    required this.showCurrentBlockedSlot,
    required this.durationToBlock,
    required this.addBuffer,
    required this.bufferDuration,
    required this.textStyle,
    required this.selectedTextStyle,
    required this.barThickness,
    required this.barLength,
    required this.timelineThickness,
    this.onError,
    this.onTimelineEnd,
    this.onTimeSelected,
    required Null Function() onTimeLineEnd,
  })  : assert(
          addBuffer == true ? bufferDuration != null : true,
          "Buffer duration cannot be null if addBuffer is true",
        ),
        assert(
          startTime.isBefore(endTime),
          "Start time must be before end time",
        ),
        assert(timeDivision > 0, "Time division must be greater than 0"),
        assert(widthOfSegment > 0, "Width of segment must be greater than 0"),
        assert(
          widthOfTimeDivisionBar > 0,
          "Width of time division bar must be greater than 0",
        );

  @override
  State<EventBookingTimeline> createState() => _EventBookingTimelineState();
}

class _EventBookingTimelineState extends State<EventBookingTimeline> {
  late FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: 0);
  List<Timeslot> timeslots = [];
  List<String> times = [];

  List<Booking> bookedSlots = [];

  double totalWidth = 0.0;

  late DateTime startTime;
  late DateTime endTime;

  int currentIndex = 0;
  int prevIndex = -1;

  @override
  void initState() {
    super.initState();

    setState(() {
      startTime = widget.startTime;
      endTime = widget.endTime;
    });

    _init();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void didUpdateWidget(covariant EventBookingTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _init() {
    _getBookingSlots();
    _getTimeSlots();

    widget.timelineController.registerOnJump((DateTime time) {
      int index = times.indexOf(
        widget.is12HourFormat
            ? DateFormat("hh:mm a").format(time)
            : "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
      );

      if (index != -1) {
        scrollController.jumpToItem(index);
      }
    });

    totalWidth = widget.timeDivision * widget.widthOfSegment;
  }

  void _getBookingSlots() {
    for (int i = 0; i < widget.currentBookings.length; i++) {
      Booking booking = widget.currentBookings[i];

      DateTime startTime = booking.startTime;
      DateTime endTime = booking.endTime;

      if (widget.addBuffer) {
        startTime = startTime.subtract(widget.bufferDuration!);
        endTime = endTime.add(widget.bufferDuration!);
      }

      bookedSlots.add(Booking(startTime: startTime, endTime: endTime));
    }
  }

  bool _ifSlotisBooked(String startTime, String endTime) {
    for (int i = 0; i < widget.currentBookings.length; i++) {
      String bookedStartTime = widget.is12HourFormat
          ? DateFormat(
              "hh:mm a",
            ).format(widget.currentBookings[i].startTime)
          : DateFormat('HH:mm').format(widget.currentBookings[i].startTime);
      String bookedEndTime = widget.is12HourFormat
          ? DateFormat("hh:mm a").format(widget.currentBookings[i].endTime)
          : DateFormat('HH:mm').format(widget.currentBookings[i].endTime);

      if (startTime == bookedStartTime && endTime == bookedEndTime) {
        return true;
      } else {
        DateTime start = DateFormat("hh:mm a").parse(startTime);
        DateTime end = DateFormat("hh:mm a").parse(endTime);
        DateTime bookedStart = DateFormat("hh:mm a").parse(bookedStartTime);
        DateTime bookedEnd = DateFormat("hh:mm a").parse(bookedEndTime);

        if ((start.isAfter(bookedStart) && start.isBefore(bookedEnd)) ||
            (end.isAfter(bookedStart) && end.isBefore(bookedEnd))) {
          return true;
        }
      }
    }
    return false;
  }

  int _roundToNearestMultiple(int value, int multiple) {
    if (multiple == 0) return value; // avoid division by zero
    return ((value + multiple ~/ 2) ~/ multiple) * multiple;
  }

  List<String> _generateTimeSlots({
    required DateTime startTime,
    required DateTime endTime,
    required int stepMinutes,
  }) {
    List<String> slots = [];
    DateTime current = startTime;

    while (current.isBefore(endTime) || current.isAtSameMomentAs(endTime)) {
      slots.add(
        DateFormat(widget.is12HourFormat ? 'hh:mm a' : 'HH:mm').format(current),
      );
      current = current.add(Duration(minutes: stepMinutes));
    }

    return slots;
  }

  void _getTimeSlots() {
    if (startTime.minute % widget.timeDivision != 0) {
      int roundedMinute = _roundToNearestMultiple(
        startTime.minute,
        widget.timeDivision,
      );
      if (roundedMinute == 60) {
        startTime = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          startTime.hour == 23 ? 0 : startTime.hour + 1,
          0,
        );
      } else {
        startTime = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          startTime.hour,
          roundedMinute,
        );
      }
    }

    if (endTime.minute % widget.timeDivision != 0) {
      int roundedMinute = _roundToNearestMultiple(
        endTime.minute,
        widget.timeDivision,
      );

      if (roundedMinute == 60) {
        endTime = DateTime(
          endTime.year,
          endTime.month,
          endTime.hour == 23 ? endTime.day + 1 : endTime.day,
          endTime.hour == 23 ? 0 : endTime.hour + 1,
          0,
        );
      } else {
        endTime = DateTime(
          endTime.year,
          endTime.month,
          endTime.day,
          endTime.hour,
          roundedMinute,
        );
      }
    }

    if (startTime.hour == 0 &&
        startTime.hour == endTime.hour &&
        startTime.minute == 0 &&
        startTime.minute == endTime.minute) {
      times = _generateTimeSlots(
        startTime: DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          0,
          0,
        ),
        endTime: DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          23,
          59,
        ),
        stepMinutes: widget.timeDivision,
      );

      times.add(
        widget.is12HourFormat
            ? DateFormat("hh:mm a").format(endTime)
            : "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
      );
    } else {
      times = _generateTimeSlots(
        startTime: startTime,
        endTime: endTime,
        stepMinutes: widget.timeDivision,
      );
    }

    for (int i = 0; i < times.length; i++) {
      if (i != 0) {
        String startTimeString = times[i - 1];
        String endTimeString = times[i];

        bool isBooked = _ifSlotisBooked(startTimeString, endTimeString);

        Timeslot timeslot = Timeslot(
          start: startTimeString,
          end: endTimeString,
          isBooked: isBooked,
        );

        if (!(timeslots.any(
          (element) =>
              element.start == timeslot.start && element.end == timeslot.end,
        ))) {
          timeslots.add(timeslot);
        }
      }

      if (i != times.length - 1) {
        String startTimeString = times[i];
        String endTimeString = times[i + 1];
        bool isBooked = _ifSlotisBooked(startTimeString, endTimeString);

        Timeslot timeslot = Timeslot(
          start: startTimeString,
          end: endTimeString,
          isBooked: isBooked,
        );

        if (!(timeslots.any(
          (element) =>
              element.start == timeslot.start && element.end == timeslot.end,
        ))) {
          timeslots.add(timeslot);
        }
      }
    }
  }

  Color _getSectionColor(int index, int sectionNo) {
    if (index == 0) {
      Timeslot timeslot =
          timeslots.where((element) => element.start == times[index]).first;
      return timeslot.isBooked
          ? widget.bookedSlotColor
          : widget.availableSlotColor;
    } else if (index == times.length - 1) {
      Timeslot timeslot =
          timeslots.where((element) => element.end == times[index]).first;
      return timeslot.isBooked
          ? widget.bookedSlotColor
          : widget.availableSlotColor;
    } else {
      if (sectionNo == 1) {
        Timeslot timeslot =
            timeslots.where((element) => element.end == times[index]).first;
        return timeslot.isBooked
            ? widget.bookedSlotColor
            : widget.availableSlotColor;
      } else {
        Timeslot timeslot =
            timeslots.where((element) => element.start == times[index]).first;

        return timeslot.isBooked
            ? widget.bookedSlotColor
            : widget.availableSlotColor;
      }
    }
  }

  int _getNextAvailableTime(int start, int end) {
    List<String> availableTimeSegments = [];

    for (int i = start; i < end; i++) {
      availableTimeSegments.add(times[i]);
    }

    for (int i = start; i < end; i++) {
      List<Booking> bookedTimes = widget.currentBookings;

      if (bookedTimes.isNotEmpty) {
        for (var element in bookedTimes) {
          // getting range of time between start and end time
          int startIndex = times.indexOf(
            DateFormat("hh:mm a").format(element.startTime),
          );
          int endIndex = times.indexOf(
            DateFormat("hh:mm a").format(element.endTime),
          );

          for (int i = startIndex; i < endIndex; i++) {
            availableTimeSegments.remove(times[i]);
          }
        }
      }
    }

    int firstAvailableSlot = times.indexOf(availableTimeSegments.first);

    return firstAvailableSlot;
  }

  int _getPrevAvailableTime(int start, int end) {
    List<String> availableTimeSegments = [];

    for (int i = start; i <= end; i++) {
      availableTimeSegments.add(times[i]);
    }

    for (int i = start; i < end; i++) {
      List<Booking> bookedTimes = widget.currentBookings;
      if (bookedTimes.isNotEmpty) {
        for (var element in bookedTimes) {
          // getting range of time between start and end time
          int startIndex = times.indexOf(
            DateFormat("hh:mm a").format(element.startTime),
          );
          int endIndex = times.indexOf(
            DateFormat("hh:mm a").format(element.endTime),
          );

          for (int i = startIndex + 1; i <= endIndex; i++) {
            availableTimeSegments.remove(times[i]);
          }
        }
      }
    }
    int lastAvailableSlot = times.indexOf(availableTimeSegments.last);

    return lastAvailableSlot;
  }

  void _jumpToNextPrevSlot() {
    // finding first available slot
    int firstAvailableSlot = _getNextAvailableTime(currentIndex, times.length);
    int prevAvailableSlot = _getPrevAvailableTime(0, currentIndex);

    // Checking scroll direction
    if (currentIndex > prevIndex) {
      if (currentIndex != firstAvailableSlot) {
        // widget.onTimeSelected(getTimeText(timeSegments[firstAvailableSlot]));
        scrollController.jumpToItem(firstAvailableSlot);
        setState(() {
          currentIndex = firstAvailableSlot;
        });
      }
    } else {
      if (currentIndex != prevAvailableSlot) {
        // widget.onTimeSelected(getTimeText(timeSegments[prevAvailableSlot]));
        scrollController.jumpToItem(prevAvailableSlot);
        setState(() {
          currentIndex = prevAvailableSlot;
        });
      }
    }
  }

  void _errorCallback() {
    widget.onError!(
      DurationException(
        "Next ${widget.durationToBlock} hours are not available",
        ErrorCodes.nextDurationBooked,
      ),
    );
  }

  String _calculateEndTimeWithDuration() {
    int startIndex = currentIndex;

    DateTime startTime = DateFormat("hh:mm a").parse(times[startIndex]);

    DateTime endTime = startTime.add(widget.durationToBlock);

    return DateFormat("hh:mm a").format(endTime);
  }

  bool _checkIfNextXDurationBooked() {
    int startIndex = currentIndex;

    String endTime = _calculateEndTimeWithDuration();

    int endIndex =
        endTime == times.last ? times.length - 1 : times.indexOf(endTime);

    List<String> availableTimeSegments = [];

    for (int i = startIndex; i <= endIndex; i++) {
      availableTimeSegments.add(times[i]);
    }

    int numberOfSlots = availableTimeSegments.length;

    for (int i = startIndex; i < endIndex; i++) {
      List<Booking> bookingList = widget.currentBookings;

      if (bookingList.isNotEmpty) {
        for (var element in bookingList) {
          // getting range of time between start and end time
          int startIndex = times.indexOf(
            DateFormat("hh:mm a").format(element.startTime),
          );
          int endIndex = times.indexOf(
            DateFormat("hh:mm a").format(element.endTime),
          );

          for (int i = startIndex + 1; i < endIndex; i++) {
            availableTimeSegments.remove(times[i]);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Center(
        child: HorizontalListWheelScrollView(
          itemExtent: widget.widthOfSegment,
          controller: scrollController,
          physics: const FixedExtentScrollPhysics(),
          scrollDirection: Axis.horizontal,
          diameterRatio: 100,
          perspective: 0.01,
          onSelectedItemChanged: (index) {
            setState(() {
              if (prevIndex != currentIndex) {
                prevIndex = currentIndex;
                currentIndex = index;
              }
            });
            if (index == times.length - 1) {
              widget.onTimeSelected!(DateFormat("hh:mm a").parse(times[index]));
              if (widget.onTimelineEnd != null) {
                widget.onTimelineEnd!();
              }
              return;
            }
            setState(() {
              if (widget.moveToNextPrevSlot) {
                _jumpToNextPrevSlot();
              }
              final bool isBooked = _checkIfNextXDurationBooked();
              if (isBooked) {
                _errorCallback();
              }
            });
            widget.onTimeSelected!(DateFormat("hh:mm a").parse(times[index]));
          },
          children: List.generate(times.length, (index) {
            return SizedBox(
              width: widget.widthOfSegment,
              height: 100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: widget.widthOfSegment / 2,
                        height: widget.timelineThickness,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.transparent
                              : _getSectionColor(index, 1),
                          borderRadius: index == times.length - 1
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                )
                              : BorderRadius.zero,
                        ),
                      ),
                      Container(
                        width: widget.widthOfSegment / 2,
                        height: widget.timelineThickness,
                        decoration: BoxDecoration(
                          color: index == times.length - 1
                              ? Colors.transparent
                              : _getSectionColor(index, 2),
                          borderRadius: index == 0
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                )
                              : BorderRadius.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: widget.barThickness,
                    height: widget.barLength,
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? widget.selectedBarColor
                          : widget.barColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    times[index],
                    style: index == currentIndex
                        ? widget.selectedTextStyle
                        : widget.textStyle,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
