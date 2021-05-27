
import 'dart:async';

import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/notification_handler.dart';
import 'package:flutter_app/util/google_calendar_fetcher.dart';
import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert' show json;
import 'package:flutter_app/models/event.dart';

/// Singleton class used to handle the users account.
class AccountHandler {

  /// Define private constructor
  AccountHandler._privateConstructor();

  /// The Account Instance
  static final AccountHandler _instance = AccountHandler._privateConstructor();

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

  /// The ID for the account
  int _id;

  /// List of events on this users calendar
  List<Event> _events = List.empty(growable: true);

  /// Last time events was fetched, used for caching information.
  DateTime _lastEventsFetched;

  StreamSubscription<GoogleSignInAccount> _lastCallback;

  final int _cacheInMinutes = 1;

  GoogleCalendarFetcher _calendarFetcher;

  /// Factory constructor to facilitate the Singleton design principle.
  factory AccountHandler() {
    return _instance;
  }

  /// Method used for updating the account.
  /// This can be used to activate a re-construction of a flutter widget, or
  /// to activate silent sign in.
  void onOneTimeUserChange(Function() callback) {
    _lastCallback = _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if ( _lastCallback != null ) {
        _lastCallback.cancel();
      }
      callback();
    });
  }

  Future<void> init({GoogleCalendarFetcher fetcher}) async {
    _calendarFetcher = fetcher ?? GoogleCalendarFetcher();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;
      _changeUserActions();
    });
    await _googleSignIn.signInSilently();
  }

  /// Sign in the user using google.
  Future<bool> handleSignIn() async {
    try {
      GoogleSignInAccount result = await _googleSignIn.signIn();
      _currentUser = result;
      if(result != null) {
        return true;
      }
    } catch (error) {
      print(error);
    }
    return false;
  }

  int id() {
    return _id;
  }

  Future<String> accessToken() async {
    bool valid = await _isTokenStillValid();
    if ( !valid ) {
      await _currentUser.clearAuthCache();
    }
    return (await _currentUser.authentication).accessToken;
  }

  /// Sign out the user using google.
  /// This will also wipe all pending notifications.
  Future<void> handleSignOut() async {
    await NotificationHandler().wipeNotifications();
    await _googleSignIn.disconnect();
  }

  /// Creates a entry for the user in the database
  void _registerUser(String email, String token) async {
    http.Response response = await _createAccount(email, token);
    if ( response.statusCode == 409 || response.statusCode == 200 ) {
      Map<String, dynamic> accountInfo = json.decode(response.body);
      _id = accountInfo['id'];
    }
  }

  /// Sends a post request to create account
  /// Returns the response.
  Future<http.Response> _createAccount(String email, String token) async {
    return http.post(
      USES_HTTPS ? Uri.https(SERVER_HOST, "/account/create") : Uri.http(SERVER_HOST, "/account/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'email': email,
        'token': token
      }),
    );
  }

  Future<bool> _isTokenStillValid() async {
    final http.Response response = await _checkToken((await _currentUser.authentication).accessToken);
    return response.statusCode == 200 && response.body == "true";
  }

  Future<http.Response> _checkToken(String token) async {
    return http.get(
      USES_HTTPS ? Uri.https(SERVER_HOST, "/account/token", {"token": token}) : Uri.http(SERVER_HOST, "/account/token", {"token": token})
    );
  }

  /// Actions when the logged in user is changed.
  /// This occurs both when the user login and logout.
  void _changeUserActions() async {
    _events = List.empty();
    _lastEventsFetched = null;
    _id = null;
    await NotificationHandler().generateCalendarNotifications();
    if ( isLoggedIn() ) {
      _registerUser(_currentUser.email, (await _currentUser.authentication).accessToken);
    }
  }

  /// Generate a list of events using the google calendar.
  /// The list will contain all of the users event from now and 24h into the future.
  Future<List<Event>> _generateCalendar() async {
    Map<String, dynamic> response = await _calendarFetcher.fetchCalendar(_googleSignIn.currentUser);
    if ( response == null ) {
      return List.empty();
    }
    return _buildEventList(response);
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
    if ( shouldCache() ) {
      _events = await _generateCalendar();
      _lastEventsFetched = DateTime.now();
    }
    return _events;
  }

  bool shouldCache() {
    return _lastEventsFetched == null || DateTime.now().difference(_lastEventsFetched).inMinutes >= _cacheInMinutes;
  }

  void clearCache() {
    _lastEventsFetched = null;
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


