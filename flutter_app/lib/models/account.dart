import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';
import 'dart:convert' show json;

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
    if (_currentUser != null) {
      _fixMeMyCalendar(_currentUser); // Testning
    }
  }

  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  Future<void> _fixMeMyCalendar(GoogleSignInAccount user) async {

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
    log('API: ${response.statusCode} response: ${response.body}');
    final Map<String, dynamic> data = json.decode(response.body);
    return;
  }

  String displayName() {
    if (_currentUser != null) {
      return _currentUser.displayName;
    }
    return "Ingen inloggad";
  }

}


