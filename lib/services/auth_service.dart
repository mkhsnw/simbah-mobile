import 'dart:convert';

import 'package:simbah/config/api.dart';
import 'package:simbah/models/auth_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<LoginModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        body: {'email': email, 'password': password},
      );
      print('Login Response Code : ${response.statusCode}');
      print('Login Response Body : ${json.decode(response.body)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LoginModel.fromJson(data);
      } else {
        throw Exception('Failed to login: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Error during login: $e');
    }
  }

  Future<RegisterModel> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        body: {'email': email, 'password': password, 'name': name},
      );
      print('Register Response Code : ${response.statusCode}');
      print('Register Response Body : ${json.decode(response.body)}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return RegisterModel.fromJson(data);
      } else {
        throw Exception('Failed to register: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }
}
