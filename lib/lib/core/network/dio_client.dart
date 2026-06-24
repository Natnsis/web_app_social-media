import 'package:dio/dio.dart';
import 'package:faithconnect/core/config/env_config.dart';
import 'package:faithconnect/core/network/auth_interceptor.dart';
import 'package:faithconnect/core/network/auth_session_coordinator.dart';
import 'package:faithconnect/core/network/auth_token_refresh_service.dart';

/// Shared [Dio] instance for REST calls (base URL from [EnvConfig]).
abstract final class DioClient {
  DioClient._();

  static Dio createBase() {
    final config = EnvConfig.instance;
    return Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  static Dio create({
    required AuthTokenRefreshService tokenRefresh,
    required AuthSessionCoordinator sessionCoordinator,
  }) {
    final config = EnvConfig.instance;
    final dio = createBase();

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenRefresh: tokenRefresh,
        sessionCoordinator: sessionCoordinator,
      ),
    );

    if (config.enableLogs) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  }
}
