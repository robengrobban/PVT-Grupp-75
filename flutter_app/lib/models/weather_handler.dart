import 'dart:collection';

import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/models/weather_data.dart';
import 'package:flutter_app/util/smhi_fetcher.dart';
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

  SMHIFetcher _smhi;

  /// Factory constructor to facilitate the Singleton design principle.
  factory WeatherHandler() {
    return _instance;
  }

  Future<void> init({SMHIFetcher smhi}) async {
    _smhi = smhi ?? SMHIFetcher();
  }

  Future<HashMap<int, WeatherData>> todaysWeather(Pair<double, double> coordinates) async {
    await _generateOrCacheWeatherData(coordinates);
    return _weatherMap;
  }

  Future<WeatherData> currentWeather(Pair<double, double> coordinates) async {
    await _generateOrCacheWeatherData(coordinates);
    return _weatherMap[DateTime.now().hour];
  }

  Future<void> _generateOrCacheWeatherData(Pair<double, double> coordinates) async {
    if ( shouldCache() ) {
      await _generateWeatherData(coordinates).then((value) => _weatherMap = value);
      _lastWeatherFetched = DateTime.now();
    }
  }

  bool shouldCache() {
    return _lastWeatherFetched == null || DateTime.now().difference(_lastWeatherFetched).inMinutes >= _cacheInMinutes;
  }

  Future<HashMap<int, WeatherData>> _generateWeatherData( Pair<double, double> coordinates ) async {
    HashMap<int, WeatherData> weatherMap = HashMap.identity();

    Map<String, dynamic> result = await _smhi.fetchWeather(coordinates.first(), coordinates.second());
    if ( result == null ) {
      return weatherMap;
    }

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

}

