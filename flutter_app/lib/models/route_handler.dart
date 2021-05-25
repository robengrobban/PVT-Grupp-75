import 'dart:convert';
import 'dart:math';

import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/Route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class RouteHandler {
  static final RouteHandler _handler = RouteHandler._internal();

  factory RouteHandler() => _handler;

  RouteHandler._internal();


  Future<CircularRoute> fetchRoute(LatLng startPosition, int duration, {String attraction, CircularRoute unwantedRoute}) async {
    int numberOfTries = 0;
    while (numberOfTries < 10) {
      numberOfTries++;
      var angle = Random().nextDouble() * pi * 2;
      var result = await getRoute(startPosition, duration, angle, attraction);
      if (result != null && result != unwantedRoute) {
        return result;
      }
    }
    return null;
  }

    Future<CircularRoute> getRoute(LatLng startPosition, int durationInMinutes, double angle, String attraction) async {
    Map<String,String> query = {"lat":startPosition.latitude.toString(),"lng":startPosition.longitude.toString(), "duration":durationInMinutes.toString(), "radians":angle.toString()};
    if (attraction != null) query["type"] = attraction.toString();
    var uri = USES_HTTPS ?  Uri.https(SERVER_HOST, '/route/generate/bearing', query) : Uri.http(SERVER_HOST, '/route/generate/bearing', query);
      print(uri.toString());
      final response = await http.get(uri);
      if(response.statusCode == 404)
        return null;
      else if (response.statusCode == 200)
        return _parseRoute(response.body);
      else
        throw Exception("Unable to get route from Google API");

    }

  CircularRoute _parseRoute(String responseBody) {
    Map<String, dynamic> route = jsonDecode(responseBody);
    return CircularRoute.fromJson(route);
  }

}