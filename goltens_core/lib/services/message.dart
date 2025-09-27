import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/models/common.dart';
import 'package:goltens_core/models/message.dart';
import 'package:goltens_core/services/common.dart';

class MessageService {
  static Future<GetMessagesResponse> getMessages(
    int groupId,
    int page,
    int limit,
    String filter,
    String query,
  ) async {
    try {
      final url = '$apiUrl/message/$groupId';
      final dio = await getDioClient();

      final response = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'filter': filter,
          'query': query,
        },
      );

      return GetMessagesResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetMessageResponse> getMessage(
    int messageId,
  ) async {
    try {
      final url = '$apiUrl/message/detail/$messageId';
      print(url);
      final dio = await getDioClient();
      final response = await dio.get(url);
      return GetMessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageStatusResponse> getMessageReadStatus(
    int messageId,
    int groupId,
  ) async {
    try {
      final url = '$apiUrl/message/read-status/$messageId/$groupId';
      final dio = await getDioClient();
      final response = await dio.get(url);
      return MessageStatusResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetMessagesResponseData> createMessage(
    int groupId,
    String title,
    String content,
    int timer,
    List<Map<String, dynamic>> filesArr,
    String? messUserId,
  ) async {
    try {
      final url = '$apiUrl/message/$groupId?messUserId=${messUserId!=null?messUserId:""}';
      final dio = await getDioClient();

      print(url);
      print(groupId);
      String types = '';

      for (var e in filesArr) {
        types += "${e['type'].toString().split('.').last},";
      }

      var data = FormData.fromMap({
        'title': title,
        'content': content,
        'timer': timer,
        'types': types,
      });

      if (kIsWeb) {
        for (var file in filesArr) {
          data.files.addAll([
            MapEntry(
              "files",
              MultipartFile.fromBytes(
                file['file'].bytes,
                filename: file['file'].name,
              ),
            ),
          ]);
        }
      } else {
        for (var file in filesArr) {
          data.files.add(
            MapEntry(
              'files',
              MultipartFile.fromFileSync(file['file'].path),
            ),
          );
        }
      }

      final response = await dio.post(
        url,
        data: data,
      );

      return GetMessagesResponseData.fromJson(response.data['data']);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> readMessage(
    int messageId,
    int groupId,
    String? reply,
    String? mode,
  ) async {
    try {
      final url = '$apiUrl/message/$messageId/read/$groupId';
      final dio = await getDioClient();

      final response = await dio.put(
        url,
        data: {
          'reply': reply,
          'mode': mode,
        },
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteMessage(
    int messageId,
  ) async {
    try {
      final url = '$apiUrl/message/$messageId';
      final dio = await getDioClient();
      final response = await dio.delete(url);
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateMessage(
    int messageId,
    String title,
    String content,
    int timer,
    List<Files> files,
  ) async {
    try {
      final url = '$apiUrl/message/$messageId';
      final dio = await getDioClient();

      // Only removes existing files in a message
      // but does not support adding files to an existing message
      final response = await dio.put(
        url,
        data: {
          'title': title,
          'content': content,
          'timer': timer,
          'files': files
              .map(
                (file) => ({
                  'name': file.name,
                  'fileType': file.fileType,
                }),
              )
              .toList(),
        },
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }
}
