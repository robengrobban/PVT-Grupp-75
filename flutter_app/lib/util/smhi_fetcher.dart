import "package:http/http.dart" as http;
import 'dart:convert' show json;

class SMHIFetcher {

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    String url = "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/"+lon.toStringAsFixed(6)+"/lat/"+lat.toStringAsFixed(6)+"/data.json";
    print(url);
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      }
    );
    if ( response.statusCode != 200 ) {
      return null;
    }
    return json.decode(response.body);
  }

}
