
// import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/user_orientation.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/services/common.dart';
import 'package:goltens_core/models/admin.dart';
import 'package:goltens_core/models/common.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

class AdminService {
  static Future<PostAssessmentResponse> uploadRiskAssesment({
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
    required int groupId,
  }) async {
    try {
      const url = '$apiUrl/admin/risk-assessment/';
      final dio = await getDioClient();

      FormData data = FormData.fromMap({
        'groupId': groupId,
      });

      if (byteArray != null) {
        data.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(
              byteArray,
              filename: filename,
              contentType: MediaType('application', 'pdf'),
            ),
          ),
        );
      }

      if (localFilePath != null) {
        data.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(localFilePath),
          ),
        );
      }

      var res = await dio.post(
        url,
        data: data,
      );

      return PostAssessmentResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateRiskAssesment({
    required int id,
    required String name,
  }) async {
    try {
      final url = '$apiUrl/admin/risk-assessment/$id';
      final dio = await getDioClient();

      var res = await dio.put(
        url,
        data: {'name': name},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteRiskAssesment({
    required int id,
  }) async {
    try {
      final url = '$apiUrl/admin/risk-assessment/$id';
      final dio = await getDioClient();

      var res = await dio.delete(url);
      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<PostAssessmentResponse> uploadOtherFile({
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
  }) async {
    try {
      const url = '$apiUrl/admin/other-file';
      final dio = await getDioClient();

      FormData data = FormData.fromMap({});

      if (byteArray != null) {
        data = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            byteArray,
            filename: filename,
            contentType: MediaType('application', 'pdf'),
          )
        });
      }

      if (localFilePath != null) {
        data = FormData.fromMap({
          'file': await MultipartFile.fromFile(localFilePath),
        });
      }

      var res = await dio.post(
        url,
        data: data,
      );

      return PostAssessmentResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateOtherFile({
    required int id,
    required String name,
  }) async {
    try {
      final url = '$apiUrl/admin/other-file/$id';
      final dio = await getDioClient();

      var res = await dio.put(
        url,
        data: {'name': name},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteOtherFile({
    required int id,
  }) async {
    try {
      final url = '$apiUrl/admin/other-file/$id';
      final dio = await getDioClient();

      var res = await dio.delete(url);
      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUserOrientationItemResponse> getUserOrientationItem({
    required int id,
    required int page,
    required int limit,
  }) async {
    try {
      final url = '$apiUrl/admin/user-orientation/$id';
      final dio = await getDioClient();

      var res = await dio.get(url, queryParameters: {
        'page': page,
        'limit': limit,
      });

      return GetUserOrientationItemResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<PostAssessmentResponse> uploadUserOrientationItem({
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
  }) async {
    try {
      const url = '$apiUrl/admin/user-orientation';
      final dio = await getDioClient();

      FormData data = FormData.fromMap({});

      if (byteArray != null) {
        data = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            byteArray,
            filename: filename,
            contentType: MediaType('application', 'pdf'),
          )
        });
      }

      if (localFilePath != null) {
        data = FormData.fromMap({
          'file': await MultipartFile.fromFile(localFilePath),
        });
      }

      var res = await dio.post(
        url,
        data: data,
      );

      return PostAssessmentResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateUserOrientationItem({
    required int id,
    required String name,
  }) async {
    try {
      final url = '$apiUrl/admin/user-orientation/$id';
      final dio = await getDioClient();

      var res = await dio.put(
        url,
        data: {'name': name},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteUserOrientationItem({
    required int id,
  }) async {
    try {
      final url = '$apiUrl/admin/user-orientation/$id';
      final dio = await getDioClient();

      var res = await dio.delete(url);
      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUsersResponse> getUsers({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/users';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetUsersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUsersResponse> getUserswithsubAdmins({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/userWithSubadmins';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetUsersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> createUser({
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String department,
    required String employeeNumber,
    required UserType type,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/users/';

      var data = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'department': department,
        'employeeNumber': employeeNumber,
        'type': type.name,
      });

      if (byteArray != null) {
        data.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              byteArray,
              filename: filename,
              contentType: MediaType('image', 'jpg'),
            ),
          ),
        );
      }

      if (localFilePath != null) {
        data.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(localFilePath),
          ),
        );
      }

      var res = await dio.post(
        url,
        data: data,
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateUser({
    required int id,
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? department,
    bool? active,
    String? employeeNumber,
    required bool deleteAvatar,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/users/$id';

      var data = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'department': department,
        'active': active,
        'employeeNumber': employeeNumber,
        'deleteAvatar': deleteAvatar,
      });

      if (byteArray != null) {
        data.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              byteArray,
              filename: filename,
              contentType: MediaType('image', 'jpg'),
            ),
          ),
        );
      }

      if (localFilePath != null) {
        data.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(localFilePath),
          ),
        );
      }

      var res = await dio.put(
        url,
        data: data,
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteUsers({
    required List<int> userIds,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/users/';

      var res = await dio.delete(
        url,
        data: {'userIds': userIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteUserslist({
    required List<int> userIds,
    required bool deleteData,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/users/delete-account/';

      var res = await dio.post(
        url,
        data: {'userIds': userIds, 'deleteData': deleteData},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> makeUsersAsSubAdmins({
    required List<int> userIds,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/users/make-subadmins';

      var res = await dio.put(
        url,
        data: {'userIds': userIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> makeSubAdminsAsUsers({
    required List<int> subAdminIds,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/subadmins/make-users';

      var res = await dio.put(
        url,
        data: {'subAdminIds': subAdminIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUsersResponse> getSubAdmins({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/subadmins';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetUsersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUsersResponse> getUsersAndSubAdmins({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/user-subadmins';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetUsersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> makeUsersAsUserAndSubAdmins({
    required List<int> userIds,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/user-subadmins/make';

      var res = await dio.put(
        url,
        data: {'userIds': userIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUsersResponse> getPendingRequests({
    required int page,
    required int limit,
    required String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/pending-requests';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetUsersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateAdminApproved({
    required int id,
    required AdminApproved adminApproved,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/update-admin-approved/$id';

      var res = await dio.put(
        url,
        data: {'adminApproved': adminApproved.name},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<DashboardResponse> getDashboardData() async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/dashboard';

      var res = await dio.get(url);
      return DashboardResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetGroupsResponse> getGroups({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/groups';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetGroupsResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetGroupResponse> getGroup({
    required int id,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/groups/$id';

      var res = await dio.get(url);
      return GetGroupResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> addGroupMembers({
    required int groupId,
    required List<int> memberIds,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/group/$groupId/members';

      var res = await dio.put(
        url,
        data: {'memberIds': memberIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> removeGroupMembers({
    required int groupId,
    required List<int> memberIds,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/group/$groupId/members';

      var res = await dio.delete(
        url,
        data: {'memberIds': memberIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> makeGroupMembersAsSubAdmins({
    required int groupId,
    required List<int> memberIds,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/group/$groupId/make-subadmins';

      var res = await dio.put(
        url,
        data: {'memberIds': memberIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> makeSubAdminsAsGroupMembers({
    required int groupId,
    required List<int> subAdminIds,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/group/$groupId/make-members';

      var res = await dio.put(
        url,
        data: {'subAdminIds': subAdminIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetUsersResponse> searchUsersNotInGroup({
    required int groupId,
    required String searchTerm,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/group/$groupId/search-users';

      var res = await dio.get(
        url,
        queryParameters: {'search': searchTerm},
      );

      return GetUsersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetGroupSearchResponse> searchGroups({
    required String searchTerm,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/group/search';

      var res = await dio.get(
        url,
        queryParameters: {'search': searchTerm},
      );

      return GetGroupSearchResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> createGroup({
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
    required String name,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/groups/';

      var data = FormData.fromMap({
        'name': name,
      });

      if (byteArray != null) {
        data.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              byteArray,
              filename: filename,
              contentType: MediaType('image', 'jpg'),
            ),
          ),
        );
      }

      if (localFilePath != null) {
        data.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(localFilePath),
          ),
        );
      }

      var res = await dio.post(
        url,
        data: data,
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateGroup({
    required int id,
    required String name,
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
    required bool deleteAvatar,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/groups/$id';

      var data = FormData.fromMap({
        'name': name,
        'deleteAvatar': deleteAvatar,
      });

      if (byteArray != null) {
        data.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              byteArray,
              filename: filename,
              contentType: MediaType('image', 'jpg'),
            ),
          ),
        );
      }

      if (localFilePath != null) {
        data.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(localFilePath),
          ),
        );
      }

      var res = await dio.put(
        url,
        data: data,
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteGroup({
    required int groupId,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/groups/';

      var res = await dio.delete(
        url,
        data: {'groupId': groupId},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetMessagesResponse> getMessagesOfGroup({
    required int groupId,
    required int page,
    required int limit,
    required String? search,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/message/$groupId';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetMessagesResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetMessageResponse> getMessage({
    required int messageId,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/message/detail/$messageId';

      var res = await dio.get(url);
      return GetMessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteMessage({
    required int messageId,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/message/$messageId';

      var res = await dio.delete(url);
      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> createMessage(
    List<int> groupIds,
    String title,
    String content,
    int timer,
    List<Map<String, dynamic>> filesArr,
    String? messUserId,
  ) async {
    try {
      final dio = await getDioClient();
      var url = '$apiUrl/admin/message/?messUserId=${messUserId ?? ""}';

      print(url);
      String types = '';
      String groupIdsString = '';

      for (var e in filesArr) {
        types += "${e['type'].toString().split('.').last},";
      }

      for (var groupId in groupIds) {
        groupIdsString += "$groupId,";
      }

      var data = FormData.fromMap({
        'groupIds': groupIdsString,
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

      var res = await dio.post(
        url,
        data: data,
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      print(e);
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
      final dio = await getDioClient();
      final url = '$apiUrl/admin/message/$messageId';

      var res = await dio.put(
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

      return MessageResponse.fromJson(res.data);
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
      final url = '$apiUrl/admin/message/read-status/$messageId/$groupId';
      final dio = await getDioClient();

      final response = await dio.get(url);
      return MessageStatusResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageChangesResponse> getMessageChanges(
    int messageId,
  ) async {
    try {
      final url = '$apiUrl/admin/message/changes/$messageId';
      final dio = await getDioClient();

      final response = await dio.get(url);
      return MessageChangesResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<FeedbackDashboardResponse> getFeedbackDashboardData() async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/feedback/dashboard';

      var res = await dio.get(url);
      return FeedbackDashboardResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetFeedbacksResponse> getFeedbacks({
    required int page,
    required int limit,
    required String? search,
    required String? color,
    required String? status,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/feedback';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
          'color': color,
          'status': status,
        },
      );

      return GetFeedbacksResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetSearchUsersToAssignResponse> searchUsersToAssignForFeedback({
    required String searchTerm,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/feedback/search/users';

      var res = await dio.get(
        url,
        queryParameters: {'search': searchTerm},
      );

      return GetSearchUsersToAssignResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<FeedbackUserAssignResponse> assignUserToFeedback({
    required int feedbackId,
    required int userId,
  }) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/admin/feedback/$feedbackId/assign-users';

      var res = await dio.put(
        url,
        data: {'userId': userId},
      );

      return FeedbackUserAssignResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> deleteFeedbacks({
    required List<int> feedbackIds,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/admin/feedback';

      var res = await dio.delete(
        url,
        data: {'feedbackIds': feedbackIds},
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateFeedback({
    required int id,
    required String responsiblePerson,
    required String actionTaken,
    required String status,
  }) async {
    try {
      final dio = await getDioClient();

      var res = await dio.put(
        '$apiUrl/admin/feedback/$id',
        data: {
          'responsiblePerson': responsiblePerson,
          'actionTaken': actionTaken,
          'status': status,
        },
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }
}
