import 'package:faithconnect/core/config/env_config.dart';
import 'package:flutter/foundation.dart';

/// Dev-only console logger (respects [EnvConfig.enableLogs]).
abstract final class FaithLogger {
  FaithLogger._();

  static void d(String tag, String message) {
    if (!_enabled) return;
    debugPrint('[$tag] $message');
  }

  static void i(String tag, String message) {
    if (!_enabled) return;
    debugPrint('[$tag] $message');
  }

  static void w(String tag, String message) {
    if (!_enabled) return;
    debugPrint('[$tag] WARN: $message');
  }

  static void e(String tag, String message, [Object? error]) {
    if (!_enabled) return;
    if (error != null) {
      debugPrint('[$tag] ERROR: $message — $error');
    } else {
      debugPrint('[$tag] ERROR: $message');
    }
  }

  static bool get _enabled {
    try {
      return EnvConfig.instance.enableLogs || kDebugMode;
    } catch (_) {
      return kDebugMode;
    }
  }
}
