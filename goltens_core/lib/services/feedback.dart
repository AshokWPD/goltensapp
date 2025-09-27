import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/models/common.dart';
import 'package:goltens_core/models/feedback.dart';
import 'package:goltens_core/services/common.dart';

class FeedbackService {
  static Future<FeedbackDashboardResponse> getFeedbackDashboardData() async {
    try {
      const url = '$apiUrl/feedback/dashboard';
      final dio = await getDioClient();

      var res = await dio.get(url);
      return FeedbackDashboardResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<FeedbackDrawerResponse> getFeedbackDrawerData() async {
    try {
      const url = '$apiUrl/feedback/drawer-data';
      final dio = await getDioClient();

      var res = await dio.get(url);
      return FeedbackDrawerResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetFeedbacksResponse> getFeedbacks({
    required int page,
    required int limit,
    required String? filter,
  }) async {
    try {
      const url = '$apiUrl/feedback/';
      final dio = await getDioClient();

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'filter': filter,
        },
      );

      return GetFeedbacksResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<CreateFeedbackResponse> createFeedback(
    String location,
    String organizationName,
    String date,
    String time,
    String feedback,
    String source,
    String color,
    String selectedValues,
    String description,
    List<Map<String, dynamic>> filesArr,
    String reportedBy,
  ) async {
    try {
      String url = '$apiUrl/feedback/';
      final dio = await getDioClient();
      String types = '';

      for (var e in filesArr) {
        types += "${e['type'].toString().split('.').last},";
      }

      var data = FormData.fromMap({
        'location': location,
        'organizationName': organizationName,
        'date': date,
        'time': time,
        'feedback': feedback,
        'source': source,
        'color': color,
        'selectedValues': selectedValues,
        'types': types,
        'description': description,
        'reportedBy': reportedBy,
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

      return CreateFeedbackResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetFeedbacksResponse> getAssignedFeedbacks({
    required int page,
    required int limit,
  }) async {
    try {
      const url = '$apiUrl/feedback/assigned';
      final dio = await getDioClient();

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return GetFeedbacksResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> completeFeedbackAssignment({
    required int feedbackId,
    required String actionTaken,
    required List<Map<String, dynamic>> filesArr,
  }) async {
    try {
      String url = '$apiUrl/feedback/complete/$feedbackId';
      final dio = await getDioClient();
      String types = '';

      // Construct the types string
      for (var e in filesArr) {
        types += "${e['type'].toString().split('.').last},";
      }

      // Create FormData object with actionTaken and types
      final data = FormData.fromMap({
        'actionTaken': actionTaken,
        'types': types,
      });

      // Add files to FormData
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

      // Send the request
      final response = await dio.put(
        url,
        data: data,
      );
      print(response.data.toString());

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  // static Future<MessageResponse> completeFeedbackAssignment({
  //   required int feedbackId,
  //   required String actionTaken,
  //   required List<Map<String, dynamic>> filesArr,
  // }) async {
  //   try {
  //     String url = '$apiUrl/feedback/complete/$feedbackId';
  //     final dio = await getDioClient();
  //     String types = '';

  //     final data = FormData.fromMap({
  //       'actionTaken': actionTaken,
  //       'types': types,
  //     });

  //     for (var e in filesArr) {
  //       types += "${e['type'].toString().split('.').last},";
  //     }

  //     if (kIsWeb) {
  //       for (var file in filesArr) {
  //         data.files.addAll([
  //           MapEntry(
  //             "files",
  //             MultipartFile.fromBytes(
  //               file['file'].bytes,
  //               filename: file['file'].name,
  //             ),
  //           ),
  //         ]);
  //       }
  //     } else {
  //       for (var file in filesArr) {
  //         data.files.add(
  //           MapEntry(
  //             'files',
  //             MultipartFile.fromFileSync(file['file'].path),
  //           ),
  //         );
  //       }
  //     }

  //     final response = await dio.put(
  //       url,
  //       data: data,
  //     );
  //     print(response.data.toString());

  //     return MessageResponse.fromJson(response.data);
  //   } catch (e) {
  //     handleDioError(e);
  //     rethrow;
  //   }
  // }

  static Future<MessageResponse> sendAcknowledgement({
    required int feedbackId,
    required String acknowledgement,
  }) async {
    try {
      final url = '$apiUrl/feedback/send-acknowledgement/$feedbackId';
      final dio = await getDioClient();

      var res = await dio.put(
        url,
        data: {'acknowledgement': acknowledgement},
      );
      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }
}
