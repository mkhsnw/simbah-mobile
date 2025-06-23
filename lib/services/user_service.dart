import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simbah/config/api.dart';
import 'package:simbah/models/user_model.dart';
import 'package:simbah/utils/token.dart';

class UserService {
  Future<UserResponse> getUserInfo() async {
    try {
      final token = await getToken();
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
}
