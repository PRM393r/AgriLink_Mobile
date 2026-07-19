import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/token_storage.dart';

class ApiService {
  late final Dio _dio;
  Future<String?>? _refreshFuture;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Inject Bearer Token to outgoing requests automatically
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (await _canRetryWithRefreshToken(e)) {
            try {
              final newToken = await _refreshAccessToken();
              if (newToken != null && newToken.isNotEmpty) {
                final retryOptions = e.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newToken';
                retryOptions.extra['retriedAfterRefresh'] = true;

                final retryResponse = await _dio.fetch<dynamic>(retryOptions);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              await TokenStorage.clearAll();
            }
          }

          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: _readableErrorMessage(e),
            ),
          );
        },
      ),
    );
  }

  Dio get client => _dio;

  Future<bool> _canRetryWithRefreshToken(DioException e) async {
    if (e.response?.statusCode != 401) return false;
    if (e.requestOptions.path == ApiConstants.refresh) return false;
    if (e.requestOptions.extra['retriedAfterRefresh'] == true) return false;

    final refreshToken = await TokenStorage.getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  Future<String?> _refreshAccessToken() {
    _refreshFuture ??= _performRefreshAccessToken();
    return _refreshFuture!.whenComplete(() => _refreshFuture = null);
  }

  Future<String?> _performRefreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final response = await refreshDio.post<Map<String, dynamic>>(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final newAccess = data?['accessToken'] as String? ?? '';
    final newRefresh = data?['refreshToken'] as String? ?? '';

    if (newAccess.isEmpty) return null;
    await TokenStorage.saveToken(newAccess);
    if (newRefresh.isNotEmpty) {
      await TokenStorage.saveRefreshToken(newRefresh);
    }
    return newAccess;
  }

  // Firebase Phone /auth/sync was removed from the product auth path
  // (email + password + email OTP). Backend endpoint may still exist as legacy.

  String _readableErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] is List) {
          return (data['message'] as List).join('\n');
        }
        if (data['message'] is String) {
          return data['message'] as String;
        }
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Lỗi kết nối mạng: Quá thời gian chờ';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến máy chủ';
    }
    return 'Đã xảy ra lỗi hệ thống';
  }

  // Generic helpers for REST API calls

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      );
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      );
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      );
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      );
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: e.toString(),
      );
    }
  }
}
