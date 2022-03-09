import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static SharedPreferences _sharedPreferences;

  static Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static String getString(String key) {
    return _sharedPreferences.getString(key);
  }

  static setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }
}

class PreferencesManagerX {

  factory PreferencesManagerX() => _instance;
  static PreferencesManagerX _instance = PreferencesManagerX._();

  PreferencesManagerX._();

  injection(PreferencesManagerX instance) {
    _instance = instance;
  }

  String getString(String key)=> PreferencesManager.getString(key);

  setString(String key,String value) => PreferencesManager.setString(key, value);

}
