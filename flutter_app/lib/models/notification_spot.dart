
import 'package:flutter/material.dart';

/// A spot that a notifications can be scheduled in.
class NotificationSpot {

  /// The spots ID
  int _id;
  /// The start time for the spot
  DateTime _startTime;
  /// The end time for the spot
  DateTime _endTime;

  /// Constructor
  NotificationSpot(@required this._id, @required this._startTime, @required this._endTime);

  /// Spot duration in minutes
  int durationInMinutes() {
    return _endTime.difference(_startTime).inMinutes;
  }

  /// Get the id
  int id() {
    return _id;
  }

  /// Get the start time
  DateTime startTime() {
    return _startTime;
  }

  // Get the end time
  DateTime endTime() {
    return _endTime;
  }

}
