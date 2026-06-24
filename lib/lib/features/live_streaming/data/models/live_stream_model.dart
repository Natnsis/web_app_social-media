import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';

class LiveStreamModel extends LiveStream {
  const LiveStreamModel({
    required super.id,
    required super.title,
    required super.hostId,
    required super.hostName,
    super.organizationName,
    super.isOrganizationVerified = false,
    super.hostAvatarUrl,
    super.playbackUrl,
    super.streamCode,
    super.rtmpUrl,
    super.thumbnailUrl,
    super.viewerCount,
    super.status,
    super.startedAt,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    final church = json['church'] as Map<String, dynamic>?;
    return LiveStreamModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      hostId: json['churchId']?.toString() ?? '',
      hostName: church?['name'] as String? ?? '',
      organizationName: church?['name'] as String?,
      isOrganizationVerified:
          json['is_organization_verified'] as bool? ?? false,
      hostAvatarUrl: church?['logoUrl'] as String?,
      playbackUrl: json['replayUrl'] as String?,
      streamCode: json['streamKey'] as String? ?? json['streamCode'] as String?,
      rtmpUrl: json['rtmpUrl'] as String? ?? json['streamUrl'] as String?,
      thumbnailUrl: json['bannerUrl'] as String?,
      viewerCount: json['viewerCount'] as int? ?? 0,
      status: _parseStatus(json['streamStatus'] ?? json['status']),
      startedAt: DateTime.tryParse(json['startAt']?.toString() ?? ''),
    );
  }

  static LiveStreamStatus _parseStatus(Object? value) {
    final raw = value?.toString().toLowerCase() ?? 'live';
    return switch (raw) {
      'scheduled' => LiveStreamStatus.scheduled,
      'ended' => LiveStreamStatus.ended,
      _ => LiveStreamStatus.live,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'host_id': hostId,
      'host_name': hostName,
      'organization_name': organizationName,
      'is_organization_verified': isOrganizationVerified,
      'host_avatar_url': hostAvatarUrl,
      'playback_url': playbackUrl,
      'thumbnail_url': thumbnailUrl,
      'viewer_count': viewerCount,
      'status': status.name,
      'started_at': startedAt?.toIso8601String(),
    };
  }

  LiveStream toEntity() => LiveStream(
    id: id,
    title: title,
    hostId: hostId,
    hostName: hostName,
    organizationName: organizationName,
    isOrganizationVerified: isOrganizationVerified,
    hostAvatarUrl: hostAvatarUrl,
    playbackUrl: playbackUrl,
    thumbnailUrl: thumbnailUrl,
    viewerCount: viewerCount,
    status: status,
    startedAt: startedAt,
  );
}
