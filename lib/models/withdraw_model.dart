class WithdrawModel {
  bool success;
  String message;
  List<WithdrawData> data;

  WithdrawModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
    return WithdrawModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => WithdrawData.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class WithdrawData {
  String id;
  String userId;
  String amount;
  String description;
  String status;
  String? adminNote;
  DateTime requestedAt;
  DateTime? processedAt;
  DateTime updatedAt;

  WithdrawData({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.status,
    required this.requestedAt,
    required this.updatedAt,
    this.adminNote,
    this.processedAt,
  });

  factory WithdrawData.fromJson(Map<String, dynamic> json) {
    return WithdrawData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: json['amount'] ?? "0",
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      adminNote: json['adminNote'],
      requestedAt: DateTime.parse(
        json['requestedAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
    );
  }
}
