import 'package:goltens_core/models/auth.dart';

class GetAllGroupsResponse {
  bool success;
  List<GetAllGroupsResponseData> data;

  GetAllGroupsResponse({required this.success, required this.data});

  factory GetAllGroupsResponse.fromJson(Map<String, dynamic> json) {
    return GetAllGroupsResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((v) => GetAllGroupsResponseData.fromJson(v))
          .toList(),
    );
  }
}

class GetAllGroupsResponseData {
  int id;
  String? avatar;
  String name;
  List<Message> unreadMessages;
  String createdAt;

  GetAllGroupsResponseData({
    required this.id,
    required this.avatar,
    required this.name,
    required this.unreadMessages,
    required this.createdAt,
  });

  factory GetAllGroupsResponseData.fromJson(Map<String, dynamic> json) {
    return GetAllGroupsResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      unreadMessages: (json['unreadMessages'] as List)
          .map((v) => Message.fromJson(v))
          .toList(),
      createdAt: json['createdAt'],
    );
  }
}

class GetGroupResponse {
  bool success;
  GetGroupResponseData data;

  GetGroupResponse({
    required this.success,
    required this.data,
  });

  factory GetGroupResponse.fromJson(Map<String, dynamic> json) {
    return GetGroupResponse(
      success: json['success'],
      data: GetGroupResponseData.fromJson(json['data']),
    );
  }
}

class GetGroupResponseData {
  int id;
  String name;
  String? avatar;
  List<Member> members;

  DateTime createdAt;

  GetGroupResponseData({
    required this.id,
    required this.avatar,
    required this.name,
    required this.members,
    required this.createdAt,
  });

  factory GetGroupResponseData.fromJson(Map<String, dynamic> json) {
    return GetGroupResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      members:
          (json['members'] as List).map((v) => Member.fromJson(v)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Member {
  int id;
  String? avatar;
  String name;
  String email;
  String phone;
  String department;
  String employeeNumber;
  AdminApproved adminApproved;
  DateTime createdAt;
  UserType type;

  Member({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.employeeNumber,
    required this.adminApproved,
    required this.createdAt,
    required this.type,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      department: json['department'],
      employeeNumber: json['employeeNumber'],
      adminApproved: AdminApproved.fromName(json['adminApproved']),
      createdAt: DateTime.parse(json['createdAt']),
      type: UserType.fromName(json['type']),
    );
  }
}

class Message {
  int id;
  String content;
  DateTime createdAt;
  String messUserID;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.messUserID,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      messUserID:json['messUserID']
    );
  }
}

class GetMembersResponse {
  final bool success;
  final List<GetMembersResponseData> data;

  GetMembersResponse({
    required this.success,
    required this.data,
  });

  factory GetMembersResponse.fromJson(Map<String, dynamic> json) {
    return GetMembersResponse(
      success: json['success'],
      data: List<GetMembersResponseData>.from(
        json['data'].map(
          (user) => GetMembersResponseData.fromJson(user),
        ),
      ),
    );
  }
}

class GetMembersResponseData {
  final int id;
  final String avatar;
  final String name;
  final String email;
  final UserType type;
  final DateTime? readAt;

  GetMembersResponseData({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
    required this.type,
    required this.readAt,
  });

  factory GetMembersResponseData.fromJson(Map<String, dynamic> json) {
    return GetMembersResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      type: UserType.fromName(json['type']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }
}
