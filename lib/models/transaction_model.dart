import 'package:intl/intl.dart';

class TransactionData {
  String id;
  String userId;
  String type;
  String totalAmount;
  String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;
  List<Item>? items;

  TransactionData({
    required this.id,
    required this.userId,
    required this.type,
    required this.totalAmount,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.items,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      totalAmount: json['totalAmount']?.toString() ?? '0',
      description: json['description']?.toString() ?? 'No Description',
      createdAt: _parseISODate(json['createdAt']),
      updatedAt: _parseISODate(json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      items: json['items'] != null ? (json['items'] as List).map((item) => Item.fromJson(item)).toList() : null,
    );
  }

  // Parsing khusus untuk format ISO 8601
  static DateTime? _parseISODate(dynamic dateValue) {
    if (dateValue == null) return null;

    try {
      if (dateValue is String) {
        // Format: "2025-06-19T02:55:55.868Z"
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
    } catch (e) {
      print('Error parsing ISO date: $dateValue, error: $e');
    }

    return null;
  }
}

class Item {
  int id;
  String transactionId;
  int wasteCategoryId;
  String weightInKg;
  String subtotal;
  WasteCategory wasteCategory;
  TransactionData transaction;

  Item({
    required this.id,
    required this.transactionId,
    required this.wasteCategoryId,
    required this.weightInKg,
    required this.subtotal,
    required this.wasteCategory,
    required this.transaction,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      transactionId: json['transactionId']?.toString() ?? '',
      wasteCategoryId: json['wasteCategoryId'] ?? 0,
      weightInKg: json['weightInKg']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
      wasteCategory: WasteCategory.fromJson(json['wasteCategory'] ?? {}),
      transaction: TransactionData.fromJson(json['transaction'] ?? {}),
    );
  }
}

class WasteCategory {
  int id;
  String name;
  String pricePerKg;
  DateTime? createdAt;
  DateTime? updatedAt;

  WasteCategory({required this.id, required this.name, required this.pricePerKg, this.createdAt, this.updatedAt});

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      pricePerKg: json['pricePerKg']?.toString() ?? '0',
      createdAt: TransactionData._parseISODate(json['createdAt']),
      updatedAt: TransactionData._parseISODate(json['updatedAt']),
    );
  }
}

class User {
  String id;
  String name;
  String email;
  String balance;
  String rekening;
  String role;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
    required this.rekening,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '0',
      rekening: json['rekening']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
      createdAt: TransactionData._parseISODate(json['createdAt']),
      updatedAt: TransactionData._parseISODate(json['updatedAt']),
    );
  }
}

class TransactionModel {
  bool success;
  String message;
  List<TransactionData> data;

  TransactionModel({required this.success, required this.message, required this.data});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<TransactionData> transactionDataList = dataList.map((item) => TransactionData.fromJson(item)).toList();

    return TransactionModel(success: json['success'] ?? false, message: json['message'] ?? '', data: transactionDataList);
  }
}

class ReportModel {
  bool success;
  String message;
  ReportData data;

  ReportModel({required this.success, required this.message, required this.data});

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ReportData.fromJson(json['data'] ?? {}),
    );
  }
}

class ReportData {
  int totalDeposit;
  int totalWithdraw;
  int totalTransaction;
  double totalWasteWeight;
  int depositCount;
  int withdrawalCount;
  int currentBalance;
  int averageDepositAmount;
  int averageWithdrawAmount;

  ReportData({
    required this.totalDeposit,
    required this.totalWithdraw,
    required this.totalTransaction,
    required this.totalWasteWeight,
    required this.depositCount,
    required this.withdrawalCount,
    required this.currentBalance,
    required this.averageDepositAmount,
    required this.averageWithdrawAmount,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      totalDeposit: json['totalDeposit'] ?? 0,
      totalWithdraw: json['totalWithdraw'] ?? 0,
      totalTransaction: json['totalTransaction'] ?? 0,
      totalWasteWeight: (json['totalWasteWeight'] as num?)?.toDouble() ?? 0.0,
      depositCount: json['depositCount'] ?? 0,
      withdrawalCount: json['withdrawalCount'] ?? 0,
      currentBalance: json['currentBalance'] ?? 0,
      averageDepositAmount: int.tryParse(json['averageDepositAmount'].toString()) ?? 0,
      averageWithdrawAmount: json['averageWithdrawAmount'] ?? 0,
    );
  }
}
