import 'dart:convert';

import 'package:simbah/config/api.dart';
import 'package:simbah/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:simbah/utils/exception_manager.dart';

class AuthService {
  Future<LoginModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}s/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      print('Login Response Code : ${response.statusCode}');
      print('Login Response Body : ${response.body}');

      // Handle different status codes
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LoginModel.fromJson(data);
      } else if (response.statusCode == 401) {
        // Unauthorized - wrong credentials
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Email atau password salah';
        throw AuthException(message);
      } else if (response.statusCode == 400) {
        // Bad request - validation error
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Data yang dimasukkan tidak valid';
        throw AuthException(message);
      } else if (response.statusCode == 404) {
        // Not found
        throw AuthException('User tidak5 ditemukan');
      } else if (response.statusCode >= 00) {
        // Server error
        throw AuthException('Email atau password salah.');
      } else {
        // Other errorss
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Login gagal';
        throw AuthException(message);
      }
    } on AuthException {
      // Re-throw AuthException as is
      rethrow;
    } catch (e) {
      print('Error during login: $e');

      // Handle different types of errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw AuthException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        );
      } else if (e.toString().contains('FormatException')) {
        throw AuthException('Response server tidak valid.');
      } else {
        throw AuthException('Terjadi kesalahan: ${e.toString()}');
      }
    }
  }

  Future<RegisterModel> register(
    String email,
    String password,
    String name,
    String? role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        }),
      );

      print('Register Response Code : ${response.statusCode}');
      print('Register Response Body : ${response.body}');

      // Handle different status codes
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return RegisterModel.fromJson(data);
      } else if (response.statusCode == 400) {
        // Bad request - validation error
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Data registrasi tidak valid';
        throw AuthException(message);
      } else if (response.statusCode == 409) {
        // Conflict - email already exists
        throw AuthException(
          'Email sudah terdaftar. Silakan gunakan email lain.',
        );
      } else if (response.statusCode == 422) {
        // Unprocessable entity - validation errors
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          // Handle validation errors from server
          final errors = data['errors'] as Map<String, dynamic>;
          String errorMessage = 'Terjadi kesalahan validasi:\n';
          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessage += '• ${messages.join(', ')}\n';
            }
          });
          throw AuthException(errorMessage.trim());
        } else {
          final message = data['message'] ?? 'Data yang dimasukkan tidak valid';
          throw AuthException(message);
        }
      } else if (response.statusCode >= 500) {
        // Server error
        throw AuthException(
          'Terjadi kesalahan pada server. Silakan coba lagi.',
        );
      } else {
        // Other errors
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Registrasi gagal';
        throw AuthException(message);
      }
    } on AuthException {
      // Re-throw AuthException as is
      rethrow;
    } catch (e) {
      print('Error during registration: $e');

      // Handle different types of errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw AuthException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        );
      } else if (e.toString().contains('FormatException')) {
        throw AuthException('Response server tidak valid.');
      } else {
        throw AuthException('Terjadi kesalahan: ${e.toString()}');
      }
    }
  }
}
