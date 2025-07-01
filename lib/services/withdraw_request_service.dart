import 'dart:convert';

import 'package:simbah/config/api.dart';
import 'package:simbah/models/withdraw_model.dart';
import 'package:simbah/services/transaction_service.dart';
import 'package:simbah/utils/token.dart';
import 'package:http/http.dart' as http;

class WithdrawRequestService {
  Future<dynamic> createWithdrawRequest(int amount, String description) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/withdrawal'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'amount': amount, 'description': description}),
      );
      print('Withdraw Request Response Code: ${response.statusCode}');
      print('Withdraw Request Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final dataDecode = json.decode(response.body);
        final data = WithdrawModel.fromJson(dataDecode);
        return data;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Gagal membuat permintaan penarikan: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error creating withdraw request: $e');
      if (e is UnauthorizedException) {
        throw e;
      } else {
        throw Exception('Terjadi kesalahan jaringan: $e');
      }
    }
  }

  Future<WithdrawModel> getWithdrawRequests() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/withdrawal/my-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Get Withdraw Requests Response Code: ${response.statusCode}');
      print('Get Withdraw Requests Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dataDecode = json.decode(response.body);
        final data = WithdrawModel.fromJson(dataDecode);
        return data;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Gagal mengambil permintaan penarikan: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error getting withdraw requests: $e');
      if (e is UnauthorizedException) {
        throw e;
      } else {
        throw Exception('Terjadi kesalahan jaringan: $e');
      }
    }
  }

  Future<dynamic> cancelUserRequest(String requestId) async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/withdrawal/$requestId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Cancel Withdraw Request Response Code: ${response.statusCode}');
      print('Cancel Withdraw Request Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final dataDecode = json.decode(response.body);
        return dataDecode;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Gagal membatalkan permintaan penarikan: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error canceling withdraw request: $e');
      if (e is UnauthorizedException) {
        throw e;
      } else {
        throw Exception('Terjadi kesalahan jaringan: $e');
      }
    }
  }

  Future<WithdrawModel> getAllAdminWithdrawRequests() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse(('${ApiConfig.baseUrl}/withdrawal/admin/all')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(
        'Get All Admin Withdraw Requests Response Code: ${response.statusCode}',
      );
      print('Get All Admin Withdraw Requests Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final dataDecode = json.decode(response.body);
        final data = WithdrawModel.fromJson(dataDecode);
        return data;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access. Please login again.');
      } else {
        throw Exception(
          'Gagal mengambil permintaan penarikan admin: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error getting all admin withdraw requests: $e');
      if (e is UnauthorizedException) {
        throw e;
      } else {
        throw Exception('Terjadi kesalahan jaringan: $e');
      }
    }
  }

  Future<dynamic> processRequestAdmin(
    String action,
    String adminNote,
    String requestId,
  ) async {
    final token = await AuthManager.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/withdrawal/admin/$requestId/process'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'action': action, 'adminNote': adminNote}),
    );
    print(
      'Process Admin Withdraw Request Response Code: ${response.statusCode}',
    );
    print('Process Admin Withdraw Request Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final dataDecode = json.decode(response.body);
      return dataDecode;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access. Please login again.');
    } else {
      throw Exception(
        'Gagal memproses permintaan penarikan admin: ${response.reasonPhrase}',
      );
    }
  }
}
