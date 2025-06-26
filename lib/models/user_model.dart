class UserModel {
  bool success;
  DataUser data;

  UserModel({required this.success, required this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] ?? false,
      data: DataUser.fromJson(json['data'] ?? {}),
    );
  }
}

class DataUser {
  String id;
  String name;
  String email;
  String balance;
  String rekening;
  String role;

  DataUser({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.rekening,
    required this.role,
  });

  factory DataUser.fromJson(Map<String, dynamic> json) {
    return DataUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '0',
      rekening: json['rekening']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
    );
  }

  // Format balance untuk display
  String get formattedBalance {
    final balance = double.tryParse(this.balance) ?? 0;
    return 'Rp ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  String toString() {
    return 'Data{id: $id, name: $name, email: $email, balance: $balance, rekening: $rekening, role: $role}';
  }
}

// Response wrapper untuk API - disesuaikan dengan response JSON
class UserResponse {
  final bool success;
  final String message;
  final DataUser? data;

  UserResponse({required this.success, this.message = '', this.data});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] ?? false,
      // Response JSON tidak memiliki field 'message', jadi berikan default atau buat berdasarkan success
      message:
          json['message'] ??
          (json['success'] == true
              ? 'Data berhasil dimuat'
              : 'Gagal memuat data'),
      data: json['data'] != null ? DataUser.fromJson(json['data']) : null,
    );
  }

  // Factory constructor untuk success response
  factory UserResponse.success(DataUser data) {
    return UserResponse(
      success: true,
      message: 'Data berhasil dimuat',
      data: data,
    );
  }

  // Factory constructor untuk error response
  factory UserResponse.error(String message) {
    return UserResponse(success: false, message: message, data: null);
  }
}

class UserResponseGet {
  bool success;
  String message;
  List<DataUser> data;

  UserResponseGet({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserResponseGet.fromJson(Map<String, dynamic> json) {
    return UserResponseGet(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => DataUser.fromJson(item))
              .toList() ??
          [],
    );
  }
}
