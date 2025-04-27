import 'package:flutter/material.dart';

class TimelineController extends ChangeNotifier {
  Function(DateTime)? _onJumpRequest;

  void scrollToTime(DateTime time) {
    if (_onJumpRequest != null) {
      _onJumpRequest!(time);
    }
  }

  void registerOnJump(void Function(DateTime time) callback) {
    _onJumpRequest = callback;
  }
}
