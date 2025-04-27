# Event Booking Timeline

[![pub package](https://img.shields.io/pub/v/event_booking_timeline)](https://pub.dev/packages/event_booking_timeline)

Event booking timeline is a widget used to display the events booked in a specific time of the day.

Note : The arrow can be added on top-center of the timeline, for better user-experiance.

## Features

<li> Timeline color changes according to booking status. </li>
<li> Time format displayed in both 24 and 12 hour formats. </li>
<li> Callback when the time is changed. </li>
<li> Inbuilt class for data. </li>
<li> Custom callbacks & exceptions </li>
<li> Highlighting the current selected slot- duration can be configured. </li>
<li> Skipping the blocked slots to the next or previous available slots. </li>

## Upcoming Features

- Optional haptic feedback while scrolling
- Zooming timeline feature - Timeline can be zoomed the change the number of divisions, for precise times.
- More configure options.
- More callbacks

## Getting started

### Install

    dependencies:
        event_booking_timeline: ^0.1.0

## Usage

### Simple Timeline with booking

### API

- startTime - Starting time of the timeline (24 Hour Format)
- endTime - Ending time of the timeline
- is12HourFormat - The time to be displayed on the timeline
- moveToFirstAvailableTime - To move the timeline to the next available slot
- numberOfSubdivision - The number of subdivisions between the main divisions
- widthOfSegment - The width of each time segments
- widthOfTimeDivisionBar - The thickness of each division
- availableColor - Color to indicate available slot
- bookedColor - Color to indicate the blocked slot
- currentBlockedColor - Color to indicate the current blocked Color
- moveToNextPrevSlot - Should the timeline skip the blocked slots
- durationToBlock - The duration(in hours) to block the time - value should be in accordance with the number of subdivision
- onError - The callback for any error.(e.g If the current slot is booked)
- onTimeSelected - The callback for the time change
- showCurrentBlockedSlot - Whether the current blocked state should be shown or not.

### Sample

```dart
    EventBookingTimeline(
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

### Demo

    Normal timeline with booked and available state.

<img src="https://raw.githubusercontent.com/anixsam/event_booking_timeline/main/example/sample.gif" alt="Demo">
```
