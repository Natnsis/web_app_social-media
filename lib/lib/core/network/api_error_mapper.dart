import 'package:dio/dio.dart';
import 'package:faithconnect/core/error/exception.dart';
import 'package:faithconnect/core/utils/phone_normalizer.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';

/// Maps [DioException] and API error bodies to a user-facing message.
abstract final class ApiErrorMapper {
  ApiErrorMapper._();

  static AuthException authExceptionFrom(DioException error) {
    final message = messageFrom(error);
    if (isUnverifiedAccount(error)) {
      return AuthException(
        message,
        code: AuthErrorCode.accountNotVerified,
        phoneNumber: phoneNumberFrom(error),
      );
    }
    return AuthException(message);
  }

  static Exception exceptionFrom(DioException error) {
    final message = messageFrom(error);
    final status = error.response?.statusCode;
    if (status == 401 || status == 403 || isUnverifiedAccount(error)) {
      return authExceptionFrom(error);
    }
    return ServerException(message: message);
  }

  static bool isUnverifiedAccount(DioException error) {
    final status = error.response?.statusCode;
    if (status == 403) return true;

    final message = messageFrom(error).toLowerCase();
    if (message.contains('not verified') ||
        message.contains('verify your phone') ||
        message.contains('phone verification') ||
        message.contains('verification required') ||
        message.contains('complete verification')) {
      return true;
    }

    final data = _responseMap(error);
    if (data == null) return false;

    final code = _stringValue(data['code'])?.toUpperCase();
    if (code != null &&
        (code.contains('NOT_VERIFIED') ||
            code.contains('UNVERIFIED') ||
            code.contains('PHONE_VERIFICATION'))) {
      return true;
    }

    return data['requiresVerification'] == true;
  }

  static String? phoneNumberFrom(DioException error) {
    final data = _responseMap(error);
    if (data != null) {
      for (final key in ['phoneNumber', 'phone', 'phone_number']) {
        final value = _stringValue(data[key]);
        if (value != null && PhoneNormalizer.looksLikePhone(value)) {
          return PhoneNormalizer.normalize(value);
        }
      }
      final nested = _asMap(data['data']);
      if (nested != null) {
        for (final key in ['phoneNumber', 'phone']) {
          final value = _stringValue(nested[key]);
          if (value != null) return PhoneNormalizer.normalize(value);
        }
      }
    }

    final message = messageFrom(error);
    final match = RegExp(r'\+?\d{10,15}').firstMatch(message);
    if (match != null) {
      return PhoneNormalizer.normalize(match.group(0)!);
    }
    return null;
  }

  static String messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return _fromMap(data) ?? _statusFallback(error);
    }
    if (data is Map) {
      return _fromMap(Map<String, dynamic>.from(data)) ?? _statusFallback(error);
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return error.message ?? 'Network request failed';
  }

  static String? _fromMap(Map<String, dynamic> map) {
    final direct = _stringOrJoin(map['message']) ??
        _stringOrJoin(map['error']) ??
        _stringOrJoin(map['detail']);
    if (direct != null) return direct;

    final errors = map['errors'];
    if (errors is Map) {
      final parts = <String>[];
      for (final entry in errors.entries) {
        final value = entry.value;
        final text = _stringOrJoin(value);
        if (text != null) {
          parts.add(text);
        }
      }
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return null;
  }

  static String? _stringOrJoin(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is List) {
      final parts = value
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return null;
  }

  static String? _stringValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static Map<String, dynamic>? _responseMap(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _statusFallback(DioException error) {
    final code = error.response?.statusCode;
    if (code == 401) {
      return 'Session expired. Please sign in again.';
    }
    if (code == 403) return 'Account not verified. Please verify your phone.';
    if (code == 400 && _isMissingUserLocation(error)) {
      return 'Turn on location access so we can find churches near you.';
    }
    if (code == 404) return 'Not found';
    if (code != null && code >= 500) return 'Server error. Please try again.';
    return error.message ?? 'Request failed';
  }

  static bool _isMissingUserLocation(DioException error) {
    return error.requestOptions.uri.path.contains('/churches/nearby');
  }
}
