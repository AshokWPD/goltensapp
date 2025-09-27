import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:goltens_mobile/components/ptpMessage/ptpModel.dart';
import 'package:goltens_mobile/components/ptpMessage/ptpmessageServer.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final PtpMessageService _repository;
  Timer? _timer;

  ChatNotifier(this._repository) : super(ChatState());

  Future<void> fetchMessages(String id) async {
    try {
      final messages = await _repository.getNewestPtpMessages(id);
      state = state.copyWith(messages: messages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void startPolling(String id, {Duration interval = const Duration(seconds: 5)}) {
    _timer = Timer.periodic(interval, (_) => fetchMessages(id));
  }

  void stopPolling() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(PtpMessageService());
});
