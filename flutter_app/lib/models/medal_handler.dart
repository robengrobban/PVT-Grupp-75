import 'dart:convert';

import 'package:flutter_app/models/performed_route.dart';

import '../main.dart';
import 'Medal.dart';
import 'account_handler.dart';
import 'package:http/http.dart' as http;

import 'medal_repository.dart';
class MedalHandler {

  static final MedalHandler _geoFencer = MedalHandler._internal();

  factory MedalHandler () => _geoFencer;

  MedalHandler._internal();

  Future<List<Medal>> createMedalsFor(PerformedRoute newRoute) async {
    List<Medal> medals = [];
    for (MedalType type in MedalType.values) {
      int value = await type.evaluate(newRoute);
      if(value != null) {
        Medal medal = Medal(type: type, value: value, timeEarned: newRoute.timeFinished);
        medals.add(medal);
        await _saveMedal(medal);
      }
    }
    return medals;
  }

  Future<List<Medal>> getMedals() async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS
        ? Uri.https(SERVER_HOST, '/medals', {"token": token})
        : Uri.http(SERVER_HOST, '/medals', {"token": token});
    print(uri.toString());
    final response = await http.get(uri);
    List<Medal> medals = [];
    if (response.statusCode == 200) {
      List<dynamic> jsonMedals = jsonDecode(response.body);
      jsonMedals.forEach((medal) {medals.add(Medal.fromJson(medal)); });
    } else {
      print("error fetching medals: ${response.statusCode}");
    }
    return medals;
  }

  Future<void> _saveMedal(Medal medal) async {
    String token = await AccountHandler().accessToken();
    var uri = USES_HTTPS ?  Uri.https(SERVER_HOST, '/medals/add') : Uri.http(SERVER_HOST, '/medals/add');
    print(uri.toString());
    Map<String, dynamic> performedRouteBody = {
      'token' :token,
      'medal':medal.toJson()
    };
    final response = await http.post(uri, headers:  {'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode(performedRouteBody));
    if(response.statusCode != 200) {
      print(response.statusCode);
      throw Exception("Failed to save user medal data");
    }
  }



}