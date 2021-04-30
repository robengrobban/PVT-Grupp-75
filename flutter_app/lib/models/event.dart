
import 'package:flutter/cupertino.dart';

class Event {

  String _id;
  String _summary;
  DateTime _startTime;
  DateTime _endTime;

  Event(@required this._id, @required this._summary, @required this._startTime, @required this._endTime);

  String id() {
    return _id;
  }

  String summary() {
    return _summary;
  }

  DateTime startTime() {
    return _startTime;
  }

  DateTime endTime() {
    return _endTime;
  }

}

