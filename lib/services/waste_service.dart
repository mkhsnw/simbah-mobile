import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:simbah/config/api.dart';
import 'package:simbah/models/waste_mode.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/utils/token.dart';
import 'package:http/http.dart' as http;

class WasteService {
  Future<WasteModel> getWasteData({BuildContext? context}) async {
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
        return WasteModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to load waste data: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat memuat data');
    }
  }
}
