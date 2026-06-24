import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/core/utils/phone_normalizer.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/auth/data/dto/auth_session_mapper.dart';
import 'package:faithconnect/features/auth/data/dto/forgot_password_request_dto.dart';
import 'package:faithconnect/features/auth/data/dto/google_auth_dto.dart';
import 'package:faithconnect/features/auth/data/dto/login_request_dto.dart';
import 'package:faithconnect/features/auth/data/dto/otp_resend_request_dto.dart';
import 'package:faithconnect/features/auth/data/dto/reset_password_request_dto.dart';
import 'package:faithconnect/features/auth/data/dto/otp_verify_request_dto.dart';
import 'package:faithconnect/features/auth/data/dto/register_request_dto.dart';
import 'package:faithconnect/features/auth/data/models/sign_up_response.dart';
import 'package:faithconnect/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> loginWithGoogle({
    required String idToken,
  });

  Future<SignUpResponse> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<void> resendOtp({required String phoneNumber});

  Future<void> requestPasswordReset({required String phoneNumber});

  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final emailOrPhone = PhoneNormalizer.normalizeEmailOrPhone(email);
    final request = LoginRequestDto(
      emailOrPhone: emailOrPhone,
      password: password,
    );

    try {
      final response = await _dio.post<dynamic>(
        AuthApiEndpoint.login,
        data: request.toJson(),
      );

      final session = AuthSessionPayload.fromResponse(
        response.data,
        loginFallback: LoginFallbackUser(emailOrPhone: emailOrPhone),
      );
      await session.persistTokens();
      return session.user;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithGoogle({
    required String idToken,
  }) async {
    const tag = 'AuthGoogle';
    final body = GoogleAuthDto(idToken: idToken).toJson();
    FaithLogger.i(
      tag,
      'POST ${AuthApiEndpoint.loginGoogle} body=$body',
    );

    try {
      final response = await _dio.post<dynamic>(
        AuthApiEndpoint.loginGoogle,
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final session = AuthSessionPayload.fromResponse(
        response.data,
        loginFallback: const LoginFallbackUser(emailOrPhone: ''),
      );

      if (!session.hasAccessToken) {
        FaithLogger.e(tag, 'Response missing access token body=${response.data}');
        throw const AuthException(
          'Google login failed: server did not return an access token.',
        );
      }

      FaithLogger.i(
        tag,
        'HTTP ${response.statusCode} — login success userId=${session.user.id} '
        'hasRefreshToken=${session.refreshToken?.isNotEmpty == true}',
      );
      await session.persistTokens();
      FaithLogger.d(tag, 'JWT persisted to secure storage');
      return session.user;
    } on DioException catch (e) {
      FaithLogger.e(
        tag,
        'API error status=${e.response?.statusCode} '
        'body=${e.response?.data}',
        e,
      );
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      FaithLogger.e(tag, 'Unexpected error', e);
      throw AuthException(e.toString());
    }
  }

  @override
  Future<SignUpResponse> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final request = RegisterRequestDto(
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phoneNumber: PhoneNormalizer.normalize(phoneNumber),
      password: password,
    );

    try {
      final response = await _dio.post<dynamic>(
        AuthApiEndpoint.register,
        data: request.toJson(),
      );

      final session = AuthSessionPayload.fromResponse(
        response.data,
        registerFallback: RegisterFallbackUser(
          fullName: request.fullName,
          email: request.email,
          phoneNumber: request.phoneNumber,
        ),
      );

      final requiresVerification = request.phoneNumber.isNotEmpty &&
          (AuthSessionPayload.requiresPhoneVerification(response.data) ||
              !session.hasAccessToken);

      if (!requiresVerification) {
        await session.persistTokens();
      }

      return SignUpResponse(
        user: session.user,
        requiresVerification: requiresVerification,
        phoneNumber: request.phoneNumber,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final normalizedPhone = PhoneNormalizer.normalize(phoneNumber);
    final request = OtpVerifyRequestDto(
      phoneNumber: normalizedPhone,
      otp: otp.trim(),
    );

    try {
      final response = await _dio.post<dynamic>(
        AuthApiEndpoint.otpVerify,
        data: request.toJson(),
      );

      final session = AuthSessionPayload.fromResponse(
        response.data,
        registerFallback: RegisterFallbackUser(
          fullName: '',
          email: '',
          phoneNumber: normalizedPhone,
        ),
      );
      await session.persistTokens();
      return session.user;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> resendOtp({required String phoneNumber}) async {
    final request = OtpResendRequestDto(
      phoneNumber: PhoneNormalizer.normalize(phoneNumber),
    );

    try {
      await _dio.post<dynamic>(
        AuthApiEndpoint.otpResend,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> requestPasswordReset({required String phoneNumber}) async {
    final request = ForgotPasswordRequestDto(
      phoneNumber: PhoneNormalizer.normalize(phoneNumber),
    );

    try {
      await _dio.post<dynamic>(
        AuthApiEndpoint.passwordForgot,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = ResetPasswordRequestDto(
      phoneNumber: PhoneNormalizer.normalize(phoneNumber),
      otp: otp.trim(),
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    try {
      await _dio.post<dynamic>(
        AuthApiEndpoint.passwordReset,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
