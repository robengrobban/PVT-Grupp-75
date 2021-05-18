
import 'package:flutter/cupertino.dart';

/// A event in the users calendar.
class Event {

  /// Event ID
  String _id;
  /// Event summary/description
  String _summary;
  /// Event start time
  DateTime _startTime;
  /// Event end time
  DateTime _endTime;

  /// Constructor
  Event(this._id,this._summary,this._startTime,this._endTime);

  /// Get event ID
  String id() {
    return _id;
  }

  /// Get event summary/description
  String summary() {
    return _summary;
  }

  /// Get event start time
  DateTime startTime() {
    return _startTime;
  }

  /// Get event end time
  DateTime endTime() {
    return _endTime;
  }

}

