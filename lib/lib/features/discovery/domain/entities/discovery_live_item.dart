import 'package:equatable/equatable.dart';

class DiscoveryLiveItem extends Equatable {
  final String streamId;
  final String organizationName;
  final String title;
  final String? thumbnailUrl;
  final int viewerCount;

  const DiscoveryLiveItem({
    required this.streamId,
    required this.organizationName,
    required this.title,
    this.thumbnailUrl,
    this.viewerCount = 0,
  });

  @override
  List<Object?> get props =>
      [streamId, organizationName, title, thumbnailUrl, viewerCount];
}
