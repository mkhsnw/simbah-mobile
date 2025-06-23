class WasteModel {
  bool success;
  String message;
  List<WasteData> data;

  WasteModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WasteModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<WasteData> wasteDataList = dataList
        .map((item) => WasteData.fromJson(item))
        .toList();

    return WasteModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: wasteDataList,
    );
  }
}

class WasteData {
  String name;
  String pricePerKg;

  WasteData({required this.name, required this.pricePerKg});

  factory WasteData.fromJson(Map<String, dynamic> json) {
    return WasteData(
      name: json['name'] ?? '',
      pricePerKg: json['pricePerKg']?.toString() ?? '0',
    );
  }
}


