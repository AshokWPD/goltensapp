import 'package:goltens_core/models/common.dart';
import 'package:goltens_core/models/user_orientation.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/constants/constants.dart';

class UserOrientationService {
  static Future<GetAllUserOrientationItemsResponse> getAllUserOrientationItems(
    int page,
    int limit,
    String? search,
  ) async {
    try {
      const url = '$apiUrl/user-orientation/';
      final dio = await getDioClient();

      final response = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetAllUserOrientationItemsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<MessageResponse> readUserOrientationItem(
    int id,
  ) async {
    try {
      final url = '$apiUrl/user-orientation/$id';
      final dio = await getDioClient();
      final response = await dio.post(url);
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
