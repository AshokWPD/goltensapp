import 'package:dio/dio.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/utils/dio.dart';
import 'package:goltens_core/models/common.dart';
import 'package:goltens_core/services/common.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goltens_core/models/auth.dart';

class AuthService {
  static Future<TokenResponse> login({
    required String email,
    required String password,
    required String? fcmToken,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/login';

      var data = {
        'email': email,
        'password': password,
        'fcmToken': fcmToken,
      };

      final response = await dio.post(url, data: data);
      var tokenResponse = TokenResponse.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenKey, tokenResponse.token);
      return tokenResponse;
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<TokenResponse> adminLogin({
    required String email,
    required String password,
    required String? fcmToken,
  }) async {
    try {
      const url = '$apiUrl/admin/login';
      final dio = await getDioClient();

      var response = await dio.post(
        url,
        data: {
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
        },
      );

      final tokenResponse = TokenResponse.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenKey, tokenResponse.token);
      return tokenResponse;
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<TokenResponse> register({
    required String name,
    required String email,
    required String phone,
    required String department,
    required String employeeNumber,
    required String password,
    required String? fcmToken,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/register';

      var data = {
        'name': name,
        'email': email,
        'phone': phone,
        'department': department,
        'employeeNumber': employeeNumber,
        'password': password,
        'fcmToken': fcmToken,
      };

      final response = await dio.post(url, data: data);
      var tokenResponse = TokenResponse.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenKey, tokenResponse.token);
      return tokenResponse;
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> logout() async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/logout';

      final response = await dio.get(url);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<UserResponse> getMe() async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/me';
      final response = await dio.get(url);
      return UserResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponseData> forgotPassword(
      String email,
      ) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/forgot-password';

      final response = await dio.post(
        url,
        data: {'email': email},
      );

      print(dio.toString());
      print('"email":"$email" $response');
      return MessageResponseData.fromJson(response.data);
    } catch (e) {
      handleDioError(e);

      print("ERROR+++++++++++: $e");
      rethrow;
    }
  }

  static Future<TokenResponse> resetPassword(
      String token,
      String password,
      ) async {
    try {
      final dio = await getDioClient();
      final url = '$apiUrl/auth/reset-password/$token';

      final response = await dio.post(
        url,
        data: {'password': password},
      );

      var tokenResponse = TokenResponse.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(tokenKey, tokenResponse.token);
      return tokenResponse;
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateDetails({
    required String name,
    required String phone,
    required String email,
    required String department,
    required String employeeNumber,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/update-details';

      final response = await dio.post(
        url,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'department': department,
          'employeeNumber': employeeNumber,
        },
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<TokenResponse> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/update-password';

      final response = await dio.post(
        url,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      final prefs = await SharedPreferences.getInstance();
      var tokenResponse = TokenResponse.fromJson(response.data);
      prefs.setString(tokenKey, tokenResponse.token);
      return tokenResponse;
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> updateAvatar({
    String? localFilePath,
    List<int>? byteArray,
    String? filename,
  }) async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/update-avatar';

      FormData data = FormData.fromMap({});

      if (byteArray != null) {
        data = FormData.fromMap({
          'avatar': MultipartFile.fromBytes(
            byteArray,
            filename: filename,
            contentType: MediaType('image', 'jpg'),
          )
        });
      }

      if (localFilePath != null) {
        data = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(localFilePath),
        });
      }

      final response = await dio.post(
        url,
        data: data,
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  static Future<MessageResponse> markAsInactive() async {
    try {
      final dio = await getDioClient();
      const url = '$apiUrl/auth/set-inactive';
      final response = await dio.get(url);
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      handleDioError(e);
      rethrow;
    }
  }
}