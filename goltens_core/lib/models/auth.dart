class TokenResponse {
  final bool success;
  final String token;

  TokenResponse({required this.success, required this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      success: json['success'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['token'] = token;
    return data;
  }
}

class UserResponse {
  bool success;
  UserResponseData data;

  UserResponse({
    required this.success,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'],
      data: UserResponseData.fromJson(json['data']),
    );
  }
}

enum AdminApproved {
  approved,
  pending,
  rejected;

  static AdminApproved fromName(String name) {
    for (AdminApproved enumVariant in AdminApproved.values) {
      if (enumVariant.name == name) return enumVariant;
    }

    throw UnsupportedError(
      "Unsupported string '$name' cannot convert to AdminApproved",
    );
  }
}

enum UserType {
  admin,
  subAdmin,
  userAndSubAdmin,
  user;

  static UserType fromName(String name) {
    for (UserType enumVariant in UserType.values) {
      if (enumVariant.name == name) return enumVariant;
    }

    throw UnsupportedError(
      "Unsupported string '$name' cannot convert to UserType",
    );
  }
}

class UserResponseData {
  int id;
  String avatar;
  String name;
  String email;
  String phone;
  String department;
  String employeeNumber;
  AdminApproved adminApproved;
  UserType type;
  String createdAt;
  int badgeCount;

  UserResponseData(
      {required this.id,
      required this.avatar,
      required this.name,
      required this.email,
      required this.phone,
      required this.department,
      required this.employeeNumber,
      required this.adminApproved,
      required this.type,
      required this.createdAt,
      required this.badgeCount});

  factory UserResponseData.fromJson(Map<String, dynamic> json) {
    return UserResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      department: json['department'],
      employeeNumber: json['employeeNumber'],
      adminApproved: AdminApproved.fromName(json['adminApproved']),
      type: UserType.fromName(json['type']),
      createdAt: json['createdAt'],
      badgeCount: json['badgeCount'],
    );
  }
}
