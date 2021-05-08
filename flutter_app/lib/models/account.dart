
import 'package:flutter/material.dart';
import 'package:flutter_app/models/notification_handler.dart';
import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert' show json;
import 'package:flutter_app/models/event.dart';

/// Singleton class used to handle the users account.
class Account {

  /// Define private constructor
  Account._privateConstructor();

  /// The Account Instance
  static final Account _instance = Account._privateConstructor();

  /// GoogleSignIn object to handle sign-ins and sign-outs.
  /// Also defines scope for the logged in account.
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar.readonly',
    ],
  );

  /// The current user
  GoogleSignInAccount _currentUser;

  /// List of events on this users calendar
  List<Event> _events = List.empty(growable: true);

  /// Last time events was fetched, used for caching information.
  DateTime _lastEventsFetched;

  /// Factory constructor to facilitate the Singleton design principle.
  factory Account() {
    return _instance;
  }

  /// Method used for updating the account.
  /// This can be used to activate a re-construction of a flutter widget, or
  /// to activate silent sign in.
  void update({State state}) {
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
      _changeUserActions();
    });
  }

  /// Sign in the user using google.
  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  /// Sign out the user using google.
  /// This will also wipe all pending notifications.
  Future<void> handleSignOut() async {
    await NotificationHandler().wipeNotifications();
    _googleSignIn.disconnect();
  }

  /// Creates a entry for the user in the database
  void _registerUser(String email) async {
    http.Response response;
    await _createAccount(email).then((value) => response = value);
    print(response.statusCode);
    print(response.body);
    print(response.headers);
  }

  Future<http.Response> _createAccount(String email) {
    return http.post(
      Uri.https("group5-75.pvt.dsv.su.se", "/account/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'email': email
      }),
    );
  }

  /// Actions when the logged in user is changed.
  /// This occures both when the user login and logout.
  void _changeUserActions() async {
    _events = List.empty();
    _lastEventsFetched = null;
    await NotificationHandler().generateCalendarNotifications();
    if ( isLoggedIn() ) {
      _registerUser(_currentUser.email);
    }
  }

  /// Generate a list of events using the google calendar.
  /// The list will contain all of the users event from now and 24h into the future.
  Future<List<Event>> _generateCalendar() async {
    GoogleSignInAccount user = _currentUser;

    if ( user == null ) {
      return List.empty();
    }

    DateTime startTime = new DateTime.now();
    DateTime endTime = new DateTime.now().add(new Duration(days: 1));

    final http.Response response = await http.get(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/'+user.email+'/events?orderBy=startTime&singleEvents=true&timeMax='+endTime.toUtc().toIso8601String()+'&timeMin='+startTime.toUtc().toIso8601String()),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      return List.empty();
    }
    return _buildEventList(json.decode(response.body));
  }

  /// Returns a list of events from a JSON object.
  /// Designed for the Google Calendar API.
  List<Event> _buildEventList( Map<String, dynamic> json ) {
    List<dynamic> items = json["items"];
    List<Event> events = List.empty(growable: true);

    for (int i = 0; i < items.length; i++) {
      if ( items[i]["start"]["dateTime"] == null ) {
        continue;
      }
      String id = items[i]["id"];
      String summary = items[i]["summary"];
      DateTime startTime = DateTime.parse(items[i]["start"]["dateTime"]).toLocal();
      DateTime endTime = DateTime.parse(items[i]["end"]["dateTime"]).toLocal();

      events.add(new Event(id, summary, startTime, endTime));
    }

    return events;

  }

  /// Returns a list of events using the google calendar.
  /// The list will contain all of the users event from now and 24h into the future.
  Future<List<Event>> events() async {
    if (_currentUser == null ) {
      return Future.error("Not logged in");
    }
    if ( _lastEventsFetched == null || DateTime.now().difference(_lastEventsFetched).inSeconds > 0 ) {
      _events = await _generateCalendar();
      _lastEventsFetched = DateTime.now();
    }
    return _events;
  }

  /// Check if a user is logged in or not.
  bool isLoggedIn() {
    return _currentUser != null;
  }

  /// Get the display name of the logged in user.
  /// If the user is not logged in, the text "Inte inloggad" will be returned.
  String displayName() {
    if (isLoggedIn()) {
      return _currentUser.displayName;
    }
    return "Inte inloggad";
  }

}


