
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherData {

  DateTime _time;
  int _forecast;
  double _temperature;

  WeatherData(this._time, this._forecast, this._temperature);

  DateTime time() {
    return _time;
  }

  int forecast() {
    return _forecast;
  }

  IconData forecastIcon() {
    switch (_forecast) {
      case 1:
      case 2:
        return WeatherIcons.day_sunny;
      case 3:
      case 4:
        return WeatherIcons.day_cloudy;
      case 5:
      case 6:
        return WeatherIcons.cloudy;
      case 7:
        return WeatherIcons.fog;
      case 8:
      case 9:
      case 10:
        return WeatherIcons.showers;
      case 11:
        return WeatherIcons.thunderstorm;
      case 12:
      case 13:
      case 14:
        return WeatherIcons.sleet;
      case 15:
      case 16:
      case 17:
        return WeatherIcons.snow;
      case 18:
      case 19:
      case 20:
        return WeatherIcons.rain;
      case 21:
        return WeatherIcons.lightning;
      case 22:
      case 23:
      case 24:
        return WeatherIcons.sleet;
      case 25:
      case 26:
      case 27:
        return WeatherIcons.snow;
      default:
        return WeatherIcons.volcano;
    }
  }

  double temperature() {
    return _temperature;
  }

}
/*
enum WeatherType {
  CLEAR_SKY,
  NEARLY_CLEAR_SKY,
  VARIABLE_CLOUDINESS,
  HALFCLEAR_SKY,
  CLOUDY_SKY,
  OVERCAST,
  FOG,
  LIGHT_RAIN_SHOWERS,
  MODERATE_RAIN_SHOWERS,
  HEAVY_RAIN_SHOWERS,
  THUNDERSTORM,
  LIGHT_SLEET_SHOWERS,
  MODERATE_SLEET_SHOWERS,
  HEAVY_SLEET_SHOWERS,
  LIGHT_SNOW_SHOWERS,
  MODERATE_SNOW_SHOWERS,
  HEAVY_SNOW_SHOWERS,
  LIGHT_RAIN,
  MODERATE_RAIN,
  HEAVY_RAIN,
  THUNDER,
  LIGHT_SLEET,
  MODERATE_SLEET,
  HEAVY_SLEET,
  LIGHT_SNOWFALL,
  MODERATE_SNOWFALL,
  HEAVY_SNOWFALL
}
*/