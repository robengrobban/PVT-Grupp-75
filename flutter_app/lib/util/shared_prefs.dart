import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String PreferredDurationKey = "preferredDuration";
  static const String PreferredAttractionKey = "preferredAttraction";
  static SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  int get preferredDuration => _sharedPrefs.getInt(PreferredDurationKey);

  set preferredDuration(int value) {
    _sharedPrefs.setInt(PreferredDurationKey, value);
  }

  String get preferredAttraction => _sharedPrefs.getString(PreferredAttractionKey);

  set preferredAttraction(String value) {
    _sharedPrefs.setString(PreferredAttractionKey, value);
  }


}