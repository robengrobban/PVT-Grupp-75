import 'package:flutter_app/models/performed_route.dart';

class Streak {
  int days;
  DateTime startDate;
  DateTime endDate;
  List<PerformedRoute> routes;

  Streak({this.days, this.startDate, this.endDate, this.routes});

  factory Streak.fromJson(Map<String, dynamic> json) {
    List<PerformedRoute> routes = [];
    (json['routes'] as List).forEach((element) {
      routes.add(PerformedRoute.fromJson(element));
    });

    return Streak(
      days: (json['days'] as int),
      startDate: (DateTime.parse(json['startDate'])),
      endDate: (DateTime.parse(json['endDate'])),
      routes: routes
    );
  }
}