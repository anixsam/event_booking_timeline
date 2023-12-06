class EventException implements Exception {
  final String message;
  EventException(this.message);
}

class DurationException implements Exception {
  final String message;
  DurationException(this.message);
}
