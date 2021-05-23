
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';

class CircularRoute {
  List<LatLng> polyCoordinates;
  List<LatLng> waypoints;
  LatLng startPoint;
  int distance;
  int duration;
  LatLng northEastBound;
  LatLng southWestBound;

  CircularRoute(
      {this.polyCoordinates,
        this.waypoints,
        this.startPoint,
        this.distance,
        this.duration,
        this.northEastBound,
        this.southWestBound});


  Map<String,dynamic> toJson() {
    List <MyLocation> polyLocations = [];
    polyCoordinates.forEach((element) {polyLocations.add(MyLocation.fromLatLng(element));});
    List <MyLocation> wayPointsLocations = [];
    waypoints.forEach((element) {wayPointsLocations.add(MyLocation.fromLatLng(element));});
    var map = Map<String,dynamic>();
    map["polyCoordinates"] = polyLocations;
    map["waypoints"] = wayPointsLocations;
    map["startPoint"] = MyLocation.fromLatLng(startPoint);
    map["distance"]= distance;
    map["durationInSeconds"] = duration;
    map["northEastBound"] = MyLocation.fromLatLng(northEastBound);
    map["southWestBound"] = MyLocation.fromLatLng(southWestBound);
    return map;
  }

  factory CircularRoute.fromJson(Map<String, dynamic> json) {
    List<LatLng> polyCoordinates = [];
    (json['polyCoordinates'] as List).forEach((element) {
      polyCoordinates.add(LatLng(element['lat'], element['lng']));
    });
    List<LatLng> waypoints = [];
    (json['waypoints'] as List).forEach((element) {
      waypoints.add(LatLng(element['lat'], element['lng']));
    });

    int fuckingWork = 30;
    if (json['durationInSeconds'] is int) {
      fuckingWork = (((json['durationInSeconds'] as int)/ 60)).toInt();
    } else if (json['durationInSeconds'] is int) {
      (((json['durationInSeconds'] as double)/ 60).toInt());
    }

    return CircularRoute(
        polyCoordinates: polyCoordinates,
        waypoints: waypoints,
        startPoint: MyLocation.fromJson(json['startPoint']).toLatLng(),
        distance: (json['distance'] is double) ? (json['distance'] as double).toInt() : (json['distance'] as int),
        duration: fuckingWork,
        northEastBound: MyLocation.fromJson(json['northEastBound']).toLatLng(),
        southWestBound: MyLocation.fromJson(json['southWestBound']).toLatLng());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircularRoute &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(waypoints,other.waypoints) &&
          startPoint == other.startPoint;

  @override
  int get hashCode => waypoints.hashCode ^ startPoint.hashCode;
}

class MyLocation extends LatLng {
  MyLocation(double latitude, double longitude) : super(latitude, longitude);
  MyLocation.fromLatLng(LatLng x): super(x.latitude, x.longitude);
  LatLng toLatLng() => LatLng(latitude, longitude);
  MyLocation.fromJson(Map<String, dynamic> json) : super (json['lat'] as double, json['lng'] as double);
  Map<String, dynamic> toJson() => { 'lat': latitude, 'lng': longitude};
}