// ignore_for_file: prefer_const_declarations

import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/models/other_files.dart';

class OtherFilesService {
  static Future<GetOtherFilesResponse> getOtherFilesItems(
    int page,
    int limit,
    String? search,
  ) async {
    try {
      final url = '$apiUrl/other-file/';
      final dio = await getDioClient();

      final response = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetOtherFilesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
