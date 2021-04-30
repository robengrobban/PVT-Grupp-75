import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert' show json;
import 'package:flutter_app/models/event.dart';

class Account {

  Account._privateConstructor();

  static final Account _instance = Account._privateConstructor();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.readonly',
    ],
  );

  GoogleSignInAccount _currentUser;

  List<Event> _events = List.empty(growable: true);

  factory Account() {
    return _instance;
  }

  void update({state = null}) {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if ( state == null ) {
        _currentUser = account;
      }
      else {
        state.setState(() {
          _currentUser = account;
        });
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  Future<void> generateCalendar(/*GoogleSignInAccount user*/) async {
    GoogleSignInAccount user = _currentUser;

    DateTime startTime = new DateTime.now();
    DateTime endTime = new DateTime.now().add(new Duration(days: 1));

    final http.Response response = await http.get(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/'+user.email+'/events?orderBy=startTime&singleEvents=true&timeMax='+endTime.toUtc().toIso8601String()+'&timeMin='+startTime.toUtc().toIso8601String()),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      // ERROR HANDLING
      return;
    }
    _buildEventList(json.decode(response.body));
    return;
  }

  void _buildEventList( Map<String, dynamic> json ) {
    List<dynamic> items = json["items"];
    _events = List.empty(growable: true);

    for (int i = 0; i < items.length; i++) {
      if ( items[i]["start"]["dateTime"] == null ) {
        continue;
      }
      String id = items[i]["id"];
      String summary = items[i]["summary"];
      DateTime startTime = DateTime.parse(items[i]["start"]["dateTime"]);
      DateTime endTime = DateTime.parse(items[i]["end"]["dateTime"]);

      _events.add(new Event(id, summary, startTime, endTime));
    }

  }

  List<Event> events() {
    return _events;
  }

  String displayName() {
    if (_currentUser != null) {
      return _currentUser.displayName;
    }
    return "Ingen inloggad";
  }

}


