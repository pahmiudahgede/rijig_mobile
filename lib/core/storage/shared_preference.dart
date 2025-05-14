import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static Future<void> setIsLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
