
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