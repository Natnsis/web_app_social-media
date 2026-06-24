import 'package:faithconnect/core/services/socket/socket_payload_formatter.dart';
import 'package:faithconnect/core/services/socket/socket_server_error.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';

/// Structured logs for socket traffic — emits, receives, errors, and lifecycle.
abstract final class SocketConversationLogger {
  SocketConversationLogger._();

  static const _coreTag = 'SocketTraffic';

  static void logLifecycle({
    required String phase,
    required String namespace,
    String? socketId,
    String? uri,
    String? reason,
    Map<String, String>? metadata,
  }) {
    final meta = _formatMetadata(metadata);
    FaithLogger.i(
      _coreTag,
      'LIFECYCLE phase=$phase namespace=$namespace '
      'socketId=${socketId ?? 'none'}'
      '${uri != null ? ' uri=$uri' : ''}'
      '${reason != null ? ' reason=$reason' : ''}'
      '$meta',
    );
  }

  static void logAuthHandshake({
    required String namespace,
    required bool hasToken,
    int? tokenLength,
  }) {
    FaithLogger.d(
      _coreTag,
      'AUTH_HANDSHAKE namespace=$namespace '
      'hasToken=$hasToken'
      '${tokenLength != null ? ' tokenLen=$tokenLength' : ''} '
      'transport=websocket',
    );
  }

  static void logConnectError({
    required String namespace,
    required dynamic error,
    String? socketId,
  }) {
    FaithLogger.e(
      _coreTag,
      'CONNECT_ERROR namespace=$namespace socketId=${socketId ?? 'none'}\n'
      '${SocketPayloadFormatter.describe(error)}',
      error is Exception ? error : null,
    );
  }

  static void logServerError({
    required String namespace,
    required SocketServerError error,
    String? socketId,
    dynamic raw,
  }) {
    FaithLogger.e(
      _coreTag,
      'SERVER_ERROR namespace=$namespace socketId=${socketId ?? 'none'} '
      'rejectedEvent=${error.event} message=${error.message}'
      '${error.code != null ? ' code=${error.code}' : ''}\n'
      '${SocketPayloadFormatter.describe(raw ?? error.raw ?? error.toMetadata())}',
    );
  }

  static void logUnparsedError({
    required String namespace,
    required dynamic raw,
    String? socketId,
  }) {
    FaithLogger.w(
      _coreTag,
      'UNPARSED_ERROR namespace=$namespace socketId=${socketId ?? 'none'}\n'
      '${SocketPayloadFormatter.describe(raw)}',
    );
  }

  static void logEmit({
    required String tag,
    required String namespace,
    required String? socketId,
    required bool connected,
    required String event,
    required Map<String, dynamic> payload,
  }) {
    final conversationId = SocketPayloadFormatter.conversationIdFrom(payload);
    FaithLogger.d(
      tag,
      'EMIT namespace=$namespace socketId=${socketId ?? 'none'} '
      'connected=$connected event=$event '
      'conversationId=${conversationId ?? 'n/a'}\n'
      '${SocketPayloadFormatter.describe(payload)}',
    );
  }

  static void logReceive({
    required String tag,
    required String namespace,
    required String? socketId,
    required String event,
    required dynamic raw,
    String? conversationId,
    Map<String, String>? details,
  }) {
    final resolvedConversationId =
        conversationId ?? SocketPayloadFormatter.conversationIdFrom(raw) ?? 'n/a';
    final detailText = _formatMetadata(details);
    FaithLogger.d(
      tag,
      'RECV namespace=$namespace socketId=${socketId ?? 'none'} '
      'event=$event conversationId=$resolvedConversationId$detailText\n'
      '${SocketPayloadFormatter.describe(raw)}',
    );
  }

  static void logDispatched({
    required String tag,
    required String namespace,
    required String? socketId,
    required String event,
    required String conversationId,
    Map<String, String>? details,
    dynamic parsedPayload,
  }) {
    final detailText = _formatMetadata(details);
    final parsedBlock = parsedPayload != null
        ? '\n${SocketPayloadFormatter.describe(parsedPayload, indent: '  parsed.')}'
        : '';
    FaithLogger.d(
      tag,
      'DISPATCH namespace=$namespace socketId=${socketId ?? 'none'} '
      'event=$event conversationId=$conversationId$detailText$parsedBlock',
    );
  }

  static void logDropped({
    required String tag,
    required String namespace,
    required String? socketId,
    required String event,
    required String reason,
    dynamic raw,
  }) {
    FaithLogger.w(
      tag,
      'DROP namespace=$namespace socketId=${socketId ?? 'none'} '
      'event=$event reason=$reason\n'
      '${SocketPayloadFormatter.describe(raw)}',
    );
  }

  static void logEmitSkipped({
    required String tag,
    required String namespace,
    required String event,
    required String reason,
    Map<String, dynamic>? payload,
  }) {
    final payloadBlock = payload != null
        ? '\n${SocketPayloadFormatter.describe(payload)}'
        : '';
    FaithLogger.w(
      tag,
      'EMIT_SKIPPED namespace=$namespace event=$event reason=$reason$payloadBlock',
    );
  }

  static void logConnectionWait({
    required String tag,
    required String namespace,
    required Duration timeout,
    required bool connected,
    String? socketId,
  }) {
    if (connected) {
      FaithLogger.d(
        tag,
        'CONNECTED namespace=$namespace socketId=${socketId ?? 'none'}',
      );
      return;
    }
    FaithLogger.w(
      tag,
      'CONNECTION_TIMEOUT namespace=$namespace '
      'timeout=${timeout.inMilliseconds}ms socketId=${socketId ?? 'none'}',
    );
  }

  static void logListenersAttached({
    required String tag,
    required String namespace,
    String? socketId,
    List<String>? events,
  }) {
    final eventList = events == null || events.isEmpty
        ? ''
        : ' events=[${events.join(', ')}]';
    FaithLogger.i(
      tag,
      'LISTENERS_ATTACHED namespace=$namespace '
      'socketId=${socketId ?? 'none'}$eventList',
    );
  }

  static String _formatMetadata(Map<String, String>? metadata) {
    if (metadata == null || metadata.isEmpty) return '';
    return ' ${metadata.entries.map((e) => '${e.key}=${e.value}').join(' ')}';
  }
}
