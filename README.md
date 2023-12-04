# Event Booking Timeline

[![pub package](https://img.shields.io/pub/v/event_booking_timeline)](https://pub.dev/packages/event_booking_timeline)

Event booking timeline is a widget used to display the events booked in a specific time of the day.

## Features

<li> Timeline color changes according to booking status. </li>
<li> Time format displayed in both 24 and 12 hour formats. </li>
<li> Callback when the time is changed. </li>
<li> Inbuilt class for data. </li>


## Getting started

### Install

    dependencies:
        event_booking_timeline: ^0.0.5

## Usage

### Simple Timeline with booking

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
        availableColor: Colors.grey,
        bookedColor: Colors.blue,
        onTimeSelected: (String time) {
            print("Selected Time $time");
        },
    );
```

### Demo

<img src="https://github.com/anixsam/event_booking_timeline/blob/9128064df2d225d04f4980ca983535e12fa4cbb5/example/sample.gif" alt="Demo">