import 'package:dio/dio.dart';
import 'package:goltens_core/models/common.dart';

String handleDioError(Object e) {
  var dioException = e as DioError;
  var errorResponse = ErrorResponse.fromJson(dioException.response?.data);
  throw errorResponse.error;
}
