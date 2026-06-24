import 'package:equatable/equatable.dart';

class LiveNowItem extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isLive;
  /// When [isLive], routes to the watch page for this stream.
  final String? streamId;

  const LiveNowItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isLive = false,
    this.streamId,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, isLive, streamId];
}
