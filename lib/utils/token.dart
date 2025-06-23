import 'package:shared_preferences/shared_preferences.dart';

void setToken(String token) async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.setString('token', token);
}

Future<String?> getToken() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  return sharedPrefs.getString('token');
}

void clearToken() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.remove('token');
}
