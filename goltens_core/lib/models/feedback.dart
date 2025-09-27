class FeedbackDashboardResponse {
  final bool success;
  final FeedbackDashboardData data;

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
  final int totalFeedbacks;
  final int redFeedbacks;
  final int yellowFeedbacks;
  final int greenFeedbacks;

  FeedbackDashboardData({
    required this.totalFeedbacks,
    required this.redFeedbacks,
    required this.yellowFeedbacks,
    required this.greenFeedbacks,
  });

  factory FeedbackDashboardData.fromJson(Map<String, dynamic> json) {
    return FeedbackDashboardData(
      totalFeedbacks: json['totalFeedbacks'],
      redFeedbacks: json['redFeedbacks'],
      yellowFeedbacks: json['yellowFeedbacks'],
      greenFeedbacks: json['greenFeedbacks'],
    );
  }
}

class FeedbackDrawerResponse {
  bool success;
  FeedbackDrawerData data;

  FeedbackDrawerResponse({
    required this.success,
    required this.data,
  });

  factory FeedbackDrawerResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackDrawerResponse(
      success: json['success'] as bool,
      data: FeedbackDrawerData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class FeedbackDrawerData {
  int assignedFeedbacks;

  FeedbackDrawerData({
    required this.assignedFeedbacks,
  });

  factory FeedbackDrawerData.fromJson(Map<String, dynamic> json) {
    return FeedbackDrawerData(
      assignedFeedbacks: json['assignedFeedbacks'] as int,
    );
  }
}

class GetFeedbacksResponse {
  bool success;
  List<FeedbackData> data;
  int totalPages;

  GetFeedbacksResponse({
    required this.success,
    required this.data,
    required this.totalPages,
  });

  factory GetFeedbacksResponse.fromJson(Map<String, dynamic> json) {
    return GetFeedbacksResponse(
      success: json['success'],
      data: List<FeedbackData>.from(
        json['data'].map((x) => FeedbackData.fromJson(x)),
      ),
      totalPages: json['totalPages'],
    );
  }
}

class CreateFeedbackResponse {
  bool success;
  FeedbackData data;

  CreateFeedbackResponse({
    required this.success,
    required this.data,
  });

  factory CreateFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return CreateFeedbackResponse(
      success: json['success'],
      data: FeedbackData.fromJson(json['data']),
    );
  }
}

class FeedbackData {
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
  List<FeedbackAssignment> feedbackAssignments;
  String reportedBy;
  String? responsiblePerson;
  String? actionTaken;
  String? acknowledgement;
  Status? status;
  int createdById;
  DateTime createdAt;
  List<FeedbackFile> actionFiles;
  FeedbackCreatedBy createdBy;

  FeedbackData({
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
    required this.status,
    required this.feedbackAssignments,
    required this.createdById,
    required this.createdAt,
    required this.actionFiles,
    required this.createdBy,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
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
      feedbackAssignments: List<FeedbackAssignment>.from(
        json['feedbackAssignments'].map((x) => FeedbackAssignment.fromJson(x)),
      ),
      reportedBy: json['reportedBy'],
      responsiblePerson: json['responsiblePerson'],
      actionTaken: json['actionTaken'],
      acknowledgement: json['userAcknowledgement'],
      status: Status.fromName(json['status']),
      createdById: json['createdById'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: FeedbackCreatedBy.fromJson(json['createdBy']),
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
