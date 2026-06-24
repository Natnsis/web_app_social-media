import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/auth_session_coordinator.dart';
import 'package:faithconnect/core/network/auth_token_provider.dart';
import 'package:faithconnect/core/network/auth_token_refresh_service.dart';

/// Attaches access tokens and refreshes on 401 using [AuthTokenRefreshService].
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required AuthTokenRefreshService tokenRefresh,
    required AuthSessionCoordinator sessionCoordinator,
  })  : _dio = dio,
        _tokenRefresh = tokenRefresh,
        _sessionCoordinator = sessionCoordinator;

  final Dio _dio;
  final AuthTokenRefreshService _tokenRefresh;
  final AuthSessionCoordinator _sessionCoordinator;

  static const _publicPaths = [
    AuthApiEndpoint.login,
    AuthApiEndpoint.register,
    AuthApiEndpoint.otpResend,
    AuthApiEndpoint.otpVerify,
    AuthApiEndpoint.passwordForgot,
    AuthApiEndpoint.passwordReset,
    AuthApiEndpoint.refresh,
    AuthApiEndpoint.loginGoogle,
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicPath(_requestPath(options))) {
      final token = await AuthTokenProvider.getAccessToken();
      if (token == null || token.isEmpty) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Please sign in to continue.',
          ),
        );
        return;
      }
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  static String _requestPath(RequestOptions options) {
    final path = options.uri.path;
    if (path.isNotEmpty) return path;
    final raw = options.path;
    return raw.startsWith('/') ? raw : '/$raw';
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final shouldRefresh = status == 401 &&
        !_isPublicPath(_requestPath(err.requestOptions)) &&
        err.requestOptions.extra['_retried'] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    try {
      final newToken = await _tokenRefresh.refreshAccessToken();
      if (newToken == null || newToken.isEmpty) {
        await _sessionCoordinator.handleSessionExpired();
        handler.next(err);
        return;
      }

      final retryOptions = err.requestOptions;
      AuthTokenProvider.setAccessToken(newToken);
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      retryOptions.extra['_retried'] = true;

      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _sessionCoordinator.handleSessionExpired();
      handler.next(err);
    }
  }

  bool _isPublicPath(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    for (final public in _publicPaths) {
      if (normalized == public || normalized.endsWith(public)) {
        return true;
      }
    }
    return false;
  }
}
