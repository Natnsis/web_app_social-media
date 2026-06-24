import 'dart:convert';

/// Formats socket payloads for debug logs — structure, types, and safe redaction.
abstract final class SocketPayloadFormatter {
  SocketPayloadFormatter._();

  static const _sensitiveKeys = {
    'token',
    'accessToken',
    'access_token',
    'refreshToken',
    'refresh_token',
    'authorization',
    'password',
    'secret',
  };

  static const _bodyKeys = {'body', 'content', 'text', 'message'};

  static const _conversationKeys = [
    'conversationId',
    'conversation_id',
    'roomId',
    'groupId',
    'group_id',
    'recipientId',
    'recipient_id',
  ];

  /// Top-level field names present in a map/list payload.
  static List<String> fieldKeys(dynamic raw) {
    if (raw is Map) return raw.keys.map((k) => k.toString()).toList()..sort();
    if (raw is List) {
      return ['<list length=${raw.length}>'];
    }
    return const [];
  }

  /// Human-readable Dart type for debugging unexpected shapes.
  static String typeLabel(dynamic raw) {
    if (raw == null) return 'null';
    if (raw is Map) return 'Map<String, dynamic>(${raw.length} keys)';
    if (raw is List) return 'List(${raw.length})';
    return raw.runtimeType.toString();
  }

  /// Extract conversation / group / recipient id when present.
  static String? conversationIdFrom(dynamic raw) {
    if (raw is! Map) return null;
    final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw);
    for (final key in _conversationKeys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Redacts secrets and truncates long text fields before logging.
  static dynamic sanitize(dynamic raw, {int bodyMaxLength = 160}) {
    if (raw is Map) {
      final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw);
      final out = <String, dynamic>{};
      for (final entry in map.entries) {
        final key = entry.key.toString();
        if (_sensitiveKeys.contains(key)) {
          out[key] = _redactSecret(entry.value);
          continue;
        }
        if (_bodyKeys.contains(key) && entry.value is String) {
          out[key] = _truncate(entry.value as String, bodyMaxLength);
          continue;
        }
        out[key] = sanitize(entry.value, bodyMaxLength: bodyMaxLength);
      }
      return out;
    }
    if (raw is List) {
      return raw
          .map((item) => sanitize(item, bodyMaxLength: bodyMaxLength))
          .toList(growable: false);
    }
    if (raw is String && raw.length > bodyMaxLength) {
      return _truncate(raw, bodyMaxLength);
    }
    return raw;
  }

  /// Pretty JSON (single line) for log lines; falls back to toString().
  static String format(dynamic raw, {int maxLength = 2400}) {
    if (raw == null) return 'null';
    try {
      final sanitized = sanitize(raw);
      final encoded = jsonEncode(sanitized);
      if (encoded.length <= maxLength) return encoded;
      return '${encoded.substring(0, maxLength)}…(+${encoded.length - maxLength} chars)';
    } catch (_) {
      final text = raw.toString();
      if (text.length <= maxLength) return text;
      return '${text.substring(0, maxLength)}…(+${text.length - maxLength} chars)';
    }
  }

  /// Multi-line block: type, keys, formatted body.
  static String describe(dynamic raw, {String indent = '  '}) {
    final buffer = StringBuffer();
    buffer.writeln('${indent}type: ${typeLabel(raw)}');
    final keys = fieldKeys(raw);
    if (keys.isNotEmpty) {
      buffer.writeln('${indent}fields: [${keys.join(', ')}]');
    }
    final conversationId = conversationIdFrom(raw);
    if (conversationId != null) {
      buffer.writeln('${indent}conversationId: $conversationId');
    }
    buffer.write('${indent}payload: ${format(raw)}');
    return buffer.toString();
  }

  static String _redactSecret(dynamic value) {
    if (value == null) return '<null>';
    final text = value.toString().trim();
    if (text.isEmpty) return '<empty>';
    return '<redacted len=${text.length}>';
  }

  static String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}…(${value.length} chars)';
  }
}
