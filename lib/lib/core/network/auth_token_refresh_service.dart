import 'package:dio/dio.dart';
import 'package:faithconnect/core/config/env_config.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/auth_token_provider.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/auth/data/dto/auth_session_mapper.dart';
import 'package:faithconnect/features/auth/data/dto/refresh_token_request_dto.dart';

/// Calls `POST /v1/auth/refresh` without the auth interceptor (avoids loops).
class AuthTokenRefreshService {
  AuthTokenRefreshService() : _dio = _createRefreshDio();

  final Dio _dio;
  Future<String?>? _inFlight;

  static Dio _createRefreshDio() {
    final config = EnvConfig.instance;
    return Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Returns a new access token, or null if refresh is not possible.
  Future<String?> refreshAccessToken() {
    _inFlight ??= _performRefresh();
    return _inFlight!.whenComplete(() => _inFlight = null);
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await SharedPrefsService.getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return null;
    }

    try {
      final response = await _dio.post<dynamic>(
        AuthApiEndpoint.refresh,
        data: RefreshTokenRequestDto(refreshToken: refreshToken).toJson(),
      );

      final tokens = AuthSessionPayload.parseTokensFromResponse(response.data);
      if (tokens.accessToken == null || tokens.accessToken!.isEmpty) {
        throw const AuthException('Invalid refresh response');
      }

      await SharedPrefsService.saveTokens(
        accessToken: tokens.accessToken!,
        refreshToken: tokens.refreshToken,
      );
      AuthTokenProvider.setAccessToken(tokens.accessToken);

      return tokens.accessToken;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
