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

  Future<TransactionModel> getAllTransactions({BuildContext? context}) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        if (context != null) {
          await AuthManager.handleUnauthorized(context);
        }
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/transaction'),
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

  Future<dynamic> createTransactionDeposit({
    required String type,
    required String userId,
    required String description,
    required List<Map<String, dynamic>> items,
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
        Uri.parse('${ApiConfig.baseUrl}/transaction'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': type,
          'userId': userId,
          'description': description,
          'items': items,
        }),
      );
      print('Create Transaction Response Code: ${response.statusCode}');
      print('Create Transaction Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Failed to create transaction: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat membuat transaksi');
    }
  }

  Future<dynamic> createTransactionWithdraw({
    required String type,
    required String userId,
    required int amount,
    required String description,
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
        Uri.parse('${ApiConfig.baseUrl}/transaction'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'type': type,
          'userId': userId,
          'description': description,
          'amount': amount,
        }),
      );
      print('Create Transaction Response Code: ${response.statusCode}');
      print('Create Transaction Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else if (response.statusCode == 400) {
        throw Exception(
          'Minimal pengambilan adalah Rp. 50.000 atau saldo anda tidak mencukupi',
        );
      } else {
        throw Exception(
          'Failed to create transaction: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('$e');
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

  Future<dynamic> editTransactionDeposit(
    String userId,
    String description,
    List<Map<String, dynamic>> items,
    String transactionId,
  ) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw UnauthorizedException('Token tidak ditemukan');
      }
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'description': description,
          'items': items,
        }),
      );
      print('Edit Transaction Response Code: ${response.statusCode}');
      print('Edit Transaction Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to edit transaction: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat mengedit transaksi');
    }
  }

  Future<dynamic> editTransactionWithdraw(
    String userId,
    int amount,
    String description,
    String transactionId,
  ) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw UnauthorizedException('Token tidak ditemukan');
      }
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'totalAmount': amount,
          'description': description,
        }),
      );
      print('Edit Transaction Response Code: ${response.statusCode}');
      print('Edit Transaction Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to edit transaction: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat mengedit transaksi');
    }
  }

  Future<dynamic> deleteTransaction(
    String transactionId, {
    BuildContext? context,
  }) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw UnauthorizedException('Token tidak ditemukan');
      }
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Delete Transaction Response Code: ${response.statusCode}');
      print('Delete Transaction Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Failed to delete transaction: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat menghapus transaksi');
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
