import 'package:equatable/equatable.dart';

class ShortVideo extends Equatable {
  final String id;
  final String authorName;
  final String? authorProfileId;
  final String? authorAvatarUrl;
  final String caption;
  final String thumbnailUrl;
  final String? videoUrl;
  final String? streamCode;
  final String? novaAppId;
  final String audioLabel;
  final int likeCount;
  final int reflectionCount;
  final int viewCount;
  final bool isLiked;
  final bool isFollowing;

  const ShortVideo({
    required this.id,
    required this.authorName,
    this.authorProfileId,
    this.authorAvatarUrl,
    required this.caption,
    required this.thumbnailUrl,
    this.videoUrl,
    this.streamCode,
    this.novaAppId,
    required this.audioLabel,
    this.likeCount = 0,
    this.reflectionCount = 0,
    this.viewCount = 0,
    this.isLiked = false,
    this.isFollowing = false,
  });

  ShortVideo copyWith({
    bool? isLiked,
    int? likeCount,
    bool? isFollowing,
    int? reflectionCount,
  }) {
    return ShortVideo(
      id: id,
      authorName: authorName,
      authorProfileId: authorProfileId,
      authorAvatarUrl: authorAvatarUrl,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      streamCode: streamCode,
      novaAppId: novaAppId,
      audioLabel: audioLabel,
      likeCount: likeCount ?? this.likeCount,
      reflectionCount: reflectionCount ?? this.reflectionCount,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorProfileId,
        authorAvatarUrl,
        caption,
        thumbnailUrl,
        videoUrl,
        streamCode,
        novaAppId,
        audioLabel,
        likeCount,
        reflectionCount,
        viewCount,
        isLiked,
        isFollowing,
      ];
}
