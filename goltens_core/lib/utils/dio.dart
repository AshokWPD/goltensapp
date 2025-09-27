import 'package:dio/dio.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Dio> getDioClient() async {
  final dio = Dio();
  dio.options.baseUrl = apiUrl;
  dio.options.connectTimeout=Duration(milliseconds: 7000);
  dio.options.receiveTimeout = Duration(milliseconds: 7000);

  // Fetch Auth Token
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString(tokenKey);

  dio.options.headers = {
    'Authorization': 'Bearer $token',
  };


  return dio;
}
