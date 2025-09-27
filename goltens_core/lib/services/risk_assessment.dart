import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/risk_assessment.dart';

class RiskAssessmentService {
  static Future<GetAssessmentsResponse> getRiskAssessmentItems(
    int page,
    int limit,
    int groupId,
    String? search,
  ) async {
    try {
      final url = '$apiUrl/risk-assessment/$groupId';
      final dio = await getDioClient();

      final response = await dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );

      return GetAssessmentsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
