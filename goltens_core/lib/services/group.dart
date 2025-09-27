import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/models/common.dart';
import 'package:goltens_core/models/group.dart';
import 'package:goltens_core/services/common.dart';

class GroupService {
  static Future<GetAllGroupsResponse> getAllGroups(
    int page,
    int limit,
  ) async {
    try {
      const url = '$apiUrl/group/';
      final dio = await getDioClient();

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
print(res.data);
      return GetAllGroupsResponse.fromJson(res.data);
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
      final url = '$apiUrl/group/$id';
      var res = await dio.get(url);
      return GetGroupResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetMembersResponse> getMembers(
    int groupId,
  ) async {
    try {
      final url = '$apiUrl/group/$groupId/members';
      final dio = await getDioClient();

      var res = await dio.get(url);
      return GetMembersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<GetMembersResponse> searchUsersToAdd(
    int groupId,
    String searchQuery,
  ) async {
    try {
      final url = '$apiUrl/group/$groupId/search-users';
      final dio = await getDioClient();

      var res = await dio.get(
        url,
        queryParameters: {
          'search': searchQuery,
        },
      );

      return GetMembersResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> addMember(
    int groupId,
    int memberId,
  ) async {
    try {
      final url = '$apiUrl/group/$groupId/members';
      final dio = await getDioClient();

      var res = await dio.put(
        url,
        data: {
          'memberId': memberId,
        },
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> removeMember(
    int groupId,
    int memberId,
  ) async {
    try {
      final url = '$apiUrl/group/$groupId/members';
      final dio = await getDioClient();

      var res = await dio.delete(
        url,
        data: {
          'memberId': memberId,
        },
      );

      return MessageResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }
}
