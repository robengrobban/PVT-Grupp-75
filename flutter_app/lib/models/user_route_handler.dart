import 'dart:convert';

import 'package:flutter_app/models/account_handler.dart';
import 'package:flutter_app/models/performed_route.dart';

import '../main.dart';
import 'package:http/http.dart' as http;

import 'Streak.dart';

class UserRouteHandler {
  static final UserRouteHandler _handler = UserRouteHandler._internal();

  factory UserRouteHandler() => _handler;

  UserRouteHandler._internal();

  Future<int> getTotalTimeWalked() async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(SERVER_HOST, '/performedRoutes/totalTime', {"token": token})
        : Uri.http(SERVER_HOST, '/performedRoutes/totalTime', {"token": token});
    print(uri.toString());
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      print(response.statusCode);
      throw Exception("Failed to load user route data");
    }
  }

  Future<int> getTotalDistanceWalked() async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(
            SERVER_HOST, '/performedRoutes/totalDistance', {"token": token})
        : Uri.http(
            SERVER_HOST, '/performedRoutes/totalDistance', {"token": token});
    print(uri.toString());
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      print(response.statusCode);
      throw Exception("Failed to load user route data");
    }
  }

  Future<void> saveRoute(PerformedRoute route) async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(SERVER_HOST, '/performedRoutes/add')
        : Uri.http(SERVER_HOST, '/performedRoutes/add');
    print(uri.toString());
    Map<String, dynamic> performedRouteBody = {
      'token': token,
      'performedRoute': route.toJson()
    };
    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(performedRouteBody));
    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception("Failed to save user route data");
    }
  }

  Future<Streak> getLongestStreak() async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(
            SERVER_HOST, '/performedRoutes/streaks/longest', {"token": token})
        : Uri.http(
            SERVER_HOST, '/performedRoutes/streaks/longest', {"token": token});
    print(uri.toString());
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return Streak(days: 0);
      }
      return Streak.fromJson(jsonDecode(response.body));
    } else {
      print(response.statusCode);
      throw Exception("Failed to load user route data");
    }
  }

  Future<Streak> getCurrentStreak() async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(
            SERVER_HOST, '/performedRoutes/streaks/current', {"token": token})
        : Uri.http(
            SERVER_HOST, '/performedRoutes/streaks/current', {"token": token});
    print(uri.toString());
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return Streak(days: 0);
      }
      return Streak.fromJson(jsonDecode(response.body));
    } else {
      print(response.statusCode);
      throw Exception("Failed to load user route data");
    }
  }

  Future<Map<DateTime, List<PerformedRoute>>> getRoutesAsDateMap() async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(SERVER_HOST, '/performedRoutes', {"token": token})
        : Uri.http(SERVER_HOST, '/performedRoutes', {"token": token});
    print(uri.toString());
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return _parseRoute(response.body);
    } else {
      print(response.statusCode);
      throw Exception("Failed to load user route data");
    }
  }

  Map<DateTime, List<PerformedRoute>> _parseRoute(String responseBody) {
    Map<DateTime, List<PerformedRoute>> routeMap = {};
    List<dynamic> routes = jsonDecode(responseBody);
    for (var d in routes) {
      PerformedRoute route = PerformedRoute.fromJson(d);
      DateTime routeTime = route.timeFinished;
      DateTime routeDate =
          DateTime(routeTime.year, routeTime.month, routeTime.day);
      if (!routeMap.containsKey(routeDate)) {
        routeMap[routeDate] = [];
      }
      routeMap[routeDate].add(route);
    }
    return routeMap;
  }

  Future<List<PerformedRoute>> getRoutesBetween(
      DateTime startTime, DateTime endTime) async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(SERVER_HOST, '/performedRoutes/between', {
            "token": token,
            "startTime": startTime.toIso8601String(),
            "endTime": endTime.toIso8601String()
          })
        : Uri.http(SERVER_HOST, '/performedRoutes/between', {
            "token": token,
            "startTime": startTime.toIso8601String(),
            "endTime": endTime.toIso8601String()
          });
    print(uri.toString());
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> unParsedRoutes = jsonDecode(response.body);
      List<PerformedRoute> routes = [];
      unParsedRoutes.forEach((route) {
        routes.add(PerformedRoute.fromJson(route));
      });
      return routes;
    } else {
      print(response.statusCode);
      throw Exception("Failed to get user route data");
    }
  }
}
