class GetMessagesResponse {
  bool success;
  List<GetMessagesResponseData> data;

  GetMessagesResponse({
    required this.success,
    required this.data,
  });

  factory GetMessagesResponse.fromJson(Map<String, dynamic> json) {
    return GetMessagesResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((v) => GetMessagesResponseData.fromJson(v))
          .toList(),
    );
  }
}

class GetMessagesResponseData {
  int id;
  String title;
  String content;
  String messUserID;
  int timer;
  List<Files> files;
  CreatedBy createdBy;
  DateTime createdAt;

  GetMessagesResponseData({
    required this.id,
    required this.title,
    required this.content,
    required this.messUserID,
    required this.files,
    required this.timer,
    required this.createdBy,
    required this.createdAt,
  });

  factory GetMessagesResponseData.fromJson(Map<String, dynamic> json) {
    return GetMessagesResponseData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      messUserID:json['messUserID'],
      files: List<Files>.from(
        json['files'].map((file) => Files.fromJson(file)),
      ),
      timer: json['timer'],
      createdBy: CreatedBy.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CreatedBy {
  int id;
  String name;
  String avatar;

  CreatedBy({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }
}

class MessageStatusResponse {
  final bool success;
  final List<ReadStatusUser> readUsers;
  final List<ReadStatusUser> unreadUsers;

  MessageStatusResponse({
    required this.success,
    required this.readUsers,
    required this.unreadUsers,
  });

  factory MessageStatusResponse.fromJson(Map<String, dynamic> json) {
    return MessageStatusResponse(
      success: json['success'],
      readUsers: List<ReadStatusUser>.from(
        json['readUsers'].map((user) => ReadStatusUser.fromJson(user)),
      ),
      unreadUsers: List<ReadStatusUser>.from(
        json['unreadUsers'].map((user) => ReadStatusUser.fromJson(user)),
      ),
    );
  }
}

class ReadStatusUser {
  final String avatar;
  final String name;
  final String email;
  final String? reply;
  final String? mode;
  final DateTime? readAt;

  ReadStatusUser({
    required this.avatar,
    required this.name,
    required this.email,
    required this.reply,
    required this.mode,
    required this.readAt,
  });

  factory ReadStatusUser.fromJson(Map<String, dynamic> json) {
    return ReadStatusUser(
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      mode: json['mode'],
      reply: json['reply'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }
}

class GetMessageResponse {
  final bool success;
  final GetMessageResponseData data;

  GetMessageResponse({
    required this.success,
    required this.data,
  });

  factory GetMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageResponse(
      success: json['success'],
      data: GetMessageResponseData.fromJson(json['data']),
    );
  }
}

class GetMessageResponseData {
  final int id;
  final String title;
  final String content;
  final int timer;
  final CreatedBy createdBy;
  final List<Read> read;
  final DateTime createdAt;
  List<Files> files;
  final Read? messageReadByUser;

  GetMessageResponseData({
    required this.id,
    required this.title,
    required this.content,
    required this.timer,
    required this.createdBy,
    required this.read,
    required this.createdAt,
    required this.files,
    required this.messageReadByUser,
  });

  factory GetMessageResponseData.fromJson(Map<String, dynamic> json) {
    return GetMessageResponseData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      timer: json['timer'],
      createdBy: CreatedBy.fromJson(json['createdBy']),
      files: List<Files>.from(
        json['files'].map((user) => Files.fromJson(user)),
      ),
      read: List<Read>.from(
        json['read'].map((user) => Read.fromJson(user)),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      messageReadByUser: json['messageReadByUser'] != null
          ? Read.fromJson(json['messageReadByUser'])
          : null,
    );
  }
}

class Read {
  int id;
  User user;
  String? reply;
  String? mode;
  DateTime readAt;

  Read({
    required this.id,
    required this.user,
    required this.reply,
    required this.mode,
    required this.readAt,
  });

  factory Read.fromJson(Map<String, dynamic> json) {
    return Read(
      id: json['id'],
      user: User.fromJson(json['user']),
      reply: json['reply'],
      mode: json['mode'],
      readAt: DateTime.parse(json['readAt']),
    );
  }
}

class Files {
  String name;
  String fileType;

  Files({
    required this.name,
    required this.fileType,
  });

  factory Files.fromJson(Map<String, dynamic> json) {
    return Files(
      name: json['name'],
      fileType: json['fileType'],
    );
  }
}

class User {
  final int id;
  final String avatar;
  final String name;
  final String email;

  User({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
    );
  }
}
