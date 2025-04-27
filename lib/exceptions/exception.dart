// Exception for event and duration
import 'package:event_booking_timeline/error_codes.dart';

class EventException implements Exception {
  /// Message for exception
  final String message;
  final ErrorCodes code;

  /// Constructor for exception
  EventException(this.message, this.code);
}

class DurationException implements Exception {
  /// Message for exception
  final String message;
  final ErrorCodes code;

  /// Constructor for exception
  DurationException(this.message, this.code);
}
