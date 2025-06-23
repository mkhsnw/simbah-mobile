class UserModel {
  bool success;
  Data data;

  UserModel({required this.success, required this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] ?? false,
      data: Data.fromJson(json['data'] ?? {}),
    );
  }
}

class Data {
  String id;
  String name;
  String email;
  String balance;
  String rekening;
  String role;

  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.rekening,
    required this.role,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
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
    return 'Rp ${balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
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
  final Data? data;

  UserResponse({
    required this.success,
    this.message = '',
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'] ?? false,
      // Response JSON tidak memiliki field 'message', jadi berikan default atau buat berdasarkan success
      message: json['message'] ?? (json['success'] == true ? 'Data berhasil dimuat' : 'Gagal memuat data'),
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  // Factory constructor untuk success response
  factory UserResponse.success(Data data) {
    return UserResponse(
      success: true,
      message: 'Data berhasil dimuat',
      data: data,
    );
  }

  // Factory constructor untuk error response
  factory UserResponse.error(String message) {
    return UserResponse(
      success: false,
      message: message,
      data: null,
    );
  }
}