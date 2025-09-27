class GetAssessmentsResponse {
  bool success;
  List<GetAssessmentsResponseData> data;
  int totalPages;

  GetAssessmentsResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetAssessmentsResponse.fromJson(Map<String, dynamic> json) {
    return GetAssessmentsResponse(
      success: json['success'],
      data: List<GetAssessmentsResponseData>.from(
        json['data'].map((x) => GetAssessmentsResponseData.fromJson(x)),
      ),
      totalPages: json['totalPages'],
    );
  }
}

class GetAssessmentsResponseData {
  int id;
  String name;
  DateTime createdAt;

  GetAssessmentsResponseData({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory GetAssessmentsResponseData.fromJson(Map<String, dynamic> json) {
    return GetAssessmentsResponseData(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
