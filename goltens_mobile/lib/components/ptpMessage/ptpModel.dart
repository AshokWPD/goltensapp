import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:goltens_mobile/components/ptpMessage/ptpmessageServer.dart';

class PtpMessage {
  int? id;
  String fromID;
  String toID;
  String message;
  String dateTime;
  String? replay;
  bool isRead;
  DateTime? createdAt;
  DateTime? updatedAt;

  PtpMessage({
    this.id,
    required this.fromID,
    required this.toID,
    required this.message,
    required this.dateTime,
    this.replay,
    required this.isRead,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method for creating a new PtpMessage for API requests
  factory PtpMessage.forApiCreation({
    required String fromID,
    required String toID,
    required String message,
    required String dateTime,
    String? replay,
    required bool isRead,
  }) {
    return PtpMessage(
      fromID: fromID,
      toID: toID,
      message: message,
      dateTime: dateTime,
      replay: replay,
      isRead: isRead,
    );
  }

  // From Map (for deserializing)
  factory PtpMessage.fromMap(Map<String, dynamic> map) {
    return PtpMessage(
      id: map['id'],
      fromID: map['fromID'],
      toID: map['toID'],
      message: map['message'],
      dateTime: map['dateTime'],
      replay: map['replay'],
      isRead: map['isread'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // To Map (for serializing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromID': fromID,
      'toID': toID,
      'message': message,
      'dateTime': dateTime,
      'replay': replay,
      'isread': isRead,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // To Map for API creation (excludes id, createdAt, updatedAt)
  Map<String, dynamic> toCreationMap() {
    return {
      'fromID': fromID,
      'toID': toID,
      'message': message,
      'dateTime': DateTime.now().toString(),
      'replay': "",
      'isread': false,
    };
  }
}

class ChatState {
  final List<PtpMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<PtpMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final PtpMessageService _repository;

  ChatNotifier(this._repository) : super(ChatState());

  Future<void> fetchMessages(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final messages = await _repository.getNewestPtpMessages(id);
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(PtpMessageService());
});








// class PtpMessage {
//   int id;
//   String fromID;
//   String toID;
//   String message;
//   String dateTime;
//   String? replay;
//   bool isRead;
//   DateTime createdAt;
//   DateTime updatedAt;

//   PtpMessage({
//     required this.id,
//     required this.fromID,
//     required this.toID,
//     required this.message,
//     required this.dateTime,
//     this.replay,
//     required this.isRead,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   // From Map (for deserializing)
//   factory PtpMessage.fromMap(Map<String, dynamic> map) {
//     return PtpMessage(
//       id: map['id'],
//       fromID: map['fromID'],
//       toID: map['toID'],
//       message: map['message'],
//       dateTime: map['dateTime'],
//       replay: map['replay'],
//       isRead: map['isread'],
//       createdAt: DateTime.parse(map['createdAt']),
//       updatedAt: DateTime.parse(map['updatedAt']),
//     );
//   }

//   // To Map (for serializing)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'fromID': fromID,
//       'toID': toID,
//       'message': message,
//       'dateTime': dateTime,
//       'replay': replay,
//       'isread': isRead,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
// }
