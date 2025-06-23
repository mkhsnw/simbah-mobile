class LoginModel {
  bool success;
  String message;
  String token;

  LoginModel({
    required this.success,
    required this.message,
    required this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
    );
  }
}

class RegisterModel {
  bool status;
  String message;

  RegisterModel({required this.status, required this.message});

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
