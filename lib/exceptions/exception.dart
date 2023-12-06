// Exception for event and duration
class EventException implements Exception {
  /// Message for exception
  final String message;

  /// Constructor for exception
  EventException(this.message);
}

class DurationException implements Exception {
  /// Message for exception
  final String message;

  /// Constructor for exception
  DurationException(this.message);
}
