import 'package:equatable/equatable.dart';

/// Payload from the server `error` event when an emitted event is rejected.
class SocketServerError extends Equatable {
  final String event;
  final String message;
  final String? code;
  final Map<String, dynamic>? raw;

  const SocketServerError({
    required this.event,
    required this.message,
    this.code,
    this.raw,
  });

  static SocketServerError? tryParse(dynamic data) {
    if (data == null) return null;

    if (data is! Map) {
      final text = data.toString().trim();
      if (text.isEmpty) return null;
      return SocketServerError(
        event: 'unknown',
        message: text,
        raw: {'value': text},
      );
    }

    final map = data is Map<String, dynamic>
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from(data);

    final event = _string(map, 'event') ?? 'unknown';
    final message = _string(map, 'message') ??
        _string(map, 'error') ??
        _string(map, 'description') ??
        '';
    final code = _string(map, 'code') ?? _string(map, 'statusCode');

    if (event == 'unknown' && message.isEmpty && code == null) {
      return null;
    }

    return SocketServerError(
      event: event,
      message: message.isNotEmpty ? message : 'Server rejected the event',
      code: code,
      raw: map,
    );
  }

  Map<String, dynamic> toMetadata() => {
        'event': event,
        'message': message,
        if (code != null) 'code': code,
      };

  static String? _string(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  @override
  List<Object?> get props => [event, message, code, raw];
}
