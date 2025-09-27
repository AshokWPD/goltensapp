import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/master_list.dart';
import 'package:goltens_core/services/common.dart';
import 'package:goltens_core/utils/dio.dart';

class MasterListService {
  static Future<GetMasterListResponse> getMasterList({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/master-list';

      var res = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetMasterListResponse.fromJson(res.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }
}
