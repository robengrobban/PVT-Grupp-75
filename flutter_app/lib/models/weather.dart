import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/pair.dart';
import "package:http/http.dart" as http;
import 'dart:convert' show json;

import 'location_handler.dart';

class Weather {


  Weather();

  //https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/xxx/lat/xxx/data.json

  Future<HashMap<int, bool>> todaysWeather() async {
    Pair<double, double> coordinates = await _currentPosition();
    http.Response response = await _fetchWeather(coordinates.first(), coordinates.second());
    Map<String, dynamic> result = json.decode(response.body);
    HashMap<int, bool> weatherMap = HashMap.identity();
    List<dynamic> timeSeries = result['timeSeries'];
    for ( int i = 0; i < 24; i++ ) {
      DateTime time = DateTime.parse(timeSeries[i]['validTime']).toLocal();
      int forecast = timeSeries[i]['parameters'][18]['values'][0];
    }

  }

  Future<Pair<double, double>> _currentPosition() async{
    return LocationHandler().latlon();
  }

  Future<http.Response> _fetchWeather(double lat, double lon) async {
    String url = "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/"+lon.toStringAsFixed(6)+"/lat/"+lat.toStringAsFixed(6)+"/data.json";
    print(url);
    return http.get(
      Uri.parse(url)
    );
  }


}

