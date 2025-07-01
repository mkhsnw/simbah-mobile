import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simbah/config/api.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/utils/token.dart';

class UserService {
  Future<UserResponse> getUserInfo({BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('User Info Response Code: ${response.statusCode}');
      print('User Info Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Menggunakan UserResponse.fromJson yang sudah disesuaikan
        return UserResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        return UserResponse.error(
          'Gagal mengambil data user: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error getting user info: $e');
      return UserResponse.error('Terjadi kesalahan jaringan: $e');
    }
  }

  Future<UserResponse> updateUser(
    String id,
    String name,
    String email,
    String role,
  ) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': name, 'email': email, 'role': role}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        return UserResponse.error(
          'Gagal memperbarui data user: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error updating user: $e');
      return UserResponse.error('Terjadi kesalahan jaringan: $e');
    }
  }

  Future<dynamic> deleteUser(String id, BuildContext context) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        await AuthManager.handleUnauthorized(context);
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await AuthManager.handleUnauthorized(context);
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception('Gagal menghapus user: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Terjadi kesalahan saat menghapus user: $e');
    }
  }

  Future<UserResponseGet> getAllUsers({BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get All Users Response Code: ${response.statusCode}');
      print('Get All Users Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserResponseGet.fromJson(data);
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Gagal mengambil daftar user: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error getting all users: $e');
      return UserResponseGet(
        success: false,
        message: 'Terjadi kesalahan saat mengambil daftar user: $e',
        data: [],
      );
    }
  }

  Future<UserResponse> getUserById(String id, {BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get User By ID Response Code: ${response.statusCode}');
      print('Get User By ID Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        return UserResponse.error(
          'Gagal mengambil data user: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      return UserResponse.error('Terjadi kesalahan jaringan: $e');
    }
  }
}
