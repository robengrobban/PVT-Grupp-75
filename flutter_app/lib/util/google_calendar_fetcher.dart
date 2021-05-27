import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'dart:convert' show json;

class GoogleCalendarFetcher {

  Future<Map<String, dynamic>> fetchCalendar(GoogleSignInAccount user, {Duration offset}) async {
    if ( user == null ) {
      return null;
    }
    offset = offset ?? Duration(microseconds: 0);

    DateTime startTime = new DateTime.now().add(offset);
    DateTime endTime = new DateTime.now().add(new Duration(days: 1)).add(offset);

    final http.Response response = await http.get(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/'+user.email+'/events?orderBy=startTime&singleEvents=true&timeMax='+endTime.toUtc().toIso8601String()+'&timeMin='+startTime.toUtc().toIso8601String()),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      return null;
    }
    return json.decode(response.body);

  }

}
