
import 'package:flutter/material.dart';

class NotificationSpot {

  int _id;
  DateTime _startTime;
  DateTime _endTime;

  NotificationSpot(@required this._id, @required this._startTime, @required this._endTime);

  int durationInMinutes() {
    return _endTime.difference(_startTime).inMinutes;
  }

  int id() {
    return _id;
  }

  DateTime startTime() {
    return _startTime;
  }

  DateTime endTime() {
    return _endTime;
  }

}
