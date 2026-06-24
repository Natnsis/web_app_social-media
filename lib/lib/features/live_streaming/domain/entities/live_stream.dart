import 'package:equatable/equatable.dart';

enum LiveStreamStatus { live, scheduled, ended }

class LiveStream extends Equatable {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final String? organizationName;
  final bool isOrganizationVerified;
  final String? hostAvatarUrl;
  final String? playbackUrl;
  final String? streamCode;
  final String? rtmpUrl;
  final String? thumbnailUrl;
  final int viewerCount;
  final LiveStreamStatus status;
  final DateTime? startedAt;

  const LiveStream({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    this.organizationName,
    this.isOrganizationVerified = false,
    this.hostAvatarUrl,
    this.playbackUrl,
    this.streamCode,
    this.rtmpUrl,
    this.thumbnailUrl,
    this.viewerCount = 0,
    this.status = LiveStreamStatus.live,
    this.startedAt,
  });

  bool get isLive => status == LiveStreamStatus.live;

  String get displayOrganization =>
      (organizationName?.trim().isNotEmpty == true
          ? organizationName!
          : hostName)
          .toUpperCase();

  @override
  List<Object?> get props => [
        id,
        title,
        hostId,
        hostName,
        organizationName,
        isOrganizationVerified,
        hostAvatarUrl,
        playbackUrl,
        streamCode,
        rtmpUrl,
        thumbnailUrl,
        viewerCount,
        status,
        startedAt,
      ];
}
