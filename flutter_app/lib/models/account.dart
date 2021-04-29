import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';

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
    print(startTime.toUtc().toIso8601String());
    print(endTime.toUtc().toIso8601String());
    print(Uri.parse('https://www.googleapis.com/calendar/v3/calendars/'+user.email+'/events?orderBy=startTime&singleEvents=true&timeMax='+startTime.toUtc().toIso8601String()+'&timeMin='+endTime.toUtc().toIso8601String()));

    String _startTime = startTime.toUtc().toIso8601String();
    String _endTime = endTime.toUtc().toIso8601String();

    _startTime = "2021-04-29T00:00:00Z";
    _endTime = "2021-04-30T00:00:00Z";

    final http.Response response = await http.get(
      Uri.parse('https://www.googleapis.com/calendar/v3/calendars/'+user.email+'/events?orderBy=startTime&singleEvents=true&timeMax='+_startTime+'&timeMin='+_endTime),
      headers: await user.authHeaders,
    );
    print('API: ${response.statusCode} response: ${response.body}');
    return;
  }

  String displayName() {
    if (_currentUser != null) {
      return _currentUser.displayName;
    }
    return "Ingen inloggad";
  }

}


