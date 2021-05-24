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

  final DateTime time = DateTime.now();
  final double temperature = 20.1;

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

    test('Forecast icon day_sunny', () async {
      int forecast = 1;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.day_sunny);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.day_sunny);
    });

    test('Forecast icon day_cloudy', () async {
      int forecast = 3;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.day_cloudy);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.day_cloudy);

    });

    test('Forecast icon cloudy', () async {
      int forecast = 5;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.cloudy);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.cloudy);

    });

    test('Forecast icon fog', () async {
      int forecast = 7;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.fog);
    });

    test('Forecast icon showers', () async {
      int forecast = 8;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.showers);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.showers);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.showers);
    });

    test('Forecast icon thunderstorm', () async {
      int forecast = 11;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.thunderstorm);
    });

    test('Forecast icon sleet', () async {
      int forecast = 12;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.sleet);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.sleet);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.sleet);
    });

    test('Forecast icon snow', () async {
      int forecast = 15;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.snow);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.snow);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.snow);
    });

    test('Forecast icon rain', () async {
      int forecast = 18;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.rain);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.rain);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.rain);
    });

    test('Forecast icon lightning', () async {
      int forecast = 21;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.lightning);
    });

    test('Forecast icon sleet_2', () async {
      int forecast = 22;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.sleet);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.sleet);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.sleet);
    });

    test('Forecast icon snow_2', () async {
      int forecast = 25;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.snow);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.snow);

      testData = WeatherData(time, ++forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.snow);
    });

    test('forecast icon default_volcano', () async {
      int forecast = 30;

      WeatherData testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.volcano);

      forecast = -25;

      testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.volcano);

      forecast = -25;

      testData = WeatherData(time, forecast, temperature);
      expect(testData.forecastIcon(), WeatherIcons.volcano);
    });




  });

  group('WeatherHandler', () {

    test('Should cache before first call and should not cache after first call', () async {
      await WeatherHandler().init();
      WeatherHandler().clearCache();
      expect(WeatherHandler().shouldCache(), true);
      await WeatherHandler().currentWeather( stockholm );
      expect(WeatherHandler().shouldCache(), false);
    });

    test('Weather data parsing', () async {

      FakeSMHIFetcher fake = FakeSMHIFetcher();
      await WeatherHandler().init(smhi: fake);

      WeatherHandler().clearCache();

      HashMap<int, WeatherData> testData = await WeatherHandler().todaysWeather(stockholm);

      DateTime testTime = DateTime.parse("2021-05-24T15:00:00Z").toLocal();

      expect(testData[testTime.hour].temperature(), 109.1);

      testTime = DateTime.parse("2021-05-24T22:00:00Z").toLocal();

      expect(testData[testTime.hour].forecast(), 683091549810583571);

    });

  });


}

