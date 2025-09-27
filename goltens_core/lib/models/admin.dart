class PostAssessmentResponse {
  bool success;
  PostAssessmentResponseData data;

  PostAssessmentResponse({
    required this.success,
    required this.data,
  });

  factory PostAssessmentResponse.fromJson(Map<String, dynamic> json) {
    return PostAssessmentResponse(
      success: json['success'],
      data: PostAssessmentResponseData.fromJson(json['data']),
    );
  }
}

class PostAssessmentResponseData {
  String name;
  int id;
  String createdAt;

  PostAssessmentResponseData({
    required this.name,
    required this.id,
    required this.createdAt,
  });

  factory PostAssessmentResponseData.fromJson(Map<String, dynamic> json) {
    return PostAssessmentResponseData(
      name: json['name'],
      id: json['id'],
      createdAt: json['createdAt'],
    );
  }
}

class PostOtherFileResponse {
  bool success;
  PostOtherFileResponseData data;

  PostOtherFileResponse({
    required this.success,
    required this.data,
  });

  factory PostOtherFileResponse.fromJson(Map<String, dynamic> json) {
    return PostOtherFileResponse(
      success: json['success'],
      data: PostOtherFileResponseData.fromJson(json['data']),
    );
  }
}

class PostOtherFileResponseData {
  String name;
  int id;
  String createdAt;

  PostOtherFileResponseData({
    required this.name,
    required this.id,
    required this.createdAt,
  });

  factory PostOtherFileResponseData.fromJson(Map<String, dynamic> json) {
    return PostOtherFileResponseData(
      name: json['name'],
      id: json['id'],
      createdAt: json['createdAt'],
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
  user,
  userAndSubAdmin;

  static UserType fromName(String name) {
    for (UserType enumVariant in UserType.values) {
      if (enumVariant.name == name) return enumVariant;
    }

    throw UnsupportedError(
      "Unsupported string '$name' cannot convert to UserType",
    );
  }
}

class GetUsersResponse {
  bool success;
  List<GetUsersResponseData> data;
  int totalPages;

  GetUsersResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetUsersResponse.fromJson(Map<String, dynamic> json) {
    return GetUsersResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((v) => GetUsersResponseData.fromJson(v))
          .toList(),
      totalPages: json['totalPages'],
    );
  }
}

class GetUsersResponseData {
  int id;
  String? avatar;
  String name;
  String email;
  String phone;
  String department;
  String employeeNumber;
  AdminApproved adminApproved;
  bool active;
  UserType type;
  String createdAt;

  GetUsersResponseData({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.employeeNumber,
    required this.adminApproved,
    required this.active,
    required this.createdAt,
    required this.type,
  });

  factory GetUsersResponseData.fromJson(Map<String, dynamic> json) {
    return GetUsersResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      department: json['department'],
      employeeNumber: json['employeeNumber'],
      adminApproved: AdminApproved.fromName(json['adminApproved']),
      active: json['active'],
      createdAt: json['createdAt'],
      type: UserType.fromName(json['type']),
    );
  }
}

class GetGroupSearchResponse {
  bool success;
  List<GetGroupSearchResponseData> data;

  GetGroupSearchResponse({
    required this.success,
    required this.data,
  });

  factory GetGroupSearchResponse.fromJson(Map<String, dynamic> json) {
    return GetGroupSearchResponse(
      success: json['success'],
      data: List<GetGroupSearchResponseData>.from(
        json['data'].map((x) => GetGroupSearchResponseData.fromJson(x)),
      ),
    );
  }
}

class GetGroupSearchResponseData {
  int id;
  String avatar;
  String name;
  DateTime createdAt;

  GetGroupSearchResponseData({
    required this.id,
    required this.avatar,
    required this.name,
    required this.createdAt,
  });

  factory GetGroupSearchResponseData.fromJson(Map<String, dynamic> json) {
    return GetGroupSearchResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class DashboardResponse {
  bool success;
  DashboardResponseData data;

  DashboardResponse({
    required this.success,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'],
      data: DashboardResponseData.fromJson(json['data']),
    );
  }
}

class DashboardResponseData {
  int totalUsers;
  int totalSubAdmins;
  int totalPendingRequests;
  int totalGroups;
  int totalMessages;
  int totalRiskAssessments;

  DashboardResponseData({
    required this.totalUsers,
    required this.totalSubAdmins,
    required this.totalPendingRequests,
    required this.totalGroups,
    required this.totalMessages,
    required this.totalRiskAssessments,
  });

  factory DashboardResponseData.fromJson(Map<String, dynamic> json) {
    return DashboardResponseData(
      totalUsers: json['totalUsers'],
      totalSubAdmins: json['totalSubAdmins'],
      totalPendingRequests: json['totalPendingRequests'],
      totalGroups: json['totalGroups'],
      totalMessages: json['totalMessages'],
      totalRiskAssessments: json['totalRiskAssessments'],
    );
  }
}

class GetGroupsResponse {
  bool success;
  List<GetGroupsResponseData> data;
  int totalPages;

  GetGroupsResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetGroupsResponse.fromJson(Map<String, dynamic> json) {
    return GetGroupsResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((v) => GetGroupsResponseData.fromJson(v))
          .toList(),
      totalPages: json['totalPages'],
    );
  }
}

class GetGroupsResponseData {
  int id;
  String? avatar;
  String name;
  List<dynamic> members;
  DateTime createdAt;

  GetGroupsResponseData({
    required this.id,
    required this.avatar,
    required this.name,
    required this.members,
    required this.createdAt,
  });

  factory GetGroupsResponseData.fromJson(Map<String, dynamic> json) {
    return GetGroupsResponseData(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      members: json['members'],
      createdAt: DateTime.parse(json['createdAt']),
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
        json['files'].map((file) => Files.fromJson(file)),
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
    print("JSON for Read: $json"); // Add this line
    return Read(
      id: json['id'],
      user: User.fromJson(json['user']),
      reply: json['reply'],
      mode: json['mode'],
      readAt: DateTime.parse(json['readAt']),
    );
  }

  // factory Read.fromJson(Map<String, dynamic> json) {
  //   return Read(
  //     id: json['id'],
  //     user: User.fromJson(json['user']),
  //     reply: json['reply'],
  //     mode: json['mode'],
  //     readAt: DateTime.parse(json['readAt']),
  //   );
  // }
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

class GetMessagesResponse {
  bool success;
  List<GetMessagesResponseData> data;
  int totalPages;

  GetMessagesResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetMessagesResponse.fromJson(Map<String, dynamic> json) {
    return GetMessagesResponse(
      success: json['success'],
      totalPages: json['totalPages'],
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
    required this.timer,
    required this.files,
    required this.createdBy,
    required this.createdAt,
  });

  factory GetMessagesResponseData.fromJson(Map<String, dynamic> json) {
    return GetMessagesResponseData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      messUserID:json['messUserID'],
      timer: json['timer'],
      files: List<Files>.from(
        json['files'].map((file) => Files.fromJson(file)),
      ),
      createdBy: CreatedBy.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt']),
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
    print("JSON for Files: $json"); // Add this line
    return Files(
      name: json['name'],
      fileType: json['fileType'],
    );
  }

  // factory Files.fromJson(Map<String, dynamic> json) {
  //   return Files(
  //     name: json['name'],
  //     fileType: json['fileType'],
  //   );
  // }
}

class CreatedBy {
  int id;
  String avatar;
  String name;

  CreatedBy({
    required this.id,
    required this.avatar,
    required this.name,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
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
  final String name;
  final String avatar;
  final String email;
  final String? reply;
  final String? mode;
  final DateTime? readAt;

  ReadStatusUser({
    required this.name,
    required this.avatar,
    required this.email,
    required this.reply,
    required this.mode,
    required this.readAt,
  });

  factory ReadStatusUser.fromJson(Map<String, dynamic> json) {
    return ReadStatusUser(
      name: json['name'],
      avatar: json['avatar'],
      email: json['email'],
      mode: json['mode'],
      reply: json['reply'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }
}

class MessageChangesResponse {
  final bool success;
  final List<MessageChangeData> data;

  MessageChangesResponse({
    required this.success,
    required this.data,
  });

  factory MessageChangesResponse.fromJson(Map<String, dynamic> json) {
    return MessageChangesResponse(
      success: json['success'],
      data: List<MessageChangeData>.from(
        json['data'].map((change) => MessageChangeData.fromJson(change)),
      ),
    );
  }
}

class MessageChangeData {
  final int userId;
  final String name;
  final String email;
  final List<MessageChangesRead> reads;

  MessageChangeData({
    required this.userId,
    required this.name,
    required this.email,
    required this.reads,
  });

  factory MessageChangeData.fromJson(Map<String, dynamic> json) {
    return MessageChangeData(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      reads: List<MessageChangesRead>.from(
        json['reads'].map((read) => MessageChangesRead.fromJson(read)),
      ),
    );
  }
}

class MessageChangesRead {
  final int id;
  final int messageId;
  final int userId;
  final String reply;
  final String mode;
  final DateTime readAt;
  final MessageChangesUser user;

  MessageChangesRead({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.reply,
    required this.mode,
    required this.readAt,
    required this.user,
  });

  factory MessageChangesRead.fromJson(Map<String, dynamic> json) {
    return MessageChangesRead(
      id: json['id'],
      messageId: json['messageId'],
      userId: json['userId'],
      reply: json['reply'],
      mode: json['mode'],
      readAt: DateTime.parse(json['readAt']),
      user: MessageChangesUser.fromJson(json['user']),
    );
  }
}

class MessageChangesUser {
  final int id;
  final String avatar;
  final String name;
  final String email;

  MessageChangesUser({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
  });

  factory MessageChangesUser.fromJson(Map<String, dynamic> json) {
    return MessageChangesUser(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class FeedbackDashboardResponse {
  bool success;
  FeedbackDashboardData data;

  FeedbackDashboardResponse({
    required this.success,
    required this.data,
  });

  factory FeedbackDashboardResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackDashboardResponse(
      success: json['success'],
      data: FeedbackDashboardData.fromJson(json['data']),
    );
  }
}

class FeedbackDashboardData {
  final int totalFeedback;
  final int redFeedback;
  final int yellowFeedback;
  final int greenFeedback;
  final int inProgress;
  final int rejected;
  final int closed;
  final int closedWithoutAction;

  FeedbackDashboardData({
    required this.totalFeedback,
    required this.redFeedback,
    required this.yellowFeedback,
    required this.greenFeedback,
    required this.inProgress,
    required this.rejected,
    required this.closed,
    required this.closedWithoutAction,
  });

  factory FeedbackDashboardData.fromJson(Map<String, dynamic> json) {
    return FeedbackDashboardData(
      totalFeedback: json['totalFeedback'],
      redFeedback: json['redFeedback'],
      yellowFeedback: json['yellowFeedback'],
      greenFeedback: json['greenFeedback'],
      inProgress: json['inProgress'],
      rejected: json['rejected'],
      closed: json['closed'],
      closedWithoutAction: json['closedWithoutAction'],
    );
  }
}

class GetSearchUsersToAssignResponse {
  bool success;
  List<GetSearchUsersToAssignData> data;

  GetSearchUsersToAssignResponse({
    required this.success,
    required this.data,
  });

  factory GetSearchUsersToAssignResponse.fromJson(Map<String, dynamic> json) {
    return GetSearchUsersToAssignResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => GetSearchUsersToAssignData.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class GetSearchUsersToAssignData {
  int id;
  String name;
  String email;
  String avatar;
  String phone;
  String department;
  String employeeNumber;
  UserType type;

  GetSearchUsersToAssignData({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.phone,
    required this.department,
    required this.employeeNumber,
    required this.type,
  });

  factory GetSearchUsersToAssignData.fromJson(Map<String, dynamic> json) {
    return GetSearchUsersToAssignData(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      phone: json['phone'] as String,
      department: json['department'] as String,
      employeeNumber: json['employeeNumber'] as String,
      type: UserType.fromName(json['type']),
    );
  }
}

class FeedbackUserAssignResponse {
  bool success;
  FeedbackUserAssignData data;

  FeedbackUserAssignResponse({
    required this.success,
    required this.data,
  });

  factory FeedbackUserAssignResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackUserAssignResponse(
      success: json['success'],
      data: FeedbackUserAssignData.fromJson(json['data']),
    );
  }
}

class FeedbackUserAssignData {
  int id;
  String location;
  String organizationName;
  String date;
  String time;
  String feedback;
  String source;
  String color;
  String selectedValues;
  String description;
  List<FeedbackFile> files;
  String reportedBy;
  String? responsiblePerson;
  List<FeedbackAssignment> feedbackAssignments;
  String? actionTaken;
  String? status;
  int createdById;
  String createdAt;
  FeedbackUser createdBy;

  FeedbackUserAssignData({
    required this.id,
    required this.location,
    required this.organizationName,
    required this.date,
    required this.time,
    required this.feedback,
    required this.source,
    required this.color,
    required this.selectedValues,
    required this.description,
    required this.files,
    required this.reportedBy,
    required this.responsiblePerson,
    required this.actionTaken,
    required this.feedbackAssignments,
    required this.status,
    required this.createdById,
    required this.createdAt,
    required this.createdBy,
  });

  factory FeedbackUserAssignData.fromJson(Map<String, dynamic> json) {
    return FeedbackUserAssignData(
      id: json['id'],
      location: json['location'],
      organizationName: json['organizationName'],
      date: json['date'],
      time: json['time'],
      feedback: json['feedback'],
      source: json['source'],
      color: json['color'],
      selectedValues: json['selectedValues'],
      description: json['description'],
      files: List<FeedbackFile>.from(
        json['files'].map((x) => FeedbackFile.fromJson(x)),
      ),
      feedbackAssignments: List<FeedbackAssignment>.from(
        json['feedbackAssignments'].map((x) => FeedbackAssignment.fromJson(x)),
      ),
      reportedBy: json['reportedBy'],
      responsiblePerson: json['responsiblePerson'],
      actionTaken: json['actionTaken'],
      status: json['status'],
      createdById: json['createdById'],
      createdAt: json['createdAt'],
      createdBy: FeedbackUser.fromJson(json['createdBy']),
    );
  }
}

class FeedbackAssignment {
  int id;
  bool assignmentCompleted;
  int feedbackId;
  int userId;
  FeedbackUser user;

  FeedbackAssignment({
    required this.id,
    required this.assignmentCompleted,
    required this.feedbackId,
    required this.userId,
    required this.user,
  });

  factory FeedbackAssignment.fromJson(Map<String, dynamic> json) {
    return FeedbackAssignment(
      id: json['id'] as int,
      assignmentCompleted: json['assignmentCompleted'] as bool,
      feedbackId: json['feedbackId'] as int,
      userId: json['userId'] as int,
      user: FeedbackUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class FeedbackUser {
  int id;
  String avatar;
  String name;
  String email;

  FeedbackUser({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
  });

  factory FeedbackUser.fromJson(Map<String, dynamic> json) {
    return FeedbackUser(
      id: json['id'] as int,
      avatar: json['avatar'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class GetFeedbacksResponse {
  bool success;
  List<GetFeedbacksResponseData> data;
  int totalPages;

  GetFeedbacksResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetFeedbacksResponse.fromJson(Map<String, dynamic> json) {
    return GetFeedbacksResponse(
      success: json['success'],
      data: List<GetFeedbacksResponseData>.from(
        json['data'].map((x) => GetFeedbacksResponseData.fromJson(x)),
      ),
      totalPages: json['totalPages'],
    );
  }
}

class FeedbackFile {
  int id;
  String fileType;
  String name;

  FeedbackFile({
    required this.id,
    required this.fileType,
    required this.name,
  });

  factory FeedbackFile.fromJson(Map<String, dynamic> json) {
    return FeedbackFile(
      id: json['id'] as int,
      fileType: json['fileType'] as String,
      name: json['name'] as String,
    );
  }
}

class GetFeedbacksResponseData {
  int id;
  String location;
  String organizationName;
  String date;
  String time;
  String feedback;
  String source;
  String color;
  String selectedValues;
  String description;
  List<FeedbackFile> files;
  String reportedBy;
  String? responsiblePerson;
  String? actionTaken;
  String? acknowledgement;
  Status? status;
  List<FeedbackAssignment> feedbackAssignments;
  int createdById;
  DateTime createdAt;
  List<FeedbackFile> actionFiles;
  FeedbackCreatedBy createdBy;

  GetFeedbacksResponseData({
    required this.id,
    required this.location,
    required this.organizationName,
    required this.date,
    required this.time,
    required this.feedback,
    required this.source,
    required this.color,
    required this.selectedValues,
    required this.description,
    required this.files,
    required this.reportedBy,
    required this.responsiblePerson,
    required this.actionTaken,
    required this.acknowledgement,
    required this.createdById,
    required this.feedbackAssignments,
    required this.status,
    required this.createdAt,
    required this.actionFiles,
    required this.createdBy,
  });

  factory GetFeedbacksResponseData.fromJson(Map<String, dynamic> json) {
    return GetFeedbacksResponseData(
      id: json['id'],
      location: json['location'],
      organizationName: json['organizationName'],
      date: json['date'],
      time: json['time'],
      feedback: json['feedback'],
      source: json['source'],
      color: json['color'],
      selectedValues: json['selectedValues'],
      description: json['description'],
      files: List<FeedbackFile>.from(
        json['files'].map((x) => FeedbackFile.fromJson(x)),
      ),
      actionFiles: List<FeedbackFile>.from(
        json['actionFiles'].map((x) => FeedbackFile.fromJson(x)),
      ),
      reportedBy: json['reportedBy'],
      responsiblePerson: json['responsiblePerson'],
      actionTaken: json['actionTaken'],
      acknowledgement: json['userAcknowledgement'],
      status: Status.fromName(json['status']),
      feedbackAssignments: List<FeedbackAssignment>.from(
        json['feedbackAssignments'].map((x) => FeedbackAssignment.fromJson(x)),
      ),
      createdById: json['createdById'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: FeedbackCreatedBy.fromJson(json['createdBy']),
    );
  }
}

class FeedbackCreatedBy {
  int id;
  String avatar;
  String name;
  String email;
  String phone;

  FeedbackCreatedBy({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory FeedbackCreatedBy.fromJson(Map<String, dynamic> json) {
    return FeedbackCreatedBy(
      id: json['id'],
      avatar: json['avatar'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

enum Status {
  inProgress,
  rejected,
  closed,
  closedWithoutAction;

  static Status? fromName(String? name) {
    if (name == null) {
      return null;
    }

    for (Status enumVariant in Status.values) {
      if (enumVariant.name == name) return enumVariant;
    }

    throw UnsupportedError(
      "Unsupported string '$name' cannot convert to Status",
    );
  }
}
