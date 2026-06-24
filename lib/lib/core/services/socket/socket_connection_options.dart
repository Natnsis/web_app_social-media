import 'package:socket_io_client/socket_io_client.dart' as io;

/// Shared Socket.IO client options for real-time messaging namespaces.
abstract final class SocketConnectionOptions {
  SocketConnectionOptions._();

  /// Matches server client config: websocket transport, JWT auth handshake,
  /// and persistent reconnection with a 2s base delay.
  static void applyMessagingDefaults(io.OptionBuilder builder) {
    builder
        .setTransports(['websocket'])
        .enableReconnection()
        .setReconnectionDelay(2000)
        .setReconnectionAttempts(double.infinity);
  }
}
