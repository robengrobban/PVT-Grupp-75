import 'dart:collection';

import "package:http/http.dart" as http;
import 'dart:convert' show json;

class Weather {


  Weather() {

  }

  //https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/xxx/lat/xxx/data.json

  Future<HashMap<int, bool>> todaysWeather() async {
    List<double> coordinates = _currentPosition();

    http.Response response = await _fetchWeather(coordinates[0], coordinates[1]);
    Map<String, dynamic> result = json.decode(response.body);

    HashMap<int, bool> weatherMap = HashMap.identity();
    List<dynamic> timeSeries = result['timeSeries'];
    for ( int i = 0; i < 24; i++ ) {
      DateTime time = DateTime.parse(timeSeries[i]['validTime']).toLocal();
      int forecast = timeSeries[i]['parameters'][18]['values'][0];
    }

  }

  List<double> _currentPosition() {
    List<double> latlon = List.empty(growable: true);
    latlon.add(59.31);
    latlon.add(18.26);
    return latlon;
  }

  Future<http.Response> _fetchWeather(double lat, double lon) async {
    return http.get(
      Uri.parse("https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/"+lon.toString()+"/lat/"+lat.toString()+"/data.json")
    );
  }


}

