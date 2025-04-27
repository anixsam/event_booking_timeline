class Timeslot {
  final String start;
  final String end;

  bool isBooked;

  Timeslot({required this.start, required this.end, this.isBooked = false});

  @override
  String toString() {
    return 'Timeslot{start: $start, end: $end, isBooked: $isBooked}';
  }
}
