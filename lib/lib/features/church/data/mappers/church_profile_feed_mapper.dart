import 'package:faithconnect/features/church/data/dto/church_api_dto.dart';
import 'package:faithconnect/features/church/data/mappers/church_member_mapper.dart';
import 'package:faithconnect/features/church/data/models/church_profile_model.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_group.dart';
import 'package:faithconnect/features/home/data/models/home_feed_model.dart';
import 'package:faithconnect/features/home/data/models/post_model.dart';
import 'package:faithconnect/features/post/data/dto/post_api_dto.dart';

/// Maps `GET /v1/churches/:id` detail payload to [ChurchProfileFeedModel].
abstract final class ChurchProfileFeedMapper {
  ChurchProfileFeedMapper._();

  static ChurchProfileFeedModel fromDetailDto(
    ChurchApiDto dto, {
    required bool isFollowing,
  }) {
    final posts = _mapPosts(dto);
    final campaigns = dto.recentCampaigns
        .map(
          (c) => c.toCampaign(
            organizationNameOverride:
                dto.name.isNotEmpty ? dto.name : null,
          ),
        )
        .toList();
    final groups = dto.recentGroups
        .map(
          (g) => ChurchProfileGroup(
            id: g.id,
            name: g.name,
            description: g.description,
            coverImageUrl: g.imageUrl,
            memberCount: g.memberCount,
            isPrivate: g.isPrivate,
          ),
        )
        .toList();
    final members = _mapMembers(dto);

    FeaturedEventModel? featuredEvent;
    for (final campaign in dto.recentCampaigns) {
      final event = campaign.toFeaturedEventModel();
      if (event != null) {
        featuredEvent = event;
        break;
      }
    }

    return ChurchProfileFeedModel(
      profile: dto.toProfileModel(isFollowing: isFollowing),
      posts: posts,
      campaigns: campaigns,
      groups: groups,
      members: members,
      featuredEvent: featuredEvent,
      followerCount: dto.followerCount,
      campaignCount: dto.campaignCount > 0
          ? dto.campaignCount
          : campaigns.length,
    );
  }

  static List<PostModel> _mapPosts(ChurchApiDto dto) {
    return dto.recentPosts
        .where((post) => post.id.isNotEmpty)
        .map((post) => _enrichPost(post, dto))
        .toList();
  }

  static PostModel _enrichPost(PostApiDto post, ChurchApiDto church) {
    final model = post.toPostModel();
    return PostModel(
      id: model.id,
      authorName: church.name.isNotEmpty ? church.name : model.authorName,
      authorProfileId: church.id.isNotEmpty ? church.id : model.authorProfileId,
      authorAvatarUrl: church.displayAvatarUrl ?? model.authorAvatarUrl,
      content: model.content,
      imageUrl: model.imageUrl,
      mediaType: model.mediaType,
      tags: model.tags,
      likeCount: model.likeCount,
      commentCount: model.commentCount,
      isLiked: model.isLiked,
      timeAgoLabel: model.timeAgoLabel,
      createdAt: model.createdAt,
    );
  }

  static List<ChurchMember> _mapMembers(ChurchApiDto dto) {
    final members = <ChurchMember>[];

    final owner = dto.owner;
    if (owner != null && owner.userId.isNotEmpty) {
      members.add(
        ChurchMember(
          id: owner.id.isNotEmpty ? owner.id : owner.userId,
          userId: owner.userId,
          name: owner.name,
          avatarUrl: owner.avatarUrl,
          role: 'Owner',
        ),
      );
    }

    for (final moderator in dto.moderators) {
      members.add(ChurchMemberMapper.toEntity(moderator));
    }

    return members;
  }
}
