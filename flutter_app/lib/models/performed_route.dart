
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PerformedRoute {
  List<LatLng> waypoints;
  LatLng startPoint;
  int distance;
  int actualDuration;
  DateTime timeFinished;

  PerformedRoute(
      {
        this.waypoints,
        this.startPoint,
        this.distance,
        this.actualDuration,
        this.timeFinished});

  factory PerformedRoute.fromJson(Map<String, dynamic> json) {
    List<LatLng> waypoints = [];
    (json['waypoints'] as List).forEach((element) {
      waypoints.add(LatLng(element['lat'], element['lng']));
    });

    return PerformedRoute(
        waypoints: waypoints,
        startPoint: MyLocation.fromJson(json['startPoint']).toLatLng(),
        distance: (json['distance'] as int),
        actualDuration: ((json["actualDuration"] / 60).toInt()),
        timeFinished: (DateTime.parse(json['timeFinished'])),
    );
  }

  Map<String,dynamic> toJson() {
    List <MyLocation> wayPointsLocations = [];
    waypoints.forEach((element) {wayPointsLocations.add(MyLocation.fromLatLng(element));});
    var map = Map<String,dynamic>();
    map["waypoints"] = wayPointsLocations;
    map["startPoint"] = MyLocation.fromLatLng(startPoint).toJson();
    map["distance"]= distance;
    map["actualDuration"] = actualDuration;
    map["timeFinished"] = timeFinished.toIso8601String();
    return map;
  }

  @override
  String toString() {
    return 'PerformedRoute{waypoints: $waypoints, startPoint: $startPoint, distance: $distance, actualDuration: $actualDuration, timeFinished: $timeFinished}';
  }
}

class MyLocation extends LatLng {
  MyLocation(double latitude, double longitude) : super(latitude, longitude);
  MyLocation.fromLatLng(LatLng x): super(x.latitude, x.longitude);
  LatLng toLatLng() => LatLng(latitude, longitude);
  MyLocation.fromJson(Map<String, dynamic> json) : super (json['lat'] as double, json['lng'] as double);
  Map<String, dynamic> toJson() => { 'lat': latitude, 'lng': longitude};
}