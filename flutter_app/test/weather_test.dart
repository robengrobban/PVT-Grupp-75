import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_app/models/pair.dart';
import 'package:flutter_app/models/weather_data.dart';
import 'package:flutter_app/models/weather_handler.dart';
import 'package:flutter_app/util/smhi_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_icons/weather_icons.dart';
import 'dart:convert' show json;

class FakeSMHIFetcher extends SMHIFetcher {

  final File file = File('assets/test/fake_smhi_data.txt');

  @override
  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final String jsonData = await file.readAsString();
    return json.decode(jsonData);
  }
}

void main() {

  final Pair<double, double> stockholm = Pair(59.326242, 17.8419717);

  group('WeatherData', () {

    test('Constructor', () async {
      final DateTime time = DateTime.now();
      final int forecast = 1;
      final double temperature = 20.1;

      final WeatherData testData = WeatherData(time, forecast, temperature);

      expect(testData.time(), time);
      expect(testData.forecast(), forecast);
      expect(testData.temperature(), temperature);

    });

    test('Forecast icon clear sky', () async {
      final DateTime time = DateTime.now();
      final double temperature = 20.1;

      final int forecast = 1;

      final WeatherData testData = WeatherData(time, forecast, temperature);

      expect(testData.forecastIcon(), WeatherIcons.day_sunny);
    });

    // TODO: ALL THE ICONS https://opendata.smhi.se/apidocs/metfcst/parameters.html


  });

  group('WeatherHandler', () {

    test('Should cache before first call and should not cache after first call', () async {
      await WeatherHandler().init();
      expect(WeatherHandler().shouldCache(), true);
      await WeatherHandler().currentWeather( stockholm );
      expect(WeatherHandler().shouldCache(), false);
    });

    test('Weather data parsing', () async {

      FakeSMHIFetcher fake = FakeSMHIFetcher();
      await WeatherHandler().init(smhi: fake);

      HashMap<int, WeatherData> testData = await WeatherHandler().todaysWeather(stockholm);

      DateTime testTime = DateTime.parse("2021-05-24T15:00:00Z").toLocal();

      expect(testData[testTime.hour].temperature(), 109.1);

      testTime = DateTime.parse("2021-05-24T22:00:00Z").toLocal();

      expect(testData[testTime.hour].forecast(), 683091549810583571);

    });

  });


}

