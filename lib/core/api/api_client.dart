import 'package:dio/dio.dart';

import '../config/app_environment.dart';
import '../session/auth_session.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required ApiConfig config,
    required this.session,
    Dio? dio,
  }) : _dio = dio ??
           Dio(
             BaseOptions(
               baseUrl: config.baseUrl.toString(),
               connectTimeout: const Duration(seconds: 12),
               receiveTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(seconds: 12),
               headers: const {
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = session.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.reject(error);
        },
      ),
    );
  }

  final Dio _dio;
  final AuthSession session;

  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> post<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    var message = 'Network is unavailable. Please try again.';
    String? code;

    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? message;
      code = data['code']?.toString();
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Connection timed out. Check the network and retry.';
      code = 'timeout';
    } else if (statusCode != null && statusCode >= 500) {
      message = 'Service is temporarily unavailable.';
      code = 'server_error';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: code,
    );
  }
}