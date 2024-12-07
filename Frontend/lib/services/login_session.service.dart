import 'package:shared_preferences/shared_preferences.dart';

class LoginSessionService {
  static const _token = "token";

  setToken(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_token, value);
  }

  Future<String> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_token) ?? '';
  }

  removeSession() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(_token);
  }
}