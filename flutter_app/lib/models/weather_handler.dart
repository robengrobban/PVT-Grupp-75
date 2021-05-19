import 'dart:collection';

import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/models/weather_data.dart';
import "package:http/http.dart" as http;
import 'dart:convert' show json;

import 'location_handler.dart';

class WeatherHandler {

  /// Define private constructor
  WeatherHandler._privateConstructor();

  /// The Account Instance
  static final WeatherHandler _instance = WeatherHandler._privateConstructor();

  DateTime _lastWeatherFetched;

  HashMap<int, WeatherData> _weatherMap;

  final int _cacheInMinutes = 1;

  /// Factory constructor to facilitate the Singleton design principle.
  factory WeatherHandler() {
    return _instance;
  }

  Future<HashMap<int, WeatherData>> todaysWeather() async {
    await _generateOrCacheWeatherData();
    return _weatherMap;
  }

  Future<WeatherData> currentWeather() async {
    await _generateOrCacheWeatherData();
    return _weatherMap[DateTime.now().hour];
  }

  Future<void> _generateOrCacheWeatherData() async {
    if ( _lastWeatherFetched == null || DateTime.now().difference(_lastWeatherFetched).inMinutes >= _cacheInMinutes ) {
      await _generateWeatherData().then((value) => _weatherMap = value);
      _lastWeatherFetched = DateTime.now();
    }
  }

  Future<HashMap<int, WeatherData>> _generateWeatherData() async {
    Pair<double, double> coordinates = await _currentPosition();
    HashMap<int, WeatherData> weatherMap = HashMap.identity();

    http.Response response = await _fetchWeather(coordinates.first(), coordinates.second());
    if ( response.statusCode != 200 ) {
      return weatherMap;
    }
    Map<String, dynamic> result = json.decode(response.body);

    List<dynamic> timeSeries = result['timeSeries'];
    for ( int i = 0; i < 24; i++ ) {
      DateTime time = DateTime.parse(timeSeries[i]['validTime']).toLocal();
      int forecast;
      double temperature;

      for ( Map<String, dynamic> entry in timeSeries[i]['parameters'] ) {
        if ( entry["name"] == "Wsymb2" ) {
          forecast = entry["values"][0];
        }
        else if ( entry["name"] == "t" ) {
          temperature = entry["values"][0];
        }
      }

      WeatherData data = WeatherData(time, forecast, temperature);
      weatherMap[time.hour] = data;
    }

    return weatherMap;
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

