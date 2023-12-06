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

* Optional haptic feedback while scrolling
* Zooming timeline feature - Timeline can be zoomed the change the number of divisions, for precise times.
* More configure options.
* More callbacks


## Getting started

### Install

    dependencies:
        event_booking_timeline: ^0.1.0

## Usage

### Simple Timeline with booking

### API 

* startTime - Starting time of the timeline (24 Hour Format)
* endTime - Ending time of the timeline
* is12HourFormat - The time to be displayed on the timeline
* moveToFirstAvailableTime - To move the timeline to the next available slot
* numberOfSubdivision - The number of subdivisions between the main divisions
* widthOfSegment - The width of each time segments
* widthOfTimeDivisionBar - The thickness of each division
* availableColor - Color to indicate available slot 
* bookedColor - Color to indicate the blocked slot
* currentBlockedColor - Color to indicate the current blocked Color
* moveToNextPrevSlot - Should the timeline skip the blocked slots
* durationToBlock - The duration(in hours) to block the time - value should be in accordance with the number of subdivision
* onError - The callback for any error.(e.g If the current slot is booked)
* onTimeSelected - The callback for the time change
* showCurrentBlockedSlot - Whether the current blocked state should be shown or not.

### Sample

```dart
    EventBookingTimeline(
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
    );

    EventBookingTimeline.withCurrentBookingSlot(
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
    );
```

### Demo

    Normal timeline with booked and available state.

<img src="https://raw.githubusercontent.com/anixsam/event_booking_timeline/main/example/sample.gif" alt="Demo">