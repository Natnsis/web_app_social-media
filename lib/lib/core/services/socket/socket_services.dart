import 'dart:async';

import 'package:faithconnect/core/config/env_config.dart';
import 'package:faithconnect/core/constants/socket_namespace.dart';
import 'package:faithconnect/core/network/auth_session_coordinator.dart';
import 'package:faithconnect/core/network/auth_token_provider.dart';
import 'package:faithconnect/core/services/socket/socket_connection_options.dart';
import 'package:faithconnect/core/services/socket/socket_conversation_logger.dart';
import 'package:faithconnect/core/services/socket/socket_server_error.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Namespace connect/disconnect notification for UI and blocs.
final class SocketNamespaceConnectionEvent {
  const SocketNamespaceConnectionEvent({
    required this.namespace,
    required this.isConnected,
  });

  final String namespace;
  final bool isConnected;
}

/// Connects to Socket.io namespaces with JWT handshake auth.
///
/// Token is passed via `auth: { token }` — not `Authorization` headers —
/// because WebSocket upgrades do not reliably carry HTTP headers on all platforms.
abstract class SocketService {
  /// Opens (or returns existing) connection to [namespace] (e.g. [SocketNamespace.messaging]).
  io.Socket connect(
    String namespace, {
    void Function(io.OptionBuilder builder)? configure,
  });

  /// Returns an active socket for [namespace], if connected.
  io.Socket? socketFor(String namespace);

  bool isConnected(String namespace);

  /// Waits until [namespace] is connected or [timeout] elapses.
  Future<bool> waitUntilConnected(
    String namespace, {
    Duration timeout = const Duration(seconds: 5),
  });

  /// Disconnects a single namespace and removes it from the registry.
  Future<void> disconnect(String namespace);

  /// Disconnects every open namespace (call on logout).
  Future<void> disconnectAll();

  /// Server rejections: `socket.on('error', ({ event, message }) => ...)`.
  Stream<SocketServerError> get onServerError;

  /// Fires when any namespace socket connects or disconnects.
  Stream<SocketNamespaceConnectionEvent> get onNamespaceConnectionChanged;
}

class SocketServiceImpl implements SocketService {
  SocketServiceImpl({AuthSessionCoordinator? sessionCoordinator})
      : _sessionCoordinator = sessionCoordinator;

  static const _logTag = 'SocketService';

  final AuthSessionCoordinator? _sessionCoordinator;
  final Map<String, io.Socket> _sockets = {};
  final StreamController<SocketServerError> _serverErrors =
      StreamController<SocketServerError>.broadcast();
  final StreamController<SocketNamespaceConnectionEvent> _connectionEvents =
      StreamController<SocketNamespaceConnectionEvent>.broadcast();

  @override
  Stream<SocketServerError> get onServerError => _serverErrors.stream;

  @override
  Stream<SocketNamespaceConnectionEvent> get onNamespaceConnectionChanged =>
      _connectionEvents.stream;

  @override
  io.Socket connect(
    String namespace, {
    void Function(io.OptionBuilder builder)? configure,
  }) {
    final normalized = _normalizeNamespace(namespace);
    final existing = _sockets[normalized];
    if (existing != null) {
      if (!existing.connected) {
        existing.connect();
      }
      return existing;
    }

    final uri = _namespaceUri(normalized);
    SocketConversationLogger.logLifecycle(
      phase: 'connecting',
      namespace: normalized,
      uri: uri,
      metadata: const {
        'transport': 'websocket',
        'auth': 'token handshake',
      },
    );

    final builder = io.OptionBuilder()
        .setAuthFn(_authPayloadResolver(normalized))
        .enableAutoConnect();
    SocketConnectionOptions.applyMessagingDefaults(builder);
    configure?.call(builder);

    final socket = io.io(uri, builder.build());

    _attachCoreListeners(socket, normalized);
    _sockets[normalized] = socket;
    return socket;
  }

  @override
  io.Socket? socketFor(String namespace) {
    return _sockets[_normalizeNamespace(namespace)];
  }

  @override
  bool isConnected(String namespace) {
    return _sockets[_normalizeNamespace(namespace)]?.connected ?? false;
  }

  @override
  Future<bool> waitUntilConnected(
    String namespace, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final key = _normalizeNamespace(namespace);
    if (isConnected(key)) return true;

    final socket = _sockets[key];
    if (socket == null) return false;

    final completer = Completer<bool>();
    void onConnect(_) {
      if (!completer.isCompleted) completer.complete(true);
    }

    socket.onConnect(onConnect);
    if (socket.connected && !completer.isCompleted) {
      completer.complete(true);
    }

    try {
      return await completer.future.timeout(
        timeout,
        onTimeout: () => isConnected(key),
      );
    } finally {
      socket.off('connect', onConnect);
    }
  }

  @override
  Future<void> disconnect(String namespace) async {
    final key = _normalizeNamespace(namespace);
    final socket = _sockets.remove(key);
    if (socket == null) return;

    socket
      ..off('connect')
      ..off('disconnect')
      ..off('connect_error')
      ..off('error')
      ..disconnect();
    socket.dispose();

    FaithLogger.i(_logTag, 'disconnected namespace: $key');
    SocketConversationLogger.logLifecycle(
      phase: 'disconnected',
      namespace: key,
    );
  }

  @override
  Future<void> disconnectAll() async {
    final namespaces = _sockets.keys.toList(growable: false);
    for (final namespace in namespaces) {
      await disconnect(namespace);
    }
  }

  void Function(void Function(Map<String, dynamic> auth) ack) _authPayloadResolver(
    String namespace,
  ) {
    return (void Function(Map<String, dynamic> auth) ack) {
      AuthTokenProvider.getAccessToken().then((token) {
        final trimmed = token?.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          SocketConversationLogger.logAuthHandshake(
            namespace: namespace,
            hasToken: true,
            tokenLength: trimmed.length,
          );
          ack({'token': trimmed});
          return;
        }
        SocketConversationLogger.logAuthHandshake(
          namespace: namespace,
          hasToken: false,
        );
        ack({});
      });
    };
  }

  void _attachCoreListeners(io.Socket socket, String namespace) {
    socket.onConnect((_) {
      SocketConversationLogger.logLifecycle(
        phase: 'connected',
        namespace: namespace,
        socketId: socket.id,
      );
      _emitConnectionChanged(namespace, isConnected: true);
    });

    socket.onDisconnect((reason) {
      SocketConversationLogger.logLifecycle(
        phase: 'disconnect',
        namespace: namespace,
        socketId: socket.id,
        reason: _stringify(reason),
      );
      _emitConnectionChanged(namespace, isConnected: false);
    });

    socket.onConnectError((error) {
      SocketConversationLogger.logConnectError(
        namespace: namespace,
        error: error,
        socketId: socket.id,
      );

      if (_connectErrorMessage(error).contains(SocketAuthError.wsAuthFailed)) {
        _sessionCoordinator?.handleSessionExpired();
      }
    });

    socket.on('error', (data) {
      final parsed = SocketServerError.tryParse(data);
      if (parsed == null) {
        SocketConversationLogger.logUnparsedError(
          namespace: namespace,
          raw: data,
          socketId: socket.id,
        );
        return;
      }

      SocketConversationLogger.logServerError(
        namespace: namespace,
        error: parsed,
        socketId: socket.id,
        raw: data,
      );
      if (!_serverErrors.isClosed) {
        _serverErrors.add(parsed);
      }
    });
  }

  String _namespaceUri(String namespace) {
    final base = EnvConfig.instance.apiBaseUrl;
    return '$base$namespace';
  }

  String _normalizeNamespace(String namespace) {
    final trimmed = namespace.trim();
    if (trimmed.isEmpty) return '/';
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  String _connectErrorMessage(dynamic error) {
    if (error is Map) {
      final message = error['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return _stringify(error);
  }

  String _stringify(dynamic value) {
    if (value == null) return 'unknown';
    return value.toString();
  }

  void _emitConnectionChanged(String namespace, {required bool isConnected}) {
    if (_connectionEvents.isClosed) return;
    _connectionEvents.add(
      SocketNamespaceConnectionEvent(
        namespace: namespace,
        isConnected: isConnected,
      ),
    );
  }
}
