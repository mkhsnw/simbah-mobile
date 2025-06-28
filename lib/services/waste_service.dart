import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simbah/config/api.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/utils/exception_manager.dart';
import 'package:simbah/utils/token.dart';
import 'package:http/http.dart' as http;

class WasteService {
  Future<WasteModelGet> getWasteData({BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/waste'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Waste Data Response Code: ${response.statusCode}');
      print('Waste Data Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WasteModelGet.fromJson(data);
      } else if (response.statusCode == 404) {
        // Throw custom exception untuk no data
        final data = json.decode(response.body);
        throw NoDataException(data['message'] ?? 'Data sampah tidak ditemukan');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to load waste data: ${response.reasonPhrase}',
        );
      }
    } on NoDataException {
      // Re-throw NoDataException untuk ditangani di UI
      rethrow;
    } on UnauthorizedException {
      // Re-throw UnauthorizedException
      rethrow;
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat memuat data');
    }
  }

  Future<WasteModelRequest> createWasteType({
    required String name,
    required String pricePerKg,
    BuildContext? context,
  }) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/waste'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': name, 'pricePerKg': pricePerKg}),
      );

      print('Create Waste Response Code: ${response.statusCode}');
      print('Create Waste Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return WasteModelRequest.fromJson(data);
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal menambahkan jenis sampah',
        );
      }
    } catch (e) {
      print('Error creating waste type: $e');
      if (e is UnauthorizedException) rethrow;
      throw Exception('Terjadi kesalahan saat menambahkan jenis sampah');
    }
  }

  Future<WasteModelRequest> updateWasteType({
    required String id,
    required String name,
    required String pricePerKg,
    BuildContext? context,
  }) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/waste/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': name, 'pricePerKg': pricePerKg}),
      );

      print('Update Waste Response Code: ${response.statusCode}');
      print('Update Waste Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WasteModelRequest.fromJson(data);
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal mengupdate jenis sampah',
        );
      }
    } catch (e) {
      print('Error updating waste type: $e');
      if (e is UnauthorizedException) rethrow;
      throw Exception('Terjadi kesalahan saat mengupdate jenis sampah');
    }
  }

  Future<WasteModelRequest> deleteWasteType({
    required String id,
    BuildContext? context,
  }) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/waste/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Waste Response Code: ${response.statusCode}');
      print('Delete Waste Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WasteModelRequest.fromJson(data);
      } else if (response.statusCode == 401) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menghapus jenis sampah');
      }
    } catch (e) {
      print('Error deleting waste type: $e');
      if (e is UnauthorizedException) rethrow;
      throw Exception('Terjadi kesalahan saat menghapus jenis sampah');
    }
  }
}
