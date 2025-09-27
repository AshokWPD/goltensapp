class GetAllUserOrientationItemsResponse {
  bool success;
  List<GetUserOrientationItemsData> data;
  int totalPages;

  GetAllUserOrientationItemsResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetAllUserOrientationItemsResponse.fromJson(
      Map<String, dynamic> json) {
    return GetAllUserOrientationItemsResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => GetUserOrientationItemsData.fromJson(item))
          .toList(),
      totalPages: json['totalPages'] as int,
    );
  }
}

class GetUserOrientationItemsData {
  int id;
  String name;
  DateTime createdAt;

  GetUserOrientationItemsData({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory GetUserOrientationItemsData.fromJson(Map<String, dynamic> json) {
    return GetUserOrientationItemsData(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class GetUserOrientationItemResponse {
  bool success;
  GetUserOrientationItemData data;
  int totalPages;

  GetUserOrientationItemResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetUserOrientationItemResponse.fromJson(Map<String, dynamic> json) {
    return GetUserOrientationItemResponse(
      success: json['success'],
      data: GetUserOrientationItemData.fromJson(json['data']),
      totalPages: json['totalPages'],
    );
  }
}

class GetUserOrientationItemData {
  int id;
  String name;
  DateTime createdAt;
  List<UserOrientationRead> userOrientationReads;

  GetUserOrientationItemData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.userOrientationReads,
  });

  factory GetUserOrientationItemData.fromJson(Map<String, dynamic> json) {
    return GetUserOrientationItemData(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      userOrientationReads: List<UserOrientationRead>.from(
        json['userOrientationReads'].map(
          (x) => UserOrientationRead.fromJson(x),
        ),
      ),
    );
  }
}

class UserOrientationRead {
  DateTime readAt;
  User user;

  UserOrientationRead({
    required this.readAt,
    required this.user,
  });

  factory UserOrientationRead.fromJson(Map<String, dynamic> json) {
    return UserOrientationRead(
      readAt: DateTime.parse(json['readAt']),
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  int id;
  String avatar;
  String name;
  String email;

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
