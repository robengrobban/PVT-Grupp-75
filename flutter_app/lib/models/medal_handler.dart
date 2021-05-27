import 'dart:convert';

import 'package:flutter_app/models/performed_route.dart';

import '../main.dart';
import 'Medal.dart';
import 'account_handler.dart';
import 'package:http/http.dart' as http;
class MedalHandler {

  static final MedalHandler _geoFencer = MedalHandler._internal();

  factory MedalHandler () => _geoFencer;

  MedalHandler._internal();

  List<Medal> createMedalsFor(PerformedRoute newRoute) {
      
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



}