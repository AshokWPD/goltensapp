class GetMasterListResponse {
  bool success;
  List<GetMasterListResponseData> data;
  int totalPages;

  GetMasterListResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetMasterListResponse.fromJson(Map<String, dynamic> json) {
    return GetMasterListResponse(
      success: json['success'],
      data: List<GetMasterListResponseData>.from(
        json['data'].map((x) => GetMasterListResponseData.fromJson(x)),
      ),
      totalPages: json['totalPages'],
    );
  }
}

class GetMasterListResponseData {
  int id;
  String title;
  List<MessageDataGroup> groups;
  List<MessageDataFile> files;
  DateTime createdAt;
  MessageDataCreatedBy createdBy;

  GetMasterListResponseData({
    required this.id,
    required this.title,
    required this.groups,
    required this.files,
    required this.createdAt,
    required this.createdBy,
  });

  factory GetMasterListResponseData.fromJson(Map<String, dynamic> json) {
    return GetMasterListResponseData(
      id: json['id'],
      title: json['title'],
      files: List<MessageDataFile>.from(
        json['files'].map((x) => MessageDataFile.fromJson(x)),
      ),
      groups: List<MessageDataGroup>.from(
        json['groups'].map((x) => MessageDataGroup.fromJson(x)),
      ),
      createdBy: MessageDataCreatedBy.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MessageDataGroup {
  int id;
  String name;
  int readUsersCount;
  int clarifyUsersCount;
  int unReadUsersCount;

  MessageDataGroup({
    required this.id,
    required this.name,
    required this.readUsersCount,
    required this.clarifyUsersCount,
    required this.unReadUsersCount,
  });

  factory MessageDataGroup.fromJson(Map<String, dynamic> json) {
    return MessageDataGroup(
      id: json['id'],
      name: json['name'],
      readUsersCount: json['readUsersCount'],
      clarifyUsersCount: json['clarifyUsersCount'],
      unReadUsersCount: json['unReadUsersCount'],
    );
  }
}

class MessageDataFile {
  int id;
  String name;
  String fileType;

  MessageDataFile({
    required this.id,
    required this.name,
    required this.fileType,
  });

  factory MessageDataFile.fromJson(Map<String, dynamic> json) {
    return MessageDataFile(
      id: json['id'],
      name: json['name'],
      fileType: json['fileType'],
    );
  }
}

class MessageDataCreatedBy {
  String avatar;
  String name;
  String email;

  MessageDataCreatedBy({
    required this.avatar,
    required this.name,
    required this.email,
  });

  factory MessageDataCreatedBy.fromJson(Map<String, dynamic> json) {
    return MessageDataCreatedBy(
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
    );
  }
}
