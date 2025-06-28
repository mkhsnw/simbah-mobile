import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';

  // Method untuk handle unauthorized dengan context manual
  static Future<void> handleUnauthorized(BuildContext context) async {
    // Hapus token
    await AuthManager.clearToken();

    if (context.mounted) {
      // Tampilkan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Redirect ke login
      Future.delayed(Duration(seconds: 2), () {
        if (context.mounted) {
          context.go('/login');
        }
      });
    }
  }

  // Method untuk check token secara manual
  static Future<bool> checkTokenValidity(
    int statusCode,
    BuildContext context,
  ) async {
    if (statusCode == 401) {
      await handleUnauthorized(context);
      return false;
    }
    return true;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ✅ Save user role for faster access
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  // ✅ Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // ✅ Get complete auth status
  static Future<Map<String, dynamic>> getAuthStatus() async {
    final token = await getToken();
    final role = await getUserRole();

    return {
      'isLoggedIn': token != null && token.isNotEmpty,
      'token': token,
      'role': role,
    };
  }
}
