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
  DateTime _lastEventsFetched;
  bool _loggedIn = false;

  factory Account() {
    return _instance;
  }

  void update({state}) {
    _googleSignIn.signInSilently();
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
  }

  Future<void> handleSignIn() async {
    try {
      _loggedIn = true;
      await _googleSignIn.signIn();
    } catch (error) {
      _notLoggedInActions();
      print(error);
    }
  }

  Future<void> handleSignOut() async {
    _notLoggedInActions();
    return _googleSignIn.disconnect();
  }

  void _notLoggedInActions() {
    _events = List.empty();
    _loggedIn = false;
    _lastEventsFetched = null;
  }

  Future<List<Event>> _generateCalendar() async {
    GoogleSignInAccount user = _currentUser;

    DateTime startTime = new DateTime.now();
    DateTime endTime = new DateTime.now().add(new Duration(days: 1));

    final http.Response response = await http.get(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/'+user.email+'/events?orderBy=startTime&singleEvents=true&timeMax='+endTime.toUtc().toIso8601String()+'&timeMin='+startTime.toUtc().toIso8601String()),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      return List.empty();
    }
    return _buildEventList(json.decode(response.body));;
  }

  bool isLoggedIn() {
    return _loggedIn;
  }

  List<Event> _buildEventList( Map<String, dynamic> json ) {
    List<dynamic> items = json["items"];
    List<Event> events = List.empty(growable: true);

    for (int i = 0; i < items.length; i++) {
      if ( items[i]["start"]["dateTime"] == null ) {
        continue;
      }
      String id = items[i]["id"];
      String summary = items[i]["summary"];
      DateTime startTime = DateTime.parse(items[i]["start"]["dateTime"]);
      DateTime endTime = DateTime.parse(items[i]["end"]["dateTime"]);

      events.add(new Event(id, summary, startTime, endTime));
    }

    return events;

  }

  Future<List<Event>> events() async {
    if ( !_loggedIn ) {
      return Future.error("Not logged in");
    }
    if ( _lastEventsFetched == null || DateTime.now().difference(_lastEventsFetched).inSeconds > 60 ) {
      _events = await _generateCalendar();
      _lastEventsFetched = DateTime.now();
    }
    return _events;
  }

  String displayName() {
    if (_currentUser != null) {
      return _currentUser.displayName;
    }
    return "Inte inloggad";
  }

}


