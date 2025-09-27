class GetOtherFilesResponse {
  bool success;
  List<GetOtherFilesResponseData> data;
  int totalPages;

  GetOtherFilesResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetOtherFilesResponse.fromJson(Map<String, dynamic> json) {
    return GetOtherFilesResponse(
      success: json['success'],
      data: List<GetOtherFilesResponseData>.from(
        json['data'].map((x) => GetOtherFilesResponseData.fromJson(x)),
      ),
      totalPages: json['totalPages'],
    );
  }
}

class GetOtherFilesResponseData {
  int id;
  String name;
  DateTime createdAt;

  GetOtherFilesResponseData({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory GetOtherFilesResponseData.fromJson(Map<String, dynamic> json) {
    return GetOtherFilesResponseData(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
