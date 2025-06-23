import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simbah/config/api.dart';
import 'package:simbah/models/transaction_model.dart';
import 'package:simbah/utils/token.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  Future<TransactionModel> getTransactions({BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transaction/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Transaction Response Code: ${response.statusCode}');
      print('Transaction Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TransactionModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Failed to load transactions: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat memuat data transaksi');
    }
  }

  Future<ReportModel> getReport({BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transaction/report'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReportModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to load report: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat data laporan: $e');
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
