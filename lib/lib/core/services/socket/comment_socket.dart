import 'dart:async';
import 'package:faithconnect/core/constants/socket_namespace.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CommentSocketService {
  final SocketService _socketService;
  io.Socket? _socket;

  CommentSocketService(this._socketService);

  /// Connects to the `/livestream` namespace and returns the socket.
  void connect() {
    _socket = _socketService.connect(SocketNamespace.livestream);
  }

  /// Disconnects from the `/livestream` namespace.
  Future<void> disconnect() async {
    await _socketService.disconnect(SocketNamespace.livestream);
    _socket = null;
  }

  /// Returns the current socket.
  io.Socket? get socket => _socket ?? _socketService.socketFor(SocketNamespace.livestream);

  /// Emits `stream:comment:send` to post a top-level comment.
  void sendComment({
    required String livestreamId,
    required String body,
    String? mediaUrl,
  }) {
    socket?.emit('stream:comment:send', {
      'livestreamId': livestreamId,
      'body': body,
      if (mediaUrl != null && mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
    });
  }

  /// Emits `stream:comment:reply` to reply to a comment or another reply.
  void replyComment({
    required String livestreamId,
    required String parentId,
    required String body,
    String? mediaUrl,
  }) {
    socket?.emit('stream:comment:reply', {
      'livestreamId': livestreamId,
      'parentId': parentId,
      'body': body,
      if (mediaUrl != null && mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
    });
  }

  /// Emits `stream:comment:update` to edit an existing comment.
  void updateComment({
    required String livestreamId,
    required String commentId,
    required String body,
  }) {
    socket?.emit('stream:comment:update', {
      'livestreamId': livestreamId,
      'commentId': commentId,
      'body': body,
    });
  }

  /// Emits `stream:comment:delete` to delete your own comment.
  void deleteComment({
    required String livestreamId,
    required String commentId,
  }) {
    socket?.emit('stream:comment:delete', {
      'livestreamId': livestreamId,
      'commentId': commentId,
    });
  }

  /// Emits `stream:comment:like` to like a comment.
  void likeComment({
    required String livestreamId,
    required String commentId,
  }) {
    socket?.emit('stream:comment:like', {
      'livestreamId': livestreamId,
      'commentId': commentId,
    });
  }

  /// Emits `stream:comment:unlike` to remove your like from a comment.
  void unlikeComment({
    required String livestreamId,
    required String commentId,
  }) {
    socket?.emit('stream:comment:unlike', {
      'livestreamId': livestreamId,
      'commentId': commentId,
    });
  }

  /// Listens to a specific event on the livestream namespace.
  void on(String event, void Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  /// Removes a listener from a specific event.
  void off(String event, [void Function(dynamic)? handler]) {
    socket?.off(event, handler);
  }
}
