class WasteModelGet {
  bool success;
  String message;
  List<WasteData> data;

  WasteModelGet({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WasteModelGet.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<WasteData> wasteDataList = dataList
        .map((item) => WasteData.fromJson(item))
        .toList();

    return WasteModelGet(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: wasteDataList,
    );
  }
}

class WasteData {
  String id;
  String name;
  String pricePerKg;

  WasteData({required this.id, required this.name, required this.pricePerKg});

  factory WasteData.fromJson(Map<String, dynamic> json) {
    return WasteData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      pricePerKg: json['pricePerKg']?.toString() ?? '0',
    );
  }
}

class WasteModelRequest {
  bool success;
  String message;
  WasteData data;

  WasteModelRequest({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WasteModelRequest.fromJson(Map<String, dynamic> json) {
    return WasteModelRequest(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: WasteData.fromJson(json['data'] ?? {}),
    );
  }
}
